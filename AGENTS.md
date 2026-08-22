# BEBÉAPP — AGENT DEVELOPMENT RULES

**Versión:** 1.0  
**Estado:** OBLIGATORIO  
**Scope:** todo el repositorio

Este archivo define las reglas permanentes de desarrollo de BebéApp para Codex y otros agentes de código. Estas reglas **no son sugerencias**.

El objetivo es evitar deriva arquitectónica y reducir consultas sobre decisiones que ya están cerradas.

---

## 1. Orden de autoridad

Ante una tarea, aplicar este orden:

1. instrucción explícita actual del usuario;
2. SDD / BDD aprobado de la tarea;
3. `AGENTS.md` más específico aplicable al directorio;
4. este `AGENTS.md` raíz;
5. código existente y tests del mismo contexto;
6. documentación arquitectónica vigente.

Si dos reglas entran en conflicto, prevalece la de mayor prioridad.

Un BDD/SDD puede cambiar comportamiento funcional, pero **no modifica automáticamente la arquitectura permanente** salvo que lo indique de forma explícita.

---

### Inheritance rule

A more specific `AGENTS.md` may specialize or tighten the root rules,
but MUST NOT silently weaken or contradict repository-wide architectural,
security, privacy, quality, or data-integrity constraints.

Any intentional exception to a root invariant requires an explicit
SDD/BDD architectural decision.

---

## 2. Regla de operación

BebéApp sigue esta distribución general de responsabilidades:

- `apps/bebe_app`: ejecutable y bootstrap de plataforma.
- `packages/app_base`: composition root, router, DI e integraciones globales.
- `packages/app_layout`: shell visual global y navegación estructural.
- `packages/core`: dominio, datos, sincronización y abstracciones compartidas.
- `packages/design_system`: sistema visual reutilizable.
- paquetes feature: presentación y coordinación propia del feature.
- `packages/splash`: máquina de estados del arranque funcional.
- `supabase`: persistencia remota, RLS, migraciones, funciones y pruebas de BD.

No rediseñar esta arquitectura por preferencia personal.

---

## 3. Architecture Decision Gate

La arquitectura se considera **CERRADA** salvo que la tarea pida explícitamente modificarla.

Antes de preguntar al usuario por arquitectura, el agente debe:

1. leer los `AGENTS.md` aplicables;
2. revisar el código equivalente más cercano;
3. revisar tests existentes;
4. revisar contratos públicos y `pubspec.yaml`;
5. buscar patrones ya utilizados en el repositorio.

### NO preguntar

No preguntar cosas como:

- “¿Dónde debería poner este componente?”
- “¿Debería ser atom o molecule?”
- “¿Esto va en core?”
- “¿Splash debería navegar directamente?”
- “¿Uso Supabase desde la vista?”
- “¿Creo otro componente parecido?”
- “¿Creo otra capa?”
- “¿Creo otra ruta global?”

si la respuesta puede deducirse de las reglas o del repositorio.

### Solo escalar al usuario si

- se propone un paquete nuevo;
- cambia ownership entre paquetes;
- aparece una nueva dependencia cross-package no establecida;
- se rompe una API pública;
- se modifica de forma material el modelo de persistencia;
- se requiere una migración destructiva;
- cambia semántica de RLS/autorización;
- existe conflicto real entre reglas;
- se introduce un patrón arquitectónico nuevo;
- existe una consecuencia importante de seguridad o privacidad.

Ante ambigüedad de bajo riesgo: seguir el patrón existente, implementar y documentar la suposición al final.

---

## 4. Ownership por paquete

### `apps/bebe_app`

Responsabilidades: `main`, bootstrap Flutter/plataforma, configuración nativa, flavors, splash nativo y ensamblado inicial.

MUST NOT convertirse en contenedor de lógica de negocio.

### `packages/app_base`

Es el **composition root**.

Responsabilidades: `MaterialApp.router`, GoRouter, rutas concretas, traducción de destinos semánticos, DI, observers, analytics global, lifecycle, Firebase/Crashlytics, FCM, app links y composición entre features.

Las rutas concretas globales pertenecen aquí.

### `packages/app_layout`

Responsabilidades: ShellRoute/StatefulShellRoute, header global, bottom navigation, FAB y chrome de aplicación.

