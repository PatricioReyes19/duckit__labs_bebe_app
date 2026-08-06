# auth

Dueño de la lógica de acceso de BebéApp. `login` y `signup` consumen
`AuthService`; ninguna pantalla conoce Firebase.

Para conectar Firebase se implementa `AuthGateway` con `firebase_auth`, se
traducen sus errores a `AuthFailure` y se reemplaza `LocalAuthGateway` en la
composición de `app_base`. No es necesario modificar los BLoCs ni las vistas.
