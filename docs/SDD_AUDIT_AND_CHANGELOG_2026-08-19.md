# Auditoría de SDD y changelog de entrega

Fecha: 2026-08-19  
Alcance: splash, startup, SQLite, recordatorios, Salud, Agenda, reportes y sincronización.

## Resumen ejecutivo

La corrección de SQLite, la serialización de la apertura de base de datos, las
claves de `AnimatedSwitcher`, la coordinación de recordatorios y los cambios
de Salud/Agenda están presentes en el código local. No se ejecutaron pruebas
Flutter/Dart en esta sesión: el SDK no está disponible en el entorno de
ejecución. Por tanto, ningún estado marcado como `PASS` sustituye una ejecución
de pruebas en CI ni una prueba en Android físico.

Los dos riesgos de rendimiento más relevantes son:

1. Una pauta de medicamento puede materializar hasta 1.024 filas de Agenda,
   aunque la vista de futuros ya no muestre cada ocurrencia.
2. Salud todavía carga el historial local completo en memoria y la exportación
   PDF sigue construyéndose íntegramente en memoria. Las fotos ya tienen un
   límite estricto de cantidad y tamaño, pero falta redimensionarlas.

## Flujo de splash

### Veredicto

Visualmente, el flujo previsto es `Native splash -> nubes -> destino`. No se
encontró un loader, fondo blanco o logo distinto entre el splash nativo y la
composición de nubes.

`apps/bebe_app/lib/bootstrap.dart` ejecuta un único `runApp`. Su raíz mantiene
`_BootstrapCloudSplash` mientras se inicializan las dependencias y sustituye
su contenido por `App` en la misma raíz. El router inicia en `SplashPage`, que
vuelve a usar `SplashBrandContent`; por tanto, entre Native y el destino sólo
se muestran nubes, sin logo, loader o árbol Flutter de reemplazo.

### Recomendación

La arquitectura de raíz única ya está aplicada. Antes de declararla cerrada se
debe probar en un Android físico, cold start y warm start, con modo oscuro y
`disableAnimations`.

### Excepción válida

`AppError` puede mostrarse si falla el bootstrap técnico antes de crear el
router. Es un error fatal de precondición, no una pantalla de carga intermedia.

## Formularios de Controles y Consultas

### Cambio aplicado

El primer paso del formulario permite guardar una cita futura mediante
`Agendar y crear recordatorio` con sólo fecha y hora. Pediatra y motivo son
opcionales; resumen, tratamiento, seguimiento y vigilancia se pueden completar
después.

- Control: título por defecto `Control de niño sano`.
- Consulta: título por defecto `Consulta pediátrica`.
- Ambos se persisten como `HealthEventStatus.scheduled` y se proyectan en
  Agenda desde `health_events`.
- Los recordatorios de Salud ahora distinguen `Consulta pediátrica` de
  `Control de salud`.
- Al guardar una cita futura, el flujo solicita/programa el recordatorio nativo
  de inmediato; no espera la siguiente sincronización. Si se reprograma,
  confirma asistencia, no asiste o finaliza, el recordatorio previo se
  reemplaza o cancela sin depender de la reconciliación global.

### Decisión funcional vigente

`health_events` es la fuente canónica de las citas nuevas. `register_events`
permanece como historial/compatibilidad para consultas antiguas migradas.

### Riesgos y pruebas pendientes

- Falta una prueba de widget que seleccione una fecha futura, pulse la acción
  rápida y compruebe un `HealthEvent` programado con título de fallback.
- Falta una prueba de integración Android de permiso concedido/denegado y una
  prueba de que la notificación de consulta recibe su título específico.

## Agenda y recurrencias

### Cambio aplicado

`AgendaOverviewVm.upcomingAfter` ahora conserva sólo la siguiente ocurrencia
futura de cada `sourceRegisterEventId`. Eventos únicos continúan apareciendo
individualmente. En el día seleccionado, la UI agrupa varias ocurrencias de la
misma serie y muestra la cantidad. En futuros, las series aparecen en la
sección visible **Pautas recurrentes**, separada de los eventos únicos y con
una card identificable por pauta.

Resultado esperado para una pauta diaria:

```text
Próxima dosis: Vitamina D
Mañana · 08:00
Diario
```

No debe existir una tarjeta por cada día/dosis futura.

### Riesgo de rendimiento aún abierto (P1)

