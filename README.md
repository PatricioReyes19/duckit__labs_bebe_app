\# DuckIT BebéApp



Aplicación móvil desarrollada en Flutter para centralizar el cuidado diario de bebés entre 0 y 36 meses.



El proyecto nace desde una necesidad común en familias con más de un cuidador: la información importante del bebé suele quedar repartida entre WhatsApp, memoria, notas, cuadernos o conversaciones sueltas. Eso provoca pérdida de trazabilidad, duplicidad de registros, olvidos de medicamentos y poca claridad al momento de asistir a controles pediátricos.



BebéApp busca resolver ese problema mediante una aplicación móvil modular, escalable y preparada para crecimiento futuro.



\---



\## Objetivo del proyecto



Desarrollar un prototipo funcional de una aplicación móvil que permita registrar, consultar y compartir información relevante del cuidado infantil, mejorando la coordinación entre cuidadores y el acceso al historial del bebé.



El MVP considera:



\- Registro de eventos diarios.

\- Perfil del bebé.

\- Cuidadores y roles.

\- Calendario referencial de vacunas y controles.

\- Historial cronológico.

\- Alertas y recordatorios.

\- Base para reportes pediátricos.

\- Arquitectura modular con Melos.



\---



\## Stack técnico



\- Flutter

\- Dart

\- Melos

\- Pub Workspaces

\- GoRouter

\- Bloc / Flutter Bloc

\- Freezed

\- Equatable

\- Firebase, en una etapa posterior

\- SQLite o almacenamiento local, en una etapa posterior



\---



\## Arquitectura general



El proyecto usa un monorepo administrado con Melos.  

La aplicación principal vive en `apps/bebe\_app` y los módulos reutilizables viven en `packages`.



La arquitectura se organiza bajo una idea simple:



> La app ejecuta, `app\_base` orquesta, `core` concentra negocio y datos, `design\_system` dibuja, `app\_layout` estructura, y las features solo presentan.

