# Supabase: contrato, sincronización y notificaciones

## Estado de la integración

La aplicación usa un enfoque **offline-first**:

1. la UI llama casos de uso y repositorios de dominio;
2. el repositorio escribe primero en SQLite y devuelve el resultado sin esperar
   a la red;
3. el servicio de sincronización procesa filas `pending`/`failed`;
4. el datasource remoto convierte el modelo y llama Data API, RPC o Storage;
5. Supabase Realtime solo despierta un nuevo pull; nunca escribe SQLite de
   forma directa.

La implementación remota está separada dentro de `data`:

```text
data/
  datasources/remote/  # GET, POST/RPC y PATCH
  models/              # entidad <-> SQLite <-> JSON remoto
  repositories/        # implementación local y adaptadores de repositorio
  sync/                # cola, reintentos, cursores y repositorios offline-first
  network/             # Dio, token Firebase y errores HTTP
```

La app queda operativa en modo local si faltan las variables de Supabase. Para
conectarla a un proyecto real todavía se deben proporcionar la URL y la
publishable key y desplegar las migraciones; esos secretos no se incluyen en
el repositorio.

## Matriz GET / POST / PATCH

| Área | Lectura | Creación/actualización | Eliminación o estado |
|---|---|---|---|
| Registros: alimentación, sueño, pañal, observación, medicamento y medición | `GET register_events` | `POST rpc/apply_register_event` | tombstone por el mismo RPC (`deleted_at`) |
| Agenda y recordatorios recurrentes | `GET agenda_events` | `POST rpc/apply_agenda_event` | tombstone por el mismo RPC |
| Controles, vacunas y eventos de salud | `GET health_events` | `POST rpc/apply_health_event` | cambio de `status`; no hay borrado físico |
| Familia y bebés | `GET families`, `babies`, `baby_caregivers`, `profiles` | `POST rpc/apply_family_snapshot` | no se borra remotamente desde la app |
| Preferencias | `GET user_preferences` | `POST rpc/apply_user_preferences` | no aplica |
| Bandeja de actividad | `GET activity_notifications?read_at=is.null` | la crea un trigger del servidor | `PATCH activity_notifications` para `read_at` |
| Dispositivos FCM | RPC del servidor/Edge Function | `POST rpc/register_push_device` | `POST rpc/unregister_push_device` |
| Invitaciones | `POST rpc/lookup_care_invitation` | `create`, `accept`, `resend` por RPC | `reject` y `revoke` por RPC |
| Fotos de observación | se conserva el path privado en `details` | `POST storage/v1/object/register-event-media/...` | `DELETE storage/v1/object/register-event-media` |

Los RPC de escritura implementan un upsert transaccional y validan RLS. Se usa
`POST` aunque semánticamente actualicen una fila porque PostgREST expone las
funciones PostgreSQL bajo `/rest/v1/rpc/<función>`. `PATCH` directo solo se usa
para marcar notificaciones leídas.

## Datos enviados y recibidos

### Registro

Se envía y recibe:

```text
id, baby_id, event_type, occurred_at, created_at, updated_at, deleted_at,
caregiver_id, notes, details, schema_version
```

`details` contiene los campos específicos del formulario. Las mediciones de
crecimiento se guardan aquí con `measurement_type`, `value` y `unit`; Salud
consume esos mismos registros, por lo que no existe una segunda escritura
remota de la medición. `photo_paths` nunca se sube: se suben los archivos al
bucket y se persisten únicamente `photo_storage_paths`.

### Agenda

```text
id, baby_id, category, title, description, starts_at, created_at, updated_at,
deleted_at, caregiver_id, source_register_event_id
```

`source_register_event_id` evita duplicar eventos creados desde un medicamento
u otro registro. Las recurrencias siguen siendo eventos normales en la base;
el agrupamiento visual no altera su persistencia.

### Salud

```text
id, baby_id, event_type, title, description, starts_at, caregiver_id, status,
created_at, updated_at
```

`event_type`: `vaccine`, `pediatricControl` o `growthControl`.
`status`: `scheduled`, `completed` o `cancelled`.

### Familia

El snapshot envía:

```json
{
  "family_id": "...",
  "family_name": "...",
  "updated_at": "UTC ISO-8601",
  "babies": [
    {"id": "...", "display_name": "...", "birth_date": "UTC ISO-8601"}
  ]
}
```

