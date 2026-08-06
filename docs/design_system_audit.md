# Auditoría de diseño y sistema de componentes

Fecha: 5 de agosto de 2026

## Alcance

Se contrastó el workspace Flutter con los 106 PNG disponibles en
`C:\Users\reyes\Downloads\mock_up` y se revisaron el sistema de diseño, la
navegación, los módulos funcionales y sus pruebas.

Los archivos de diseño corresponden principalmente a pantallas móviles en
orientación vertical. Hay 13 dimensiones de imagen distintas, pero no existe
una especificación canónica de breakpoints ni diseños equivalentes para tablet,
horizontal, escritorio, modo oscuro o escalado de texto. Tres imágenes son
tableros de arquitectura o flujo y dos PNG son duplicados exactos:
`ChatGPT Image 27 jul 2026, 19_19_42.png` y
`ChatGPT Image 27 jul 2026, 19_19_51.png`.

## Resultado ejecutivo

La base visual es consistente y el catálogo de componentes es amplio, pero el
producto actual cubre principalmente vistas resumen y formularios
presentacionales. La mayoría de los flujos profundos de los diseños todavía no
está conectada a rutas, estado o persistencia real.

La auditoría detectó cuatro riesgos principales:

1. Comportamiento responsive repetido y con criterios distintos entre
   componentes.
2. Componentes o propiedades duplicadas, sin uso o con responsabilidades
   solapadas.
3. Flujos visibles con callbacks vacíos, datos simulados y rutas pendientes.
4. Ausencia de una fuente de diseño versionada y de referencias para estados
   responsive, accesibilidad y modo oscuro.

## Estandarización aplicada

- Se creó un contrato responsive común en `BebeLayout`, con breakpoints de
  360, 600 y 960 px y anchos máximos de contenido de 520, 720 y 960 px.
- Se incorporaron `BebeResponsiveContent` y `BebeAdaptiveGrid` como primitivas
  reutilizables.
- Se migraron las grillas de acciones, formularios, resumen familiar y perfiles
  de bebé al mismo algoritmo adaptativo.
- Se limitaron y centraron los templates de Home, Agenda, Salud, detalle de
  consulta, Familia, Ajustes y Registro.
- El encabezado del bebé activo ahora se apila cuando falta espacio o aumenta
  el texto.
- El resumen diario conserva tres tarjetas en los anchos móviles de referencia
  y permite desplazamiento cuando el texto necesita más espacio.
- Las acciones rápidas dejaron de usar un ancho artificial de 1,5 veces el
  espacio disponible.
- La barra inferior aumenta su altura con el escalado de texto.
- Se normalizaron los títulos y la marca del encabezado para Home, Agenda,
  Salud y Familia.
- Se eliminó un template de agenda casi duplicado, estado de scroll muerto y
  propiedades sin consumidores en Home.
- La acción rápida de Home ahora abre el tipo de registro seleccionado, en vez
  de enviar siempre el mismo identificador.

## Cobertura funcional frente a los diseños

| Área de diseño | Estado actual | Trabajo pendiente |
| --- | --- | --- |
| Inicio | Parcial | Sustituir datos simulados y conectar estados vacío, offline y primer registro. |
| Agenda | Parcial | Conectar filtros, detalle, edición y acciones clínicas a rutas y casos de uso. |
| Registro rápido | Integrado localmente | La ruta, cubits, validación y SQLite existen; falta usar el bebé activo real, probar el repositorio y definir sincronización. |
| Vacunas y controles | Mayormente faltante | Calendario, detalle, aplicación, éxito, recordatorios e historial. |
| Crecimiento y mediciones | Mayormente faltante | Peso, talla, historial, estados vacío/offline y visualización de evolución. |
| Informes | Faltante | Resumen, detalle, exportación PDF/CSV, compartir y estados vacío/offline. |
| Consultas médicas | Parcial | Flujo completo de consulta, profesionales, directorio, detalle y evaluación. |
| Salud | Parcial | El resumen existe; faltan datos reales y navegación a los flujos profundos. |
| Familia | Parcial | Cambio de bebé, perfil, círculo de cuidado, miembro, invitación y permisos. |
| Onboarding y acceso | Avanzado | Extraer componentes privados, conectar backend y ampliar pruebas de estados de error. |
| Notificaciones | Faltante | La ruta todavía resuelve a una pantalla pendiente. |
| Sesión y bebé activo | Estructura solamente | Implementar los manejadores de eventos y su fuente de datos. |

## Hallazgos de responsividad y accesibilidad