MUST NOT contener reglas de negocio.

### `packages/core`

Responsabilidades: entidades de dominio, contratos de repositorio, use cases, modelos/DTO, mappers, datasources, persistencia local/remota, sincronización, políticas transversales y BLoC compartido solo cuando su responsabilidad sea realmente transversal.

MUST NOT contener widgets de feature.

### `packages/design_system`

Responsabilidades: tokens/foundations, themes, atoms, molecules, organisms, templates, layout primitives, componentes visuales reutilizables e infraestructura visual transversal como theme state.

MUST NOT contener lógica de negocio de features.

### Paquetes feature

Ejemplos: `home`, `agenda`, `health`, `register`, `family`, `login`, `signup`, `onboarding`, `notifications`.

Responsabilidades principales: páginas, conexión de estado, BLoC/controller de feature, coordinación de interacción y adaptación visual del dominio.

No duplicar dominio que ya pertenece a `core`.

Evitar dependencias feature → feature salvo dependencia ya establecida y justificada.

---

## 5. Dirección de dependencias

Preservar un grafo acíclico.

```text
apps/bebe_app
      ↓
   app_base
      ↓
features / app_layout
      ↓
core + design_system
```

Reglas:

- `core` MUST NOT depender de features.
- `design_system` MUST NOT depender de features.
- negocio MUST NOT depender de presentación.
- una vista MUST NOT acceder directamente a Supabase/SQLite/Dio/Retrofit.
- no agregar dependencias a `pubspec.yaml` sin revisar antes si ya existe una abstracción o dependencia equivalente.

Las excepciones legacy no autorizan nuevas dependencias incorrectas.

---

## 6. Clean Architecture

Flujo preferido:

```text
UI
→ BLoC / controller
→ use case
→ repository contract
→ repository implementation
→ datasource
→ local / remote
```

No saltar capas solo para reducir cantidad de archivos.

Cuando una operación sea trivial, reutilizar patrones existentes; no crear capas sin responsabilidad real.

---

## 7. Domain / Data

Los detalles de transporte o almacenamiento no deben filtrarse a la presentación.

```text
Remote / Local Model
→ Mapper
→ Domain Entity
```

- DTOs no son entidades de dominio.
- filas SQLite no son contratos de UI.
- respuestas Supabase no deben llegar directamente a widgets.
- entidades de dominio deben evitar detalles específicos de Supabase/SQLite.
- conversiones explícitas y testeables.

---

## 8. Atomic Design obligatorio

Antes de crear cualquier UI reutilizable:

1. buscar en `packages/design_system`;
2. verificar atoms;
3. verificar molecules;
4. verificar organisms;
5. verificar templates;
6. extender/componer un componente existente si la semántica coincide;
7. crear uno nuevo solo cuando no exista un equivalente correcto.

MUST NOT duplicar componentes visualmente equivalentes.

Clasificación por **responsabilidad**, no por tamaño de archivo.

### Foundation / Token

Decisión visual primitiva: color, typography, spacing, radius, elevation, stroke, theme.

### Atom

Primitiva visual pequeña y altamente reutilizable. No contiene negocio, repositorios ni navegación global.

### Molecule

Composición pequeña y reutilizable de atoms. Expone props/callbacks. No decide negocio.

### Organism

Sección visual significativa y reutilizable. Compone atoms/molecules; no consulta datos.

### Template

Define composición y layout de una vista. Organiza UI y responsive; no ejecuta negocio ni datasources.

La página/feature conecta estado y comportamiento con el template cuando corresponde.

---

## 9. Design System y tokens

Usar tokens existentes antes de introducir constantes visuales.

Aplican a colores, tipografía, spacing, border radius, elevation, stroke y themes.

No hardcodear valores visuales equivalentes a un token existente.

La iconografía puede definirse por componente según las convenciones vigentes de BebéApp.

---

## 10. Width, layout y responsive

El ancho normalmente lo controla el padre.

Para componentes fluidos preferir restricciones del layout y, cuando corresponda:

```dart
width: double.infinity
```

Evitar anchos fijos salvo elementos intrínsecos como iconos, avatares, botones circulares, assets expresamente acotados o límites de accesibilidad.

