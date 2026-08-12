# Entornos y flavors de BebéApp

## Fuente única

La configuración compilable de desarrollo vive en:

```text
apps/bebe_app/config/development.env.json
```

`AppEnvironment`, dentro de `packages/core`, es el único punto desde el que el
código Dart debe leer esas variables. No usar `String.fromEnvironment`
directamente en features, datasources o widgets.

Variables actuales:

| Variable | Uso |
|---|---|
| `APP_ENVIRONMENT` | Identifica el entorno y se valida contra el flavor nativo. |
| `APP_DISPLAY_NAME` | Nombre visible dentro de Flutter y en Android. |
| `SUPABASE_URL` | URL de Data API, RPC, Storage y Realtime. |
| `SUPABASE_PUBLISHABLE_KEY` | Clave pública que puede compilarse en el cliente. |
| `INVITATION_BASE_URL` | Base de los enlaces que se comparten desde Familia. |
| `ENABLE_VERBOSE_LOGS` | Habilita diagnósticos propios del entorno. |

No agregar a este JSON contraseñas, JWT, refresh tokens, claves privadas de
Firebase ni la `service_role` de Supabase. Esos secretos pertenecen al backend
o al almacén de secretos del pipeline.

## Ejecutar development

Desde `apps/bebe_app`:

```powershell
flutter run --flavor development `
  --dart-define-from-file=config/development.env.json
```

Desde la raíz también se puede usar:

```powershell
melos run run:app
melos run run:app:android
melos run run:app:ios
```

Antigravity puede abrir la raíz o `duckit-bebe-app.code-workspace`. Las
configuraciones de lanzamiento ya pasan el flavor y el archivo de variables al
Flutter tool; basta seleccionar **BebéApp development**, **BebéApp Android** o
**BebéApp iOS**.

## Configuración nativa

- Android define la dimensión `environment`, el product flavor `development`
  y lee el nombre de aplicación desde el mismo JSON durante Gradle.
- iOS dispone del scheme compartido `development` y configuraciones
  `Debug-development`, `Profile-development` y `Release-development`.
- El arranque compara el flavor nativo con `APP_ENVIRONMENT`; si no coinciden,
  muestra el error de bootstrap en vez de conectarse al backend equivocado.

El flavor conserva por ahora los identificadores nativos existentes. Firebase
Android solo contiene un cliente para `com.duckitlabs.bebeapp` y no existe en
el repositorio un `GoogleService-Info.plist` de desarrollo. Para instalar
development junto a producción se deben registrar primero ambas apps Firebase,
descargar sus archivos nativos y entonces asignar sufijos de application/bundle
ID.

## Agregar otro entorno

1. Crear `staging.env.json` o `production.env.json` con el mismo contrato.
2. Agregar el product flavor Android y un scheme/configuraciones iOS del mismo
   nombre.
3. Registrar los application IDs/bundle IDs correspondientes en Firebase.
4. Crear una configuración de lanzamiento que pase `--flavor` y
   `--dart-define-from-file` con el mismo nombre.
5. Ejecutar los tests de `core` y compilar al menos una variante nativa.
