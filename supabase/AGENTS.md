# BEBÉAPP — SUPABASE AGENT RULES

**Scope:** `supabase/**`  
**Extiende:** `/AGENTS.md`

Estas reglas gobiernan migraciones, RLS, funciones, queries y tests de base de datos.

---

## 1. Estructura

El proyecto contiene:

```text
supabase/
├── config.toml
├── migrations/
├── functions/
└── tests/
```

Preservar esta estructura.

---

## 2. Migraciones

Todo cambio de schema/RLS/index/function persistente debe quedar trazado mediante migración.

MUST:

- crear una migración nueva;
- usar timestamp/version coherente con el historial;
- mantener migraciones idempotentes cuando el patrón lo permita;
- revisar dependencias entre objetos;
- documentar cambios destructivos.

MUST NOT:

- reescribir silenciosamente una migración remota ya aplicada;
- borrar historial para “arreglar” divergencia;
- usar `migration repair` como reemplazo de entender el estado local/remoto;
- hacer cambios destructivos sin indicar impacto.

---

## 3. Historial local/remoto

Antes de push/repair:

1. `supabase migration list --linked`;
2. comparar Local vs Remote;
3. identificar versiones faltantes o divergentes;
4. decidir si corresponde fetch/pull/repair;
5. no marcar `reverted/applied` sin comprender el historial real.

Un estado “Remote database is up to date” no elimina la necesidad de revisar drift si el historial no coincide.

---

## 4. Foreign Keys

Toda FK nueva/modificada debe revisar:

- tipo de columnas;
- orden de inserción/sync;
- `ON DELETE`;
- `ON UPDATE`;
- offline IDs;
- relaciones baby/caregiver/family;
- impacto sobre datos existentes.

No resolver `FOREIGN KEY constraint failed` deshabilitando constraints.

Corregir el orden/datos/modelo de sync.

---

## 5. RLS

RLS es autoridad de autorización remota.

Toda tabla con datos de usuario/bebé/círculo debe evaluarse para RLS.

Policies deben contemplar contexto correcto de membresía.

MUST NOT:

- confiar solo en checks cliente;
- deshabilitar RLS para solucionar UI;
- usar service role desde la app móvil;
- conceder escritura por una etiqueta visual de rol;
- asumir un rol global cuando el permiso es por círculo/bebé.

---

## 6. Invitaciones y permisos

La aceptación de invitación debe respetar los permisos otorgados.

Campos de relación/acceso deben ser consistentes con la membresía creada.

Si existe `can_write = false`, ninguna policy debe permitir escritura solo por pertenecer al círculo.

La UI puede ocultar acciones, pero la BD debe impedirlas igualmente.

---

## 7. Índices

Agregar índices guiados por queries reales.

Revisar especialmente:

- `baby_id`;
- `caregiver_id`;
- `family/circle_id`;
- timestamps de historial;
- status;
- próximas fechas de agenda;
- columnas usadas en joins/policies;
- filtros combinados frecuentes.

No agregar índices indiscriminadamente: cada índice tiene costo de write/storage.

Para índices compuestos, ordenar columnas de acuerdo con filtros/ordenamiento reales.

---

## 8. Query performance

Evitar:

- `select *` cuando no es necesario;
- rangos ilimitados;
- N+1;
- subqueries RLS costosas por fila cuando pueden simplificarse;
- funciones volátiles innecesarias;
- materializar recurrencias futuras ilimitadas.

Preferir filtros por baby/contexto, date ranges, paginación, índices adecuados y vistas/materialized views solo cuando el patrón de lectura lo justifique.

---

## 9. Materialized Views

No crear una materialized view automáticamente para “mejorar performance”.

Antes debe existir:

- query costosa y repetitiva;
- patrón de lectura claro;
- estrategia de refresh;
- tolerancia a datos no instantáneos;
- medición/EXPLAIN que justifique la decisión.

Reportes agregados 1/7/30 días pueden ser candidatos, pero requieren evidencia.

---

## 10. EXPLAIN / medición

Antes y después de una optimización relevante:

```sql
EXPLAIN (ANALYZE, BUFFERS)
...
```

cuando sea seguro en el entorno disponible.

Documentar plan, rows, scans, indexes, tiempo relativo y cambio aplicado.

No declarar una query “optimizada” solo porque se añadió un índice.

---

## 11. Functions / Edge Functions

No mover lógica de dominio al servidor sin necesidad.

Edge Functions deben validar auth/input, limitar privilegios, no exponer secrets, manejar errores y mantener contratos versionables.

Service role solo en backend seguro cuando realmente corresponda.

---

## 12. Seguridad

Nunca commitear service-role key, JWT privado, passwords, secrets ni credenciales de producción.

Usar secrets/configuración del entorno.

No loggear tokens o payloads sensibles completos.

---

## 13. Tests de BD

Cambios de RLS deben probar al menos:

- usuario autorizado;
- usuario no autorizado;
- read;
- write cuando corresponda;
- miembro readonly;
- aislamiento entre bebés/círculos;
- invitación/aceptación cuando aplique.

Cambios de migración deben revisar que schema final sea consistente.

---

## 14. Offline-first y sync

El schema remoto debe ser compatible con sincronización local.

Considerar IDs, timestamps, idempotencia, reintentos, orden de escritura, foreign keys, conflictos y registros creados offline.

No diseñar constraints incompatibles con el orden de sync sin adaptar el cliente.

---

## 15. Definition of Done — Supabase

- [ ] nueva migración creada cuando corresponde;
- [ ] historial local/remoto no fue alterado sin análisis;
- [ ] RLS revisada;
- [ ] permisos readonly/write verificados;
- [ ] foreign keys revisadas;
- [ ] índices justificados;
- [ ] performance medida si aplica;
- [ ] tests SQL/RLS relevantes ejecutados;
- [ ] no hay secrets;
- [ ] impacto offline/sync revisado.