Toda modificación UI debe considerar pantallas pequeñas/grandes, text scaling, overflow, SafeArea, teclado y diferencias Android/iOS.

No solucionar bugs de un dispositivo con magic numbers específicos de marca/modelo. Corregir la restricción de layout.

---

## 11. Accesibilidad

Objetivo: WCAG AA cuando aplique.

Revisar contraste, legibilidad, touch targets, Semantics/labels, disabled, loading, empty, error, text scaling y overflow.

No degradar accesibilidad para copiar un mockup.

---

## 12. State management

Seguir BLoC + Freezed/Equatable conforme al patrón existente.

MUST NOT introducir otro framework global de estado sin decisión arquitectónica explícita.

- widgets no ejecutan datasources;
- BLoC coordina mediante abstracciones/use cases;
- side effects explícitos y testeables;
- `BuildContext` debe respetar lifecycle/build.

---

## 13. Startup / Splash

Existen dos conceptos distintos:

1. splash nativo visual/técnico;
2. splash Flutter funcional.

`packages/splash` es dueño de la máquina de estados del arranque y de destinos **semánticos** como `login`, `signUp`, `onboarding`, `home`, `invitation` o selección de contexto/bebé.

`packages/splash` MUST NOT conocer strings concretos de GoRouter.

`app_base` traduce destinos semánticos a rutas concretas.

No agregar un splash intermedio adicional entre el nativo y el splash funcional salvo instrucción explícita.

---

## 14. Onboarding

El onboarding NO se asume como wizard lineal.

El arranque debe considerar cuando aplique: sesión activa, sesión inexistente/expirada, onboarding incompleto, invitación pendiente, círculo de cuidado, bebé activo, multi-bebé, multi-cuidador y restauración local/remota.

No recrear entidades porque falte temporalmente estado local si existe posibilidad válida de restaurarlas desde persistencia/sync.

---

## 15. Care Circle y permisos

Los roles/permisos son contextuales a membresía/círculo/bebé, no un rol global único.

El servidor/RLS es autoridad de autorización.

La UI MUST NOT prometer permisos que el servidor no concedió.

Si una invitación entrega `relationship`, `access_description` y `can_write`, la semántica debe conservarse a través de DTO/model/domain/local storage.

No reemplazar permisos remotos por textos o roles fijos.

---

## 16. Offline-first

BebéApp es offline-first.

Todo flujo de datos nuevo debe evaluar lectura local, escritura local, sync remoto, retry, fallo de sincronización, reconciliación, pérdida de conectividad y consistencia eventual.

La UI no debe bloquearse innecesariamente por red cuando existen datos locales válidos.

Fallo de sincronización ≠ falta de conectividad.

Nunca eliminar silenciosamente datos locales válidos por un fallo remoto.

---

## 17. Supabase / autorización

La UI nunca consulta Supabase directamente.

Client-side permission checks son UX, no seguridad.

RLS debe seguir siendo autoridad para acceso remoto.

Para cambios de BD: nueva migración, preservar historial, revisar foreign keys, índices, RLS, costo de queries y escenarios multiusuario/multibebé.

Una mejora de performance MUST NOT debilitar seguridad.

---

## 18. Performance

Evitar queries sin límites, historiales completos innecesarios, N+1, llamadas repetidas, rebuilds masivos, proyecciones duplicadas, listas infinitas de recurrencias y cálculos pesados en `build`.

Los eventos recurrentes deben modelarse/proyectarse como **serie** cuando la UX representa una recurrencia. No generar miles de cards futuras.

---

## 19. Navegación

Routing global pertenece a `app_base`.

Features pueden emitir intención/destino semántico.

No distribuir strings de rutas globales por múltiples paquetes.

Las páginas raíz del shell deben respetar el comportamiento de header/back aprobado.

---

## 20. Manejo de errores

No silenciar excepciones.

Diferenciar cuando aplique validación, dominio, red, autorización, sincronización, persistencia y error técnico inesperado.

No exponer stack traces, SQL, tokens, claves o detalles internos sensibles al usuario.

---

## 21. Seguridad y privacidad

MUST NOT hardcodear passwords, service-role keys, API secrets ni tokens privados.

MUST NOT loggear auth tokens, credenciales ni datos sensibles innecesarios de bebé/cuidador.

