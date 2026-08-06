# Componentes Atomic Design derivados de los mockups

Fecha de revisión: 5 de agosto de 2026

Este catálogo traduce los patrones repetidos de los 106 mockups de
`C:\Users\reyes\Downloads\mock_up` a componentes públicos, responsivos y sin
lógica de negocio dentro de `packages/design_system`.

## Criterios de estandarización

- Las cards usan altura mínima y crecen según su contenido.
- Los textos visibles no se truncan por defecto. Los límites de líneas son una
  decisión explícita del consumidor para superficies realmente densas.
- A partir de texto ampliado al 130 %, los encabezados y composiciones complejas
  se apilan para conservar legibilidad e iconos.
- Las grillas calculan columnas a partir del ancho disponible mediante
  `BebeAdaptiveGrid`; no dependen del ancho total del dispositivo.
- Los templates de producto usan `neutralsSurface` como fondo común y limitan
  el ancho de lectura con `BebeResponsiveContent`.
- Navegación, carga de datos y persistencia permanecen en cada feature mediante
  callbacks y modelos visuales inmutables.

## Átomos

| Componente | Patrón del diseño | Uso |
| --- | --- | --- |
| `BebeRatingStar` | Estrella seleccionada/no seleccionada | Evaluación de consulta o profesional. |
| `BebeLeadingIcon` | Icono circular semántico | Timeline, estados, listas y cards. El tamaño `large` ahora es visualmente distinto. |
| `BebeButton` | Acción principal/secundaria | Altura mínima accesible; crece con etiquetas largas y texto ampliado. |
| `BebeMetadataItem` | Icono + dato contextual | Sin truncado por defecto; `maxLines` sigue disponible de forma optativa. |

## Moléculas

| Componente | Patrón del diseño | Responsividad |
| --- | --- | --- |
| `BebeCompactMetricCard` | Estadística compacta de informes | Valor, unidad, estado y tendencia; altura intrínseca. |
| `BebeProgressSteps` | Flujos de tres pasos | Horizontal o vertical según ancho y escala de texto. |
| `BebeRatingSelector` | Escala de una a cinco estrellas | Wrap accesible y callback controlado. |
| `BebeFamilyMetricCard` | Métrica de “Mi familia” | Cambia de fila a composición vertical en cards estrechas. |
| `BebeBabyProfileCard` | Perfil de bebé | Dos columnas en móvil cuando existe espacio; modo compacto automático. |
| `BebeBabySelector` | Bebé activo/secundario | Variante compacta, avatar genérico y textos de altura natural. |
| `BebeDetailActionCard` | Acceso a flujo secundario | Título, descripción y metadata completos. |
| `BebeDetailSummaryCard` | Pares de detalle | Label, valor y apoyo crecen sin elipsis. |
| `BebeStatusBadge` | Estado local, pendiente o clínico | El badge aumenta su altura si la etiqueta envuelve. |

## Organismos

| Componente | Patrón del diseño | Contrato |
| --- | --- | --- |
| `BebeMetricsOverview` | Grupo de tres métricas | Título y grilla de hasta tres columnas. |
| `BebeStatePanel` | Éxito, vacío, error u offline | Ilustración/icono, detalle y dos acciones adaptativas. |
| `BebeTimeline` | Historial diario o clínico | Hora, icono, card, metadata, estado y detalle por callback. |
| `BebeTodaySummary` | Resumen del Home | Incluye `onHistoryPressed` y “Ver historial” como acción explícita. |
| `BebeFamilyContextHeader` | Bebé activo + contexto alternativo | Acepta `secondaryContext` y apila en móvil o con texto ampliado. |

## Templates y features alineados

- Home: `BebeTodaySummary` abre `/home/history`.
- Historial de hoy: usa datos locales reales, filtros por categoría,
  `BebeTimeline` y detalle completo en bottom sheet.
- Familia: bebé activo, selector del segundo bebé, “Mi familia” con tres
  métricas, dos perfiles, círculo de cuidado y acciones con iconografía.
- Registro, Agenda, Salud, Familia y Configuración: fondo de superficie
  uniforme, ancho máximo y scroll cuando el contenido crece.

## Cobertura pendiente de producto

Los componentes visuales ya existen, pero los siguientes flujos aún requieren
features, rutas o datos definitivos: vacunas y controles, crecimiento,
informes/exportación, profesionales, invitaciones/permisos familiares,
notificaciones, sincronización remota y resolución del bebé activo real.

Los nuevos componentes están catalogados en Widgetbook y cubiertos por pruebas
de ancho reducido, texto al 200 %, interacción y ausencia de overflow.
