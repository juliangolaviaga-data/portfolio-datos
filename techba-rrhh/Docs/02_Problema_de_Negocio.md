# Problema de Negocio

La información del área de Recursos Humanos suele encontrarse distribuida en múltiples archivos independientes, dificultando la obtención de indicadores confiables para la toma de decisiones.

La falta de estandarización, las inconsistencias en los datos y la ausencia de un modelo unificado obligan a realizar procesos manuales de consolidación y validación, incrementando el tiempo de análisis y el riesgo de errores.

TechBA propone una solución basada en PostgreSQL para centralizar, limpiar, validar y modelar los datos antes de ponerlos a disposición de herramientas de Business Intelligence.

---

# Situación Inicial

Los datos se encontraban distribuidos en distintos archivos CSV sin un modelo unificado.

Entre los principales problemas identificados se encontraban:

- Información dispersa entre múltiples archivos.
- Registros con valores nulos.
- Datos duplicados.
- Tipos de datos inconsistentes.
- Categorías mal definidas.
- Ausencia de relaciones entre entidades.
- Imposibilidad de consultar indicadores de forma integrada.

Como consecuencia, cualquier análisis requería procesos manuales de consolidación y validación, incrementando el tiempo de trabajo y el riesgo de errores.

---

# Necesidades del Negocio

El área de Recursos Humanos necesitaba disponer de información confiable para responder preguntas como:

- ¿Cuál es la dotación actual por departamento?
- ¿Qué áreas presentan mayor ausentismo?
- ¿Existen empleados sin información de sueldo?
- ¿Cómo se distribuyen los sueldos entre departamentos?
- ¿Cuál es el desempeño promedio por área?
- ¿Qué empleados presentan evaluaciones pendientes?

Responder estas preguntas directamente sobre los archivos originales resultaba complejo debido a la falta de estandarización de los datos.

---

# Objetivos del Proyecto

Para resolver esta situación se definieron los siguientes objetivos:

- Centralizar toda la información en PostgreSQL.
- Construir un proceso reproducible de limpieza y validación.
- Diseñar un modelo relacional consistente.
- Garantizar la integridad de los datos mediante restricciones y relaciones.
- Crear vistas optimizadas para análisis.
- Reducir al mínimo las transformaciones dentro de Power BI.
- Facilitar la reutilización del modelo para futuros análisis.

---

# Alcance

El proyecto comprende todo el proceso de preparación de datos:

- Ingesta de archivos CSV.
- Carga en tablas de staging.
- Limpieza y normalización.
- Validaciones de calidad.
- Construcción del modelo relacional.
- Creación de vistas analíticas.
- Desarrollo del dashboard en Power BI.

No forma parte del alcance la generación de datos desde sistemas transaccionales ni la automatización del proceso mediante herramientas de orquestación.

---

# Resultado Esperado

Obtener una base de datos consistente, documentada y preparada para Business Intelligence, permitiendo que Power BI consuma únicamente información previamente validada y estructurada.

Esta arquitectura mejora la mantenibilidad del proyecto, facilita futuras ampliaciones y reduce la complejidad del modelo analítico.