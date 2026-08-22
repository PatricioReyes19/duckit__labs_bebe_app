# BEBÉAPP — DESIGN SYSTEM AGENT RULES

**Scope:** `packages/design_system/**`  
**Extiende:** `/AGENTS.md`

Estas reglas gobiernan cualquier cambio dentro del Design System.

---

## 1. Propósito

Este paquete contiene UI reutilizable y lenguaje visual transversal.

La estructura existente incluye:

```text
design_system/
├── atoms/
├── molecules/
├── organisms/
├── templates/
├── layout/
├── tokens/
├── themes/
└── bloc/        # infraestructura visual transversal, p. ej. theme
```

Atomic Design es obligatorio.

---

## 2. Gate previo a crear un componente

Antes de crear un componente nuevo:

1. buscar por nombre;
2. buscar por semántica;
3. revisar atoms;
4. revisar molecules;
5. revisar organisms;
6. revisar templates;
7. revisar si composición/variantes de uno existente solucionan el caso.

Crear duplicados visuales o semánticos está prohibido.

No crear un componente solo porque el feature necesita una variante de color/copy si esa diferencia puede expresarse mediante props/tokens.

---

## 3. Clasificación Atomic

### Atom

Usar cuando es una primitiva UI, tiene responsabilidad visual única, no depende de componentes complejos y es altamente reusable.

### Molecule

Usar cuando combina atoms y representa una interacción/unidad visual pequeña reusable transversalmente.

### Organism

Usar cuando compone varias molecules/atoms y representa una sección completa con estructura visual significativa.

### Template

Usar cuando define composición global de una vista, organiza secciones, define responsive/layout, recibe datos/estado ya preparado y no consulta repositorios.

Clasificar por responsabilidad, no por cantidad de líneas.

---

## 4. Prohibiciones de dependencia

MUST NOT importar lógica de feature.

MUST NOT acceder a:

- Supabase;
- SQLite;
- Dio;
- Retrofit;
- repositories;
- use cases;
- router global;
- páginas de features.

El `bloc` existente del Design System se limita a infraestructura visual transversal, por ejemplo theme. No introducir BLoC de negocio o de feature.

---

## 5. Props y callbacks

Un componente reusable recibe datos y emite intención.

Correcto:

```dart
onPressed
onChanged
onRetry
isLoading
isEnabled
title
supportText
status
```

Incorrecto:

- decidir si un cuidador tiene permiso;
- validar RLS;
- consultar invitaciones;
- resolver navegación global;
- cargar medicamentos desde repository;
- decidir el siguiente paso de onboarding.

La decisión de negocio vive fuera del Design System.

---

## 6. Naming

Los nombres deben describir función visual/interacción reusable.

Evitar nombres excesivamente específicos del dominio cuando el componente es genérico.

```text
BabyMedicationBlueCard     ❌
ScheduleStatusCard         ✅
InformationCard            ✅
CaregiverPermissionCard    ✅ solo si la semántica visual realmente es exclusiva y reusable
```

No abstraer de más: un nombre genérico no justifica un componente sin reusabilidad real.

---

## 7. Tokens

Antes de usar un literal visual, buscar token existente.

Usar tokens para:

- colors;
- typography;
- spacing;
- border radius;
- elevation;
- stroke;
- theme values.

No duplicar colores con nuevos `Color(...)` si ya existe token equivalente.

No crear nuevos tokens por un solo componente sin justificar que representan una decisión de sistema.

La iconografía se define según la convención vigente y puede ser específica por componente.

---

## 8. Width y constraints

El ancho total normalmente pertenece al parent/template.

Reusable components deben ser fluidos.

Preferir:

```dart
double.infinity
```

cuando el contrato visual es “ocupa el ancho disponible”.

Evitar `width: 320`, `width: 360`, etc. salvo que el asset/elemento sea intrínsecamente fijo.

No usar magic numbers para resolver Samsung/iPhone específico. Resolver constraints.

---

## 9. Responsive

Todo componente nuevo/modificado debe evaluarse para:

- 320–360dp de ancho;
- pantallas grandes;
- text scaling;
- textos largos;
- localization futura;
- overflow;
- landscape si el componente puede aparecer allí;
- SafeArea cuando sea responsabilidad del layout.

Usar `Flexible`, `Expanded`, `Wrap` y constraints cuando corresponda.

No ocultar información importante arbitrariamente con `maxLines`.

---

## 10. Estados visuales

Cuando sean parte del contrato, modelar explícitamente:

- normal;
- loading;
- disabled;
- empty;
- error;
- selected;
- pressed/focused cuando aplique.

No convertir errores de negocio en responsabilidad interna del componente.

---

## 11. Accesibilidad

Objetivo WCAG AA.

Revisar contraste, touch target, semantics, text scaling, lectura por screen reader, estado disabled distinguible e icon-only actions con label.

No depender exclusivamente de color para comunicar estado importante.

---

## 12. Templates y páginas

El Design System puede contener templates reutilizables.

La conexión con BLoC/repository/use cases debe quedar en el feature.

```text
Feature Page
  ↓ state + callbacks
Design System Template
  ↓
Organisms
  ↓
Molecules
  ↓
Atoms
```

No mover pages de negocio al Design System solo para compartir layout.

---

## 13. Assets

Reutilizar assets y mecanismos existentes.

Cuando un componente soporte asset local o URL remota, no mezclar heurísticas ad-hoc en múltiples widgets. Reutilizar/centralizar la resolución vigente.

No agregar dependencias de packages de features para acceder a assets.

---

## 14. Tests

Agregar/actualizar widget tests cuando:

- cambia comportamiento;
- se crea un estado;
- se corrige overflow;
- se agrega interacción;
- se agrega resolución de asset/URL;
- se corrige un bug.

Tests deben verificar comportamiento/semántica, no detalles frágiles de implementación cuando no son parte del contrato.

---

## 15. Definition of Done — Design System

- [ ] busqué componente equivalente;
- [ ] Atomic classification es correcta;
- [ ] no hay negocio;
- [ ] no hay dependencia a feature;
- [ ] tokens reutilizados;
- [ ] width/constraints fluidos;
- [ ] estados relevantes cubiertos;
- [ ] accesibilidad revisada;
- [ ] widget tests relevantes ejecutados;
- [ ] `dart format .` ejecutado sobre el paquete/cambios;
- [ ] analyzer del paquete/cambios revisado.
