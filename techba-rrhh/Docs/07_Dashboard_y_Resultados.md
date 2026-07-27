# 07_Dashboard_y_Resultados.md

# Dashboard y Resultados

## Objetivo

El objetivo del dashboard es transformar la información preparada en PostgreSQL en indicadores visuales que permitan analizar la situación del área de Recursos Humanos de forma rápida, consistente y confiable.

Toda la lógica de negocio fue implementada previamente en PostgreSQL. Power BI actúa exclusivamente como herramienta de visualización y exploración de datos.

---

# Fuente de Datos

El dashboard se conecta directamente a PostgreSQL (Neon) mediante el modo Import.

Como fuente de información utiliza únicamente vistas analíticas del esquema `core`, evitando el acceso directo a tablas operacionales.

Esta arquitectura permite:

- Centralizar la lógica de negocio.
- Reducir transformaciones en Power Query.
- Minimizar el uso de medidas DAX complejas.
- Facilitar el mantenimiento del modelo.

---

# Estructura del Dashboard

El informe está compuesto por dos páginas principales.

## Página 1 — Dotación y Ausentismo

Permite analizar:

- Dotación total de empleados.
- Distribución por departamento.
- Distribución por puesto.
- Empleados sin sueldo registrado.
- Ausentismo por área.
- Ausencias por empleado.
- Distribución de sueldos.

---

## Página 2 — Evaluaciones de Desempeño

Permite analizar:

- Puntaje promedio general.
- Distribución de evaluaciones por categoría.
- Top 5 mejor desempeño y Top 5 empleados que necesitan atención (puntaje promedio).
- Historial de evaluaciones por empleado.
- Última evaluación registrada por empleado.

---

# Indicadores Generados

Entre los principales indicadores desarrollados se encuentran:

- Total de empleados.
- Empleados activos.
- Empleados sin sueldo registrado.
- Sueldo promedio.
- Ausencias totales.
- Ausencias por departamento.
- Puntaje promedio.
- Distribución por categoría.
- Top 5 mejor y peor desempeño.

---

# Principios de Diseño

Durante el desarrollo del dashboard se priorizaron los siguientes criterios:

- Simplicidad visual.
- Consistencia entre páginas.
- Uso eficiente del espacio.
- Navegación intuitiva.
- Indicadores fácilmente interpretables.
- Separación entre lógica de negocio y visualización.

---

# Resultado

El resultado es un dashboard preparado para responder preguntas frecuentes del área de Recursos Humanos utilizando información previamente validada y modelada en PostgreSQL.

La arquitectura implementada facilita futuras ampliaciones del modelo sin afectar las visualizaciones existentes.