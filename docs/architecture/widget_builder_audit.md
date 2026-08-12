# Auditoría de helpers que construyen widgets

## Criterio

Un método que retorna `Widget` no produce por sí mismo una fuga o un consumo de
memoria adicional. El problema práctico es que oculta límites de rebuild,
dificulta usar `const` y `Key`, mezcla estado con presentación y no puede
probarse aisladamente. La corrección es extraer componentes, no mover el mismo
código a otro helper.

Comando reproducible:

```powershell
rg -n --glob '*.dart' "(^|\s)(Widget|List<Widget>)\s+_[A-Za-z0-9_]+\s*\(" packages apps/bebe_app/lib
```

## Corregidos en esta revisión

- `BebeQuickRegistrationActions._buildTile` → componente privado con callback.
- `_eventIcon` de Agenda → mapeo puro a `IconData`.
- `_historyContent` de Home → `StatelessWidget` con límite de Bloc propio.
- `_registerContent` de Registro → `StatelessWidget` con proveedores propios.

## Pendientes encontrados

| Área | Archivo | Helpers |
|---|---|---|
| Agenda | `packages/agenda/lib/pages/agenda_subpage.dart` | `_reminderSettings`, `_createReminder`, `_eventDetail` |
| Registro | `packages/register/lib/pages/views/register_page_view.dart` | `_feeding`, `_sleep`, `_diaper`, `_clinicalObservation`, `_medication`, `_measurement`, `_shell` |
| Salud | `packages/health/lib/pages/views/health_flow_detail_views.dart` | `_basicStep`, `_indicationsStep`, `_summaryStep`, `_vaccineDetail`, `_measurementDetail`, `_consultationDetail`, `_pediatricianDetail`, `_clinicalDetail` |

Son 18 helpers restantes. Deben extraerse por flujo, conservando los Cubits y
controladores en el dueño correcto; hacer un reemplazo textual global arriesga
reinicializar formularios y perder estado al cambiar de tab.

## Regla para código nuevo

- Un fragmento visual reutilizable o con estado de carga es una clase de
  componente.
- Las funciones puras pueden mapear valores (`enum` → `IconData`, color o texto)
  y no retornan widgets.
- La view conecta Bloc/Cubit y navegación; el componente recibe datos y
  callbacks.
- Todo componente público con carga remota expone su skeleton junto a la clase.
- El template recibe `isLoading` y compone skeletons; no dibuja un spinner
  genérico que desconozca la forma final.

