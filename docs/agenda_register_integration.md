# Integración Registro ↔ Agenda

## Decisión de producto

- **Registro** conserva hechos ocurridos: una toma, un sueño, un pañal, una
  observación, una dosis administrada o una medición.
- **Agenda** conserva acciones futuras: vacunas, controles, exámenes,
  recordatorios y próximas dosis.
- Agenda consulta los registros locales para mostrar **Registros del día**. No
  copia esos datos a otra tabla, por lo que Historial, Inicio y Agenda leen la
  misma fuente de verdad.
- El CTA **Registrar evento ahora** lleva al flujo especializado de Registro;
  **Ver historial** lleva al historial completo.

Esta separación evita el error de tratar un hecho pasado como una cita y
elimina divergencias entre pantallas.

## Medicación programada

Al guardar una dosis con `schedule_next_doses = true`,
`RegisterAgendaCoordinator` proyecta solo las dosis futuras:

1. Interpreta la frecuencia guardada.
2. Genera una ventana móvil de 14 días, con un máximo de 64 dosis.
3. Usa un id determinista (`source register id + fecha UTC`) para que dos
   dispositivos produzcan el mismo recordatorio sin duplicarlo.
4. Vincula cada recordatorio con `source_register_event_id`.
5. Si se edita, desprograma o elimina el registro original, reconcilia y crea
   tombstones para las dosis que ya no corresponden.

`Una vez` no genera un evento futuro. Una fecha de término explícita limita la
pauta antes de la ventana móvil.

## Offline y sincronización

- Tanto `register_events` como `agenda_events` se escriben primero en SQLite.
- Las altas, ediciones y eliminaciones se encolan con estado local.
- Los borrados se conservan como tombstones hasta propagarse.
- Supabase aplica last-write-wins por `updated_at` mediante RPC idempotentes.
- RLS restringe cada fila al `sub` del JWT de Firebase.
- La sincronización se dispara al guardar, iniciar sesión, abrir la app y
  volver desde segundo plano.
- La interfaz distingue datos sincronizados de datos guardados localmente.

## Flujo de Agenda

- La sección **Programado** responde a la categoría seleccionada.
- **Registros del día** muestra toda la actividad ocurrida, porque filtrar un
  pañal o una toma con categorías médicas ocultaría información importante.
- **Nuevo recordatorio** exige tipo, título, fecha y hora futura; las notas son
  opcionales. Confirma explícitamente que el guardado es local primero.
- El detalle indica si un evento proviene de una pauta registrada y su estado
  de sincronización.