`RegisterAgendaCoordinator` sigue creando filas derivadas para cada dosis:

- horizonte abierto: 90 días;
- límite: 1.024 dosis por pauta;
- una pauta cada 4 horas puede crear aproximadamente 540 filas por
  medicamento antes de alcanzar el horizonte;
- las filas se persisten localmente y se sincronizan individualmente.

La mejora actual corrige la presentación, no el costo de almacenamiento, sync,
marcadores de calendario ni las consultas sobre `agenda_events`.

### SDD recomendado: SDD-010 — Serie recurrente canónica

Representar una pauta recurrente como una serie canónica con regla, inicio y
fin, y calcular la próxima ocurrencia para Agenda/notificaciones. Mantener sólo
las ocurrencias necesarias para la ventana de alarmas del sistema operativo;
no materializar 90 días de filas sincronizables. La migración debe conservar
las filas derivadas existentes y limpiar únicamente las que puedan regenerarse
de forma segura.

## Reportes de Salud

### Arquitectura encontrada

- `HealthFlowController.load()` carga todos los `register_events` del bebé sin
  límite y mantiene la colección en memoria.
- `ClinicalReportEngine` filtra en memoria el rango del reporte, agrega
  registros y combina citas canónicas con consultas históricas.
- `ClinicalReportPdfRenderer` carga fuentes y todas las fotos seleccionadas
  como `Uint8List`, construye el PDF en memoria y `SharePlus` vuelve a recibir
  el archivo como bytes.

### Hallazgos

1. **Memoria alta al exportar fotos (P1, mitigado):** el PDF incorpora como
   máximo 8 fotos y omite archivos de más de 5 MiB. Esto limita la entrada a
   40 MiB antes del documento, pero no hay downsampling ni streaming: los bytes
   incluidos, el PDF y `XFile.fromData` aún coexisten en memoria.
2. **Historial en memoria (P1):** abrir Salud puede cargar años de registros,
   aunque la pantalla normalmente muestre un resumen reciente.
3. **Paginación de reporte (P2):** el motor filtra después de cargar, no en la
   consulta SQLite. Para reportes largos, debe recibir datos por rango y/o
   paginados.
4. **Deduplificación parcial (P2):** consultas históricas se excluyen cuando
   comparten exactamente el mismo `id` con `health_events`; la migración V9 lo
   garantiza. Importaciones antiguas con IDs distintos podrían aparecer dos
   veces y requieren una clave de trazabilidad explícita para deduplicar.

### SDD recomendado: SDD-011 — Reportes paginados y exportación acotada

- Consultar registros por rango de fechas y tipo desde SQLite.
- Limitar o paginar la previsualización de Salud.
- Al exportar, limitar fotos, redimensionarlas antes de incorporarlas al PDF y
  mostrar el tamaño/alcance de exportación.
- Añadir pruebas con historial grande y fotos de alta resolución, midiendo
  tiempo de generación y memoria pico.

## Peticiones remotas y sincronización

### Controles correctos encontrados

- Registro y Agenda poseen cursor estable por `updated_at` + `id`.
- Agenda usa páginas de 200 registros durante sync.
- El coordinador inicial paraleliza las sincronizaciones hijas después de
  hidratar Family/Babies.
- Agenda hace debounce de reload de 32 ms y sus servicios de sync aplican
  single-flight.

### Riesgos abiertos

1. **Family sin delta/paginación (P1):** cada sync realiza cuatro selects
   completos (`families`, `babies`, `baby_caregivers`, `profiles`). Es correcto
   funcionalmente para membresías, pero puede crecer con el número de círculos
   y perfiles accesibles.
2. **Pauta recurrente amplifica tráfico (P1):** las filas derivadas de
   medicamento se suben una a una vía RPC. Este punto es dependiente de
   SDD-010.
3. **Caché de imágenes (P2, mitigado):** bootstrap redujo
   `PaintingBinding.instance.imageCache.maximumSizeBytes` de 300 MiB a 96 MiB.
   Aún conviene hacerlo adaptativo tras medir Android real.
4. **Carga de archivos para Storage (P2):** `uploadObject` usa
   `file.readAsBytes()`, por lo que archivos grandes se cargan enteros en RAM.
   Conviene usar streaming/multipart cuando el cliente lo permita.

### Mejora aplicada