- Los diseños no definen formalmente qué debe ocurrir bajo 360 px, sobre 600
  px, en landscape o en desktop. El código estandarizado aplica un criterio
  conservador de una, dos o tres columnas según el espacio real disponible.
- Se añadió cobertura automática para 320/375/390/430/768 px en Registro y
  pruebas directas de grillas, ancho máximo y texto al 200 % en el sistema de
  diseño.
- Faltan pruebas visuales equivalentes para todos los templates principales a
  320, 390, 430, 768 y 1024 px, además de modo oscuro y contraste.
- Los goldens actuales de Registro contienen glifos cuadrados en algunos
  iconos. Aunque las pruebas pasan, esa referencia visual no debe considerarse
  aprobada hasta corregir la carga o selección de la fuente de iconos.
- Los mockups de Registro muestran navegación inferior, mientras la política de
  la app oculta la barra para `/register`. Se debe decidir si Registro pertenece
  al shell principal o es un flujo modal y alinear diseño, ruta y pruebas.

## Redundancia y escalabilidad pendientes

- Corregir nombres heredados antes de ampliar la API pública:
  `up_comming`, `upcomming`, `carrousel`, `care_giver`, `deatil` e `infor`.
- Separar el estado de tema del paquete visual. Actualmente `design_system`
  depende de `core` para `AppThemeBloc`, lo que acopla presentación y estado de
  aplicación.
- Alinear el requisito de SDK del workspace con los paquetes; varios paquetes
  exigen Dart 3.12.2 mientras la raíz declara un mínimo anterior.
- Dividir `onboarding_view.dart`, que concentra más de mil líneas y numerosos
  valores geométricos locales, en pasos y componentes reutilizables.
- Documentar variantes, estados, accesibilidad y uso permitido de cada
  componente. Widgetbook ofrece buena cobertura inicial, pero no todos los
  componentes públicos tienen caso de uso.
- Sustituir los callbacks vacíos de Agenda, Salud y Familia por contratos de
  navegación explícitos o deshabilitar visualmente las acciones no disponibles.

## Backlog recomendado

### P0 — Producto navegable y datos confiables

1. Versionar una fuente canónica de diseño y definir viewport, estado y versión
   de cada pantalla.
2. Sustituir el `babyId` y los datos de bebé fijos de Registro por el contexto
   activo; probar el repositorio y definir sincronización.
3. Conectar las acciones de Agenda, Salud y Familia a rutas reales.
4. Implementar sesión, bebé activo y repositorios; eliminar datos simulados.
5. Corregir los glifos de iconos y regenerar/aprobar los goldens.

### P1 — Cobertura de los flujos diseñados

1. Vacunas, controles, crecimiento y mediciones.
2. Consultas, profesionales y evaluación.
3. Informes, exportación y compartir.
4. Círculo de cuidado, invitaciones, perfiles y cambio de bebé.
5. Notificaciones y estados vacío, error y offline.
6. Matriz visual y semántica por viewport, tema y escala de texto.

### P2 — Mantenibilidad del sistema

1. Renombrar APIs con errores ortográficos mediante una migración compatible.
2. Desacoplar tema y estado del paquete de componentes.
3. Alinear SDKs y documentar soporte de plataforma.
4. Extraer y catalogar los componentes de onboarding.
5. Completar casos de Widgetbook y documentación de componentes públicos.

## Verificación ejecutada

- Análisis estático completo: 16 paquetes sin errores ni observaciones. Después
  de cambios concurrentes se volvieron a analizar `core`, `register` y
  `app_base`, también sin observaciones.
- 70 tests aprobados en 11 paquetes: sistema de diseño, registro, layout,
  núcleo, autenticación, login, signup, splash, onboarding, app base y app.
- Registro conserva cobertura visual en 320, 375, 390, 430 y 768 px, temas
  claro/oscuro y texto al 200 %.
- El sistema de diseño verifica resolución de grillas, ancho máximo, resumen
  diario móvil y comportamiento con texto al 200 %.
- Permanecen espacios finales en archivos generados por Freezed de Agenda y
  Familia. Deben limpiarse regenerando esos archivos junto con los modelos que
  pertenecen a ese trabajo, no mediante una edición manual aislada.

## Criterio mínimo para considerar una pantalla terminada

Una pantalla debe contar con ruta accesible, datos no simulados, estados de
carga/vacío/error/offline cuando correspondan, acciones conectadas, semántica,
soporte de texto al 200 %, verificación en los viewports definidos y pruebas de
regresión visual aprobadas.
