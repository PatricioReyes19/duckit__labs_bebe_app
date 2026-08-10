# Core

Contratos de dominio y persistencia local compartidos por las funcionalidades
de Bebé App.

## Capas

- `domain/entities`: objetos de negocio independientes de Flutter y SQLite.
- `domain/repositories`: contratos que consume la capa de aplicación.
- `domain/use_cases`: operaciones que coordinan las reglas del dominio.
- `data/models`: traducción entre entidades y registros persistidos.
- `data/network`: Dio, autenticación por JWT y errores remotos tipados.
- `data/repositories`: implementaciones SQLite de los contratos.
- `data/local`: base de datos, esquema, migraciones y datos iniciales.
- `data/sync`: fuentes Supabase, cola offline-first y coordinación Realtime.

Las vistas consumen modelos de presentación construidos desde entidades. Los
BLoC/Cubit invocan casos de uso y no conocen tablas ni sentencias SQL.

## Persistencia SQLite

El esquema compartido está versionado en `BebeDatabaseSchema` e incluye
familias, bebés, cuidadores, agenda, salud, mediciones, registros diarios y
preferencias. La migración desde la base previa conserva `register_events` y
crea las tablas nuevas de forma idempotente.

Los repositorios exponen las operaciones equivalentes a:

- GET: obtener listados, resúmenes y configuración.
- POST: crear eventos de agenda, salud, familia y registros diarios.
- PATCH: actualizar solo los campos presentes mediante objetos `Patch`.

Los datos de demostración se insertan desde `BebeSeedData`; no están definidos
en widgets ni en BLoC.

## Supabase

Las consultas remotas pasan por `SupabaseRestClient`; los modelos implementan
`fromEntity`, serialización local y JSON remoto. `supabase_flutter` se reserva
para la inicialización y Realtime. Firebase Auth entrega el JWT bajo demanda:
core nunca persiste tokens en SQLite.

La guía completa de configuración, RLS, círculos de cuidado y alertas está en
`docs/supabase_register_sync.md`.