Salud ya utiliza cursor estable `updated_at + id` y páginas de 200 registros
cuando el remoto soporta `PagedHealthEventRemoteDataSource`. Las instalaciones
anteriores con cursor sólo de fecha realizan una última lectura compatible y,
después de sincronizar con éxito, pasan al cursor completo. Se agregó una prueba
con 201 eventos para comprobar que no se invoca la lectura remota ilimitada.

## Estado de los SDD trabajados

| SDD | Estado de revisión | Evidencia / pendiente |
| --- | --- | --- |
| SDD-001 SQLite V9 sin JSON1 | PARTIAL | Migración Dart con `jsonDecode`, batch e idempotencia presente. Falta ejecutar pruebas V8->V9 en CI/Android. |
| SDD-002 BebeDatabase single-flight | PARTIAL | Existe `_openingFuture` por ruta y prueba de llamadas concurrentes. Faltan pruebas de fallo/retry, conteo exacto de opens y cambio de scope concurrente. |
| SDD-003 cuidador invitado | PARTIAL | Startup usa snapshots remotos de familias/bebés accesibles y guarda `ActiveContext`. Falta validar pending/revoked y reinstalación contra backend/Android. |
| SDD-004 Native -> Cloud Splash | PARTIAL | Hay una única raíz Flutter y sólo nubes entre Native y el destino. Falta prueba física. |
| SDD-005 AnimatedSwitcher | PARTIAL | Hijos tienen claves explícitas y se agregó prueba de retry. Falta ejecutar el paquete Splash. |
| SDD-006 readiness antes de reminders | PARTIAL | `AuthenticatedStartupStatus.ready` bloquea la reconciliación previa. Faltan pruebas unitarias de transición ready/sync y fallo controlado. |
| SDD-007 regresión integral | PENDING | No hay evidencia de matriz integral ni dispositivo Android físico. |
| SDD-008 agendamiento rápido | PARTIAL | Implementado en UI y persistencia existente. Faltan tests de widget, reminder y edición posterior. |
| SDD-009 futuros recurrentes | PARTIAL | Se deduplicó la vista de futuros. Permanece la materialización/sync masiva de filas; requiere SDD-010. |

## Archivos modificados en este conjunto de trabajo

```text
apps/bebe_app/lib/bootstrap.dart
apps/bebe_app/pubspec.yaml
packages/app_base/lib/src/app/app_listeners.dart
packages/app_base/lib/src/app/app_wrappers.dart
packages/app_base/lib/src/notifications/notification_reminder_coordinator.dart
packages/app_base/lib/src/router/router.dart
packages/app_base/lib/src/startup/authenticated_startup_coordinator.dart
packages/app_base/test/authenticated_startup_coordinator_test.dart
packages/agenda/lib/models/agenda_overview_vm.dart
packages/agenda/test/agenda_register_integration_test.dart
packages/core/lib/src/data/local/bebe_database.dart
packages/core/lib/src/data/local/bebe_database_schema.dart
packages/core/lib/src/data/datasources/remote/health_event_remote_data_source.dart
packages/core/lib/src/data/repositories/sqlite_health_repository.dart
packages/core/lib/src/data/sync/health_event_sync_service.dart
packages/core/test/health/health_appointment_lifecycle_test.dart
packages/core/test/local/account_scoped_database_test.dart
packages/core/test/sync/pending_sync_queues_test.dart
packages/health/lib/clinical_reports/clinical_report_pdf_renderer.dart
packages/health/lib/models/health_flow_controller.dart
packages/health/lib/pages/views/health_flow_detail_views.dart
packages/health/test/health_views_test.dart
packages/splash/lib/src/views/splash_view.dart
packages/splash/test/views/splash_brand_content_test.dart
```

## Validación obligatoria antes de merge oficial

1. Ejecutar `flutter test` para `packages/core`, `packages/app_base`,
   `packages/splash`, `packages/agenda` y `packages/health`.
2. Ejecutar análisis estático y formato Dart.
3. Cold start Android con DB V8 real, JSON corrupto y sesión autenticada.
4. Login de cuidador invitado con DB vacía y con DB existente.
5. Agendar control y consulta futuros con sólo fecha/hora; comprobar ambas
   notificaciones y completar el resumen posteriormente.
6. Crear una pauta cada 4 horas, comprobar una sola tarjeta en futuros y medir
   número de filas/peticiones producidas.
7. Exportar un reporte con historial extenso y fotos grandes, observando RAM,
   tiempo y tamaño final del PDF.
