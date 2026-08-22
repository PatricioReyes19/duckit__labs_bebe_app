# BEBÉAPP — APP_BASE AGENT RULES

**Scope:** `packages/app_base/**`  
**Extiende:** `/AGENTS.md`

`app_base` es el composition root de BebéApp.

---

## 1. Ownership

Este paquete es dueño de:

- `MaterialApp.router`;
- router global;
- composición de rutas;
- traducción de destinos semánticos;
- DI composition;
- observers globales;
- lifecycle;
- analytics global;
- app links;
- Firebase/Crashlytics/FCM wiring;
- integración entre packages.

No es dueño de reglas de negocio específicas de un feature.

---

## 2. Router

Strings/rutas concretas globales pertenecen aquí.

Features y packages de flujo deben preferir intención/destino semántico.

Ejemplo correcto:

```text
splash
→ StartupDestination.login
→ app_base
→ /login
```

Ejemplo incorrecto:

```text
splash
→ context.go('/login')
```

No duplicar path literals en features.

---

## 3. Composition

`app_base` puede importar packages para componerlos.

Eso no autoriza a mover lógica de negocio a `app_base`.

Su trabajo es wiring, no implementación de dominio.

---

## 4. Dependency Injection

Registrar dependencias en la capa que corresponde.

No usar Service Locator desde widgets para evitar wiring correcto.

Preferir inyección explícita/BLoC providers según el patrón del repositorio.

No registrar dos implementaciones del mismo contrato sin una razón clara de scope/qualifier.

---

## 5. Startup integration

`app_base` consume la resolución semántica del startup.

Debe mapear de forma exhaustiva los destinos soportados.

Si aparece un destino nuevo, revisar:

- router;
- guards/redirects;
- restore de contexto;
- deep links;
- tests.

No duplicar la máquina de estados de `splash` en router redirects.

---

## 6. Shell / app_layout

`app_layout` es dueño del chrome visual global.

`app_base` lo compone.

No replicar header/bottom bar/FAB por feature si el destino pertenece al shell principal.

---

## 7. Integraciones globales

Analytics, Crashlytics, lifecycle, notifications y app links se cablean aquí o en package especializado y se componen aquí.

No introducir llamadas globales dispersas en páginas.

---

## 8. Tests

Al tocar navegación/composición:

- verificar resolución de destinos;
- verificar guards;
- verificar ruta inicial;
- verificar deep links si aplica;
- verificar provider/DI graph afectado;
- evitar tests basados solo en strings si existe enum/destino semántico.

---

## 9. Definition of Done — app_base

- [ ] no se movió negocio a composition root;
- [ ] rutas concretas permanecen centralizadas;
- [ ] destinos semánticos mapeados exhaustivamente;
- [ ] DI consistente;
- [ ] shell respetado;
- [ ] tests relevantes ejecutados;
- [ ] analyzer revisado.
