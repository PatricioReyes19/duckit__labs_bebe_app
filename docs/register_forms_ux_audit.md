# Auditoría UX de formularios de registro

Fecha: 6 de agosto de 2026

## Alcance

Se contrastaron los seis diseños de referencia entregados para Alimentación,
Sueño, Pañal, Observación clínica, Medicina y Medición con la implementación de
`packages/register` y los componentes compartidos de `packages/design_system`.

La revisión cubrió arquitectura de información, coherencia clínica de los
datos, controles, validación, jerarquía visual, densidad móvil, navegación y
accesibilidad básica.

## Resultado ejecutivo

El problema principal no era cosmético. Los formularios tenían una única
estructura visual por categoría, aunque varios subtipos requieren datos
distintos. Esto permitía guardar información semánticamente incorrecta, por
ejemplo un lado del pecho para una mamadera o características de deposiciones
en un pañal con solo orina.

También había una brecha visual sistemática: categorías sobredimensionadas con
scroll horizontal, subcategorías sin iconos, campos cortos apilados en una sola
columna, radios mayores que los del diseño y ausencia de la navegación inferior
en el flujo real.

## Hallazgos y correcciones

| Prioridad | Área | Hallazgo | Riesgo UX / de datos | Resolución |
| --- | --- | --- | --- | --- |
| P0 | Alimentación | Pecho, mamadera, leche extraída y fórmula compartían el campo `Lado`. | Se guardaba anatomía no aplicable a una toma en recipiente y no existía cantidad consumida. | `Lado` se muestra solo para pecho. Los otros subtipos exigen `Cantidad (mL)`, normalizan coma decimal y guardan `amount_ml`. |
| P0 | Pañal | Un pañal mojado guardaba apariencia, color y cantidad de deposiciones. | Registro clínicamente ambiguo y estadísticas posteriores poco confiables. | Se incorporó `Orina` explícita. Orina guarda color/cantidad propios; deposición conserva apariencia/color/cantidad; mixto registra ambos bloques. |
| P1 | Medicina | Suplemento y vitamina seguían preguntando “Nombre del medicamento”. | La etiqueta contradice la selección y reduce confianza. | Etiqueta, semántica y mensaje de validación ahora cambian según medicamento, suplemento o vitamina. |
| P1 | Medición | El campo se llamaba genéricamente “Medición (kg/cm)”. | El usuario debía recordar si había seleccionado peso, talla o perímetro. | La etiqueta ahora es `Peso`, `Talla` o `Perímetro cefálico`, con unidad y ejemplo contextual. |
| P1 | Observación | La grilla se resolvía en dos columnas y todo el formulario aparecía dentro de una tarjeta ausente en el diseño. | Mucho desplazamiento y jerarquía diferente a la referencia. | Tipos en tres columnas en ancho de referencia y composición directa sobre la superficie de página. |
| P1 | Navegación | Registro se abre fuera del shell y perdía la barra inferior visible en todos los diseños. | Ruptura del modelo de navegación y sensación de pantalla ajena a la app. | Se añadió navegación inferior específica, conectada a Inicio, Agenda, Salud y Familia, con Registrar activo. |
| P1 | Densidad | Hora, duración y término se apilaban en móvil. | El formulario duplicaba su altura y dejaba de parecerse al diseño. | Los campos cortos usan tres columnas en el ancho objetivo y degradan de forma adaptativa en pantallas más estrechas. |
| P1 | Selectores | Las seis categorías eran tarjetas de aproximadamente 104 px y requerían scroll; los subtipos eran texto plano. | Baja encontrabilidad y pérdida de la jerarquía visual del mockup. | Categorías compactas adaptativas; subcategorías prominentes con icono, selección y divisores. |
| P2 | Superficies | Tarjetas y selector de bebé usaban radios y alturas mayores que la referencia. | Apariencia inflada y menor densidad de información. | Se redujeron radios, padding vertical y altura de banners sin bajar de los objetivos táctiles. |

## Contrato de datos resultante

### Alimentación

- `breast`: `side`, horario, duración, estado y observaciones.
- `bottle`, `expressed`, `formula`: `amount_ml`, horario, duración, estado y
  observaciones.
- Una toma no mamaria sin cantidad válida no se guarda.

### Pañal

- `wet`: `urine_color`, `urine_amount`.
- `dirty`: `appearance`, `color`, `amount` para deposición, conservando
  compatibilidad con registros existentes.
- `mixed`: ambos conjuntos.

## Pendientes que no deben resolverse con datos ficticios

1. El bebé activo, su edad, avatar y contexto familiar todavía llegan con
   valores locales por defecto. Deben provenir de la sesión/familia activa.
2. Los banners del diseño (“Última toma…”, “Próxima dosis…”, “Último peso…”)
   requieren consultar eventos reales. La interfaz actual mantiene mensajes
   informativos y no inventa métricas clínicas.
3. `Temporizador` de sueño todavía usa el formulario de duración manual. Antes
   de producción debe convertirse en un flujo real iniciar/detener o retirarse
   temporalmente para no prometer una función inexistente.
4. El selector de bebé muestra affordance de cambio, pero el flujo de selección
   aún debe conectarse al estado de bebé activo.
5. Las fotos clínicas necesitan estados explícitos para permiso denegado,
   error de lectura, carga y eliminación.

## Criterios de aceptación

- Ningún subtipo solicita o persiste campos que no le corresponden.
- Las seis categorías son visibles simultáneamente en el ancho móvil de los
  diseños; en anchos estrechos conservan objetivos táctiles mediante scroll.
- Los selectores de subtipo conservan icono, etiqueta y estado seleccionado.
- Los campos de hora usan la misma fila cuando el ancho lo permite y no
  desbordan con texto ampliado.
- Registro conserva acceso a las cinco áreas de navegación de la app.
- Validaciones describen el dato faltante con el vocabulario del subtipo.
- La implementación mantiene semántica de botones, selección y etiquetas.
