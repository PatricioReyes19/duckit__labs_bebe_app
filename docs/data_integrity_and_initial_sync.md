# Integridad Baby-first y sincronización inicial

El agregado central es `Baby`. La identidad pública vive en `profiles` y la
autorización multi-cuidador continúa viviendo en `baby_caregivers` mediante
`can_access_baby(...)`.

El cold start autenticado debe respetar este orden:

1. sincronizar el perfil Firebase restaurado;
2. hidratar Family y Babies;
3. sincronizar Register, Agenda, Health y preferencias, en ese orden;
4. reconciliar Register → Agenda;
5. activar el listener local;
6. iniciar Realtime.

Los callbacks Realtime usan la misma cola. Todo callback Baby-owned vuelve a
pasar por Family como barrera; un evento omitido por faltar su Baby converge al
recibirse posteriormente un cambio de Family/Baby.

## Semántica pendiente de `caregiver_id`

No se agregó una FK remota para `caregiver_id`. En SQLite, Agenda y Health lo
relacionan con `family_members.id`; la representación remota de membresía usa
la clave compuesta `baby_caregivers(baby_id, user_id)`, donde `user_id` es el
Firebase UID. Algunas entradas de UI históricas también usan etiquetas de rol.

Antes de agregar una FK hay que elegir y migrar una identidad canónica. La
opción recomendada es conservar por separado el actor histórico (Firebase UID)
y, si se necesita, la membresía contextual. No se deben enlazar los valores
actuales automáticamente a `profiles`, porque eso puede falsear trazabilidad.

## Aplicación de la migración remota

La migración `20260812153549_connect_core_relations_and_harden_sync.sql` aborta
si encuentra Babies o fuentes Register huérfanas. Los IDs de usuario válidos y
ya referenciados reciben únicamente un perfil mínimo; no se borra ninguna fila.

Antes de desplegar, con Docker/Podman disponible:

```bash
supabase db reset
supabase test db supabase/tests/database
supabase db lint --local --level warning
supabase db push --dry-run
```

El último comando debe permanecer en modo `--dry-run` durante la revisión. No
se debe ejecutar un push real automáticamente.
