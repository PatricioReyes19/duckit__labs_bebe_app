# Sincronización offline y notificaciones

## Flujo acordado

1. El registro o evento se guarda primero en SQLite con estado `pending`.
2. La interfaz lo muestra de inmediato y expone que todavía está local; no se
   confirma como sincronizado antes de recibir una respuesta de Supabase.
3. Al recuperar conexión, el coordinador sube perfiles y relaciones antes que
   registros, agenda, salud y preferencias.
4. Supabase inserta una fila durable en `activity_notifications` para cada otro
   cuidador del bebé. Si el registro fue creado hace más de dos minutos, la
   notificación se identifica como `synced_offline` y evita aparentar que el
   evento ocurrió recién.
5. Realtime actualiza la bandeja y el punto de no leídos dentro de la app.
6. Un Database Webhook llama a `send-activity-notification`; la Edge Function
   valida `ACTIVITY_WEBHOOK_SECRET` y envía FCM desde el servidor.
7. Al abrir el aviso se marca leído tanto local como remotamente.

La migración `20260812203000_describe_delayed_offline_activity.sql` incorpora
la descripción honesta de las cargas retrasadas. Requiere desplegarse en el
proyecto Supabase antes de que el flujo remoto la utilice.

## Diferencia entre recordatorio y alarma

- **Anticipación:** el banner visual de Home aparece durante los diez minutos
  previos. Sus acciones son `Gracias por recordar` (descartar) y `Ya lo hice`
  (descartar y abrir el registro correspondiente).
- **Plazo cumplido:** se programa como notificación local exacta, de prioridad
  máxima, con sonido y vibración. No depende de que Home esté abierto.
- **Actividad familiar:** es informativa; llega a bandeja, snackbar INAPP y FCM,
  pero no se presenta como alarma clínica.

## Límites de paquetes

| Responsabilidad | Ubicación |
|---|---|
| Entidades, contratos y casos de uso | `packages/core/lib/src/domain` |
| SQLite, Supabase, datasources, repositories y sync | `packages/core/lib/src/data` |
| FCM, notificaciones locales y bandeja visual | `packages/notifications` |
| Inyección, navegación y listeners globales | `packages/app_base` |
| Envío privilegiado con service role | `supabase/functions` |

El SDK de Firebase no debe importarse en el dominio de Core: es un adaptador de
plataforma sustituible. El paquete `notifications` dejó de estar anidado bajo
`apps/bebe_app`; Core conserva las abstracciones y datos compartidos, mientras
el paquete de infraestructura encapsula Firebase y `flutter_local_notifications`.

## Casos de prueba obligatorios

- Usuario A sin conexión crea un registro; A lo ve como local.
- A recupera conexión; el registro cambia a sincronizado una sola vez.
- Usuario B recibe una fila durable, un punto de no leído y un push FCM.
- El texto recibido por B dice “sincronizado” si la carga fue retrasada.
- A no recibe una notificación de su propia actividad.
- Usuario C, fuera del círculo, no puede leer ni modificar el registro o aviso.
- Reintentar una misma carga no duplica notificaciones.
- Un token FCM inválido se deshabilita sin impedir los demás envíos.

