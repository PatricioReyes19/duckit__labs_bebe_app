# BEBÉAPP — SPLASH / STARTUP AGENT RULES

**Scope:** `packages/splash/**`  
**Extiende:** `/AGENTS.md`

Este paquete implementa el **startup funcional Flutter**.

No confundir con el splash nativo.

---

## 1. Responsabilidad

`splash` es dueño de:

- máquina de estados inicial;
- resolución de startup;
- estados de carga/error/decisión;
- destinos semánticos;
- acciones iniciales como login/sign-up requested;
- coordinación del contexto necesario para decidir el destino.

No es dueño de rutas concretas GoRouter.

---

## 2. Destinos semánticos

Representar destinos con enum/sealed type/model semántico, por ejemplo:

```text
home
login
signUp
onboarding
invitation
contextSelection
babySelection
```

La lista exacta debe seguir el código vigente.

MUST NOT:

```dart
context.go('/login');
context.go('/home');
```

dentro de `packages/splash`.

`app_base` traduce el destino.

---

## 3. Orden de resolución

No asumir flujo lineal.

Evaluar, según la implementación vigente:

1. bootstrap técnico;
2. sesión/auth;
3. restauración de contexto local;
4. contexto remoto/sync mínimo necesario;
5. invitación pendiente;
6. onboarding incompleto;
7. círculo/membresía;
8. bebé/contexto activo;
9. home u otro destino final.

No recrear un bebé/círculo porque la caché local esté vacía si la sesión puede restaurar datos remotos válidos.

---

## 4. Invitaciones

Las invitaciones pueden cambiar el destino de startup.

No degradar información de permisos durante la aceptación/restauración.

La lógica de autorización pertenece a dominio/RLS; splash solo decide flujo.

---

## 5. UI de splash

El splash funcional puede mostrar la experiencia visual aprobada mientras resuelve estado.

No agregar otra vista de splash intermedia después del splash nativo.

No repartir cargas de startup entre múltiples pantallas decorativas.

Mantener la carga funcional en la vista de splash aprobada salvo cambio explícito de UX.

---

## 6. Side effects

Los efectos de navegación deben exponerse de forma semántica.

Evitar navegación directa enterrada en listeners sin contrato.

Errores recuperables deben permitir retry o destino seguro según contrato.

---

## 7. Tests mínimos

Cambios en startup deben cubrir cuando aplique:

- sesión activa → home;
- sesión ausente/expirada → auth;
- onboarding incompleto → paso correcto;
- invitación pendiente → flujo correcto;
- contexto/bebé ya existente → no recrear onboarding;
- restauración offline/local;
- error remoto con local válido;
- acciones login/sign-up;
- destino semántico, no path literal.

---

## 8. Definition of Done — Splash

- [ ] no hay strings de rutas globales;
- [ ] no se duplicó lógica del router;
- [ ] se preservó restore de sesión/contexto;
- [ ] invitaciones consideradas;
- [ ] offline-first considerado;
- [ ] no se añadió splash intermedio;
- [ ] tests de destinos relevantes ejecutados.