No usar service role dentro de la app móvil.

No deshabilitar RLS para solucionar un bug cliente.

---

## 22. Código generado

No editar manualmente archivos generados por Freezed, Retrofit, Injectable, JSON serialization u otros generators.

Modificar la fuente y regenerar.

Comando workspace disponible:

```bash
melos run build_runner
```

Usar el generator solo en paquetes afectados cuando sea posible.

---

## 23. Reutilización y búsqueda previa

Antes de crear component, mapper, repository, use case, helper, extension, formatter o datasource, buscar equivalentes en el repo.

Preferir composición/extensión cuando la semántica coincide.

No crear abstracciones que solo reenvían una llamada sin aportar frontera, testabilidad o semántica.

---

## 24. Contrato SDD / BDD

Si la tarea referencia un SDD o BebéApp Development Diff:

**EL SDD/BDD ES EL CONTRATO DE IMPLEMENTACIÓN DE ESA TAREA.**

- implementar el scope aprobado;
- no agregar funcionalidades comerciales hipotéticas;
- no mezclar refactors no relacionados;
- mantener trazabilidad con incidencia/BDD;
- trabajo adicional solo si es indispensable para compilar/corregir/testear;
- hallazgos fuera de scope se reportan como follow-up.

---

## 25. Política de bug fix

Un bug fix debería incorporar un test de regresión cuando sea técnicamente razonable.

MUST NOT borrar asserts, cambiar un test correcto para justificar el bug, usar `skip` para ocultar regresiones ni mockear el comportamiento que se necesita verificar.

Verificar side effects relevantes: persistencia, sync, analytics, navegación semántica, event emitters, etc.

---

## 26. Validación y comandos

El workspace actual expone:

```bash
melos bs
melos run analyze
melos run build_runner
melos run run:app
melos run run:app:android
melos run run:app:ios
```

Para paquetes Flutter afectados, ejecutar según corresponda:

```bash
dart format .
flutter test
dart analyze .
```

Para paquetes Dart puros, adaptar a `dart test`.

### Importante

El `makefile` puede contener aliases históricos que no coinciden con scripts Melos actuales. No asumir que un alias existe: verificar primero `pubspec.yaml`.

No afirmar que un comando/test pasó si no fue ejecutado. Si no puede ejecutarse, informar el motivo exacto.

---

## 27. Scope de cambios

Implementar el cambio coherente más pequeño.

No renombrar APIs públicas por gusto, mover archivos solo por preferencia, refactorizar un módulo completo por un bug local, cambiar convenciones sin necesidad ni introducir paquetes “por si acaso”.

Consistencia > preferencia personal.

---

## 28. Legacy

El código legacy que incumple una regla no autoriza nuevas violaciones.

Al tocar legacy: preservar scope, mejorar la zona afectada si es seguro, no convertir la tarea en migración masiva y reportar deuda relevante aparte.

---

## 29. Definition of Done

### Arquitectura

- ownership correcto;
- dependencias respetadas;
- no duplicación;
- no acceso directo UI → data source.

### UI

- Design System reutilizado;
- clasificación Atomic correcta;
- tokens usados;
- responsive revisado;
- accesibilidad considerada.

### Datos

- offline-first preservado;
- permisos preservados;
- RLS no debilitada;
- sincronización considerada.

### Calidad

- código formateado;
- analyzer revisado;
- tests relevantes ejecutados;
- código generado actualizado si aplica.

### Scope

- requisito implementado;
- no se alteró funcionalidad ajena;
- follow-ups separados.

---

## 30. Reporte final del agente

Toda implementación debe terminar con un resumen corto:

### Implementado

Qué cambió.

### Arquitectura

Qué patrón existente se respetó.

### Validación

Comandos/tests ejecutados y resultado real.

### Riesgos / Follow-ups

Solo asuntos relevantes no resueltos.

No producir ensayos arquitectónicos salvo que el usuario los pida.

---

## 31. Regla de oro

Cuando exista elección entre inventar un patrón nuevo y reutilizar el patrón BebéApp existente, **reutilizar el existente**.

Cuando exista elección entre volver a preguntar una decisión ya documentada y aplicar la regla vigente, **aplicar la regla vigente**.