Los miembros se consultan desde `baby_caregivers` y `profiles`; no se acepta
desde el cliente un listado arbitrario de miembros. Las invitaciones son las
únicas operaciones autorizadas para agregar o quitar acceso. La selección de
bebé activo y la ruta local de su avatar se conservan en el dispositivo.

### Preferencias

```text
theme_mode, high_contrast, personal_reminders, family_activity, daily_summary,
reduce_motion, wifi_only, account_name, account_email, language, time_format,
text_size, updated_at
```

El mismo RPC actualiza `profiles` con nombre y correo. Así las invitaciones y
las tarjetas de Familia pueden resolver al cuidador sin duplicar una API de
perfil.

### Datos que nunca salen del dispositivo

- JWT, refresh token, contraseña o secret/service-role key;
- `sync_status`, `sync_error` y cursores;
- rutas locales de archivos (`photo_paths`, avatar local);
- estado efímero de BLoC, navegación, loaders y snackbars.

## Resolución de conflictos y reintentos

- Cada mutación local incrementa `updated_at` y queda `pending`.
- El RPC acepta la versión más nueva (`last-write-wins`).
- Los borrados de Registro/Agenda son tombstones para no resucitar datos.
- El pull incremental usa `updated_at=gte.<cursor>` y orden
  `updated_at.asc,id.asc`. El `gte` repite como máximo algunas filas, pero evita
  perder dos cambios con el mismo timestamp; el merge local es idempotente.
- El cursor solo avanza si el pull terminó. Un POST exitoso seguido de un GET
  fallido no puede saltarse cambios de otro cuidador.
- Los fallos quedan reintentables. La sincronización se solicita al guardar,
  al iniciar, al volver de segundo plano y al recibir Realtime.
- RLS autoriza por `baby_caregivers`; el cliente no decide permisos.

## Implementación paso a paso

### 1. Crear y enlazar Supabase

1. Crear un proyecto en Supabase.
2. Instalar Supabase CLI (en este checkout no está instalada actualmente).
3. Desde la raíz del repositorio ejecutar:

```powershell
supabase init              # solo si todavía falta supabase/config.toml
supabase login
supabase link --project-ref <PROJECT_REF>
supabase migration list
supabase db push --dry-run
supabase db push
```

`db push` aplica en orden las cinco migraciones de `supabase/migrations`. No
usar `db reset --linked` en producción: elimina los datos del proyecto remoto.

### 2. Conectar Firebase Auth como Third-Party Auth

1. En Supabase: **Authentication > Third-Party Auth > Firebase**.
2. Registrar el Project ID de Firebase usado por la app.
3. Asignar a los usuarios Firebase el custom claim `role: authenticated` desde
   un backend con Firebase Admin.
4. Después de asignarlo, renovar el ID token (`getIdToken(true)`) o volver a
   iniciar sesión.

Flutter inicializa Supabase con un callback que entrega el Firebase ID token.
Dio añade en cada request:

```text
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

Ante un `401`, el interceptor renueva una vez el token y reintenta una vez. La
secret/service-role key jamás debe compilarse en Flutter.

### 3. Configurar la app

```powershell
Copy-Item apps/bebe_app/config/supabase.dart-defines.example.json `
  apps/bebe_app/config/supabase.local.json
```

Editar el archivo ignorado por Git:

```json
{
  "SUPABASE_URL": "https://PROJECT_REF.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
}
```

Ejecutar:

```powershell
flutter run -d android `
  --dart-define-from-file=apps/bebe_app/config/supabase.local.json
