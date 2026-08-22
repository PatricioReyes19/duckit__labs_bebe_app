# BEBÉAPP — CORE AGENT RULES

**Scope:** `packages/core/**`  
**Extiende:** `/AGENTS.md`

`core` concentra dominio, datos, sincronización y abstracciones transversales.

---

## 1. Estructura

Respetar la separación existente:

```text
lib/src/
├── domain/
├── data/
├── bloc/      # solo responsabilidades compartidas/transversales
├── config/
└── utils/
```

No convertir `core` en un depósito genérico.

---

## 2. Domain

Domain contiene contratos y conceptos del negocio.

Puede contener entities, value objects, repository contracts, use cases, domain policies, failures y abstracciones de servicio cuando son dominio real.

MUST NOT conocer Supabase concreto, SQLite concreto, Dio/Retrofit, widgets, GoRouter, páginas ni DTOs específicos de transporte.

---

## 3. Data

Data implementa detalles de persistencia/transporte.

Puede contener DTO/model, local model, remote model, datasource, repository implementation, mapper y sync implementation.

Los modelos data no deben escapar como contrato público hacia presentación.

---

## 4. Mappers

Mantener mapping explícito.

```text
Remote Model → Domain Entity
Local Model  → Domain Entity
Domain Entity → Persistence Model
```

No insertar conversiones dispersas dentro de widgets/BLoCs.

No perder campos semánticos que afectan permisos o comportamiento.

---

## 5. Repositories

El contrato pertenece al dominio cuando expresa una capacidad del negocio.

La implementación pertenece a data.

Un repository debe esconder la fuente concreta.

No crear un repository por cada llamada HTTP si no existe una frontera de dominio real.

---

## 6. Use cases

Use cases expresan operaciones del dominio/aplicación.

Deben recibir dependencias inyectadas, ser testeables, evitar BuildContext y evitar detalles de UI.

No crear use cases triviales sin valor si el patrón del dominio correspondiente no los usa.

Seguir consistencia del módulo existente.

---

## 7. Offline-first

Todo repository que maneje información persistente debe evaluar estrategia local/remota.

Principios:

- local data puede ser fuente inmediata para UI;
- writes locales no deben perderse por fallo de red;
- sync debe ser observable/reintentable;
- fallos remotos no deben destruir estado válido;
- reconciliación debe preservar identidad y relaciones;
- considerar reinicio de aplicación.

No asumir “network-first” por defecto.

---

## 8. Identidad y contexto activo

Al restaurar sesión/contexto:

- no confundir ausencia local temporal con ausencia remota;
- preservar relación usuario ↔ círculo ↔ bebé;
- considerar múltiples bebés;
- considerar múltiples círculos/membresías;
- evitar recrear perfiles existentes;
- restaurar contexto antes de enviar al usuario a onboarding cuando sea posible.

---

## 9. Care Circle / Invitaciones

Los permisos no son un string decorativo.

Cualquier DTO/model de invitación debe preservar los campos de autorización/relación disponibles.

Si remote entrega:

```text
relationship
access_description
can_write
```

no descartar esos datos en capas intermedias.

No sustituirlos por etiquetas fijas si no corresponden al permiso real.

RLS sigue siendo autoridad final.

---

## 10. Recurrencias

No materializar series recurrentes como listas futuras ilimitadas sin una razón de dominio.

Separar cuando aplique:

- definición de serie;
- próxima ocurrencia;
- historial de ocurrencias reales;
- proyección limitada.

La UI de “Programadas” debe poder representar una serie con una sola card y una próxima ejecución actualizable.

---

## 11. Performance

En repositorios/queries:

- limitar columnas cuando aplique;
- limitar rangos;
- evitar cargar historial completo;
- evitar N+1;
- aprovechar índices definidos;
- no recalcular grandes proyecciones innecesariamente;
- usar cache/local DB cuando forme parte de la estrategia vigente.

No optimizar eliminando checks de autorización.

---

## 12. BLoC en core

`core/lib/src/bloc` se reserva para estado realmente transversal/compartido.

BLoC exclusivo de un feature pertenece al feature.

No mover un BLoC a core solo para “poder importarlo”.

---

## 13. Errores

Modelar fallos útiles para consumidores.

No obligar a UI a parsear strings de excepción para descubrir semántica cuando exista posibilidad de un failure tipado.

No exponer detalles SQL/HTTP innecesarios.

---

## 14. Tests

Cambios en domain/data deberían cubrir según corresponda mapper tests, repository tests, use case tests, sync tests, serialization/model tests y regression tests.

Mockear fronteras, no el comportamiento que se quiere comprobar.

---

## 15. Definition of Done — Core

- [ ] domain no conoce infraestructura concreta;
- [ ] data no filtra DTOs a presentación;
- [ ] mappings completos;
- [ ] offline-first evaluado;
- [ ] permisos preservados end-to-end;
- [ ] no se duplicó lógica de dominio;
- [ ] tests relevantes ejecutados;
- [ ] analyzer revisado;
- [ ] generated code regenerado cuando aplica.