```

En este checkout `supabase.local.json` no existe; es correcto que no se
versione, pero debe crearse en cada entorno de ejecución.

### 4. Verificar RLS y Realtime

Las migraciones agregan a `supabase_realtime`:

```text
register_events, agenda_events, health_events, user_preferences,
families, babies, baby_caregivers, activity_notifications
```

Pruebas manuales mínimas:

1. A y B son cuidadores del mismo bebé; C no lo es.
2. A crea un registro sin red: debe verse `pending` en SQLite.
3. Al volver la red: aparece en Supabase, cambia a `synced` y B lo recibe.
4. C obtiene cero filas/403 para ese bebé.
5. A y B editan el mismo elemento: converge el `updated_at` mayor.
6. Repetir con Agenda, Salud, bebé y Preferencias.
7. Revocar `can_write` de B y confirmar que GET sigue permitido pero escritura
   es rechazada.

### 5. Desplegar notificaciones push

1. En Firebase habilitar FCM HTTP v1 y crear una cuenta de servicio de envío.
2. Generar un secreto aleatorio largo para `ACTIVITY_WEBHOOK_SECRET`.
3. Cargar secretos desde un archivo **no versionado** basado en
   `supabase/functions/.env.example`:

```powershell
supabase secrets set --env-file supabase/functions/.env.local
supabase functions deploy send-activity-notification
```

4. En Supabase crear un Database Webhook:
   - tabla: `public.activity_notifications`;
   - evento: `INSERT`;
   - destino: `https://<PROJECT_REF>.supabase.co/functions/v1/send-activity-notification`;
   - header: `x-webhook-secret: <ACTIVITY_WEBHOOK_SECRET>`.
5. En Android/iOS completar la configuración nativa de Firebase del proyecto.

Flujo resultante:

```text
cambio compartido -> trigger SQL -> activity_notifications
  -> webhook -> Edge Function -> FCM HTTP v1 -> dispositivo
```

La app pide permiso desde la vista de notificaciones, registra el token en
`push_devices`, guarda mensajes de foreground/background en la bandeja local,
combina esa bandeja con el GET de Supabase y usa `notification_id` para no
duplicar el mismo aviso. Al abrir o limpiar, actualiza `read_at`. Al cambiar el
token o cerrar sesión, revoca el token remoto anterior.

Los recordatorios de Agenda son notificaciones locales programadas con canal
de alarma; no crean una fila remota. Se usa programación inexacta para no pedir
permiso de alarma exacta. En Android 13+ e iOS el usuario debe conceder permiso
antes de recibir FCM.

## Checklist de aceptación

- [ ] `supabase db push --dry-run` no informa errores.
- [ ] Las seis migraciones figuran aplicadas en `supabase migration list`.
- [ ] Firebase Third-Party Auth y claim `role: authenticated` funcionan.
- [ ] Registro, Agenda, Salud, Familia y Preferencias convergen en dos equipos.
- [ ] Un usuario ajeno no puede leer ni escribir datos.
- [ ] Una invitación devuelve `family_id` y la fecha de nacimiento reales.
- [ ] Bandeja remota: GET, PATCH individual y PATCH global funcionan.
- [ ] Webhook/Edge Function entrega FCM y deshabilita tokens inválidos.
- [ ] El cierre de sesión elimina el token remoto y los datos locales quedan
      aislados por UID en un SQLite distinto.

### Prueba manual del círculo familiar

1. El usuario A crea un bebé y envía una invitación al correo exacto de B.
2. Si B ya tenía cuenta, recibe una alerta con ruta
   `/invitation?code=<código>`; si aún no tenía cuenta, la alerta se crea al
   registrarse o iniciar sesión por primera vez.
3. El enlace conserva el código al alternar entre Login y Crear cuenta.
4. Con otro correo, `lookup_care_invitation` responde `wrong_account`.
5. B acepta: se crea `baby_caregivers`, se actualiza su perfil y la app descarga
   `families`, `babies`, miembros y perfiles antes de cerrar el loader.
6. A recibe una alerta `care_invitation_accepted` con ruta
   `/family/care-circle` y ve a B como miembro activo.
7. Crear un registro con B y verificar que A lo recibe; deshabilitar escritura y
   confirmar que B mantiene lectura pero ya no puede crear ni actualizar.
8. Repetir con rechazo, reenvío y revocación; cada cambio debe aparecer en la
   bandeja in-app sin duplicados.

## Referencias oficiales

- [Firebase Auth como Third-Party Auth](https://supabase.com/docs/guides/auth/third-party/firebase-auth)
- [Migraciones y `db push`](https://supabase.com/docs/guides/local-development/cli-workflows)
- [Postgres Changes / Realtime](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes)
- [Database Webhooks](https://supabase.com/docs/guides/database/webhooks)
- [Despliegue de Edge Functions](https://supabase.com/docs/guides/functions/deploy)
- [Secretos de Edge Functions](https://supabase.com/docs/guides/functions/secrets)
- [Recepción FCM en Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
- [Envío FCM HTTP v1](https://firebase.google.com/docs/cloud-messaging/send/v1-api)
