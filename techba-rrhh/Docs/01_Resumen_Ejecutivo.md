# Resumen Ejecutivo

# Descripción

TechBA es un proyecto de Business Intelligence que simula el proceso completo de preparación, validación y modelado de datos del área de Recursos Humanos utilizando PostgreSQL como plataforma central de procesamiento y Power BI como herramienta de visualización.

El proyecto demuestra una metodología de trabajo orientada a transformar datos crudos provenientes de múltiples archivos CSV en información consistente, documentada y lista para el análisis.

Toda la lógica de negocio fue implementada en PostgreSQL, permitiendo que Power BI consuma únicamente vistas preparadas para análisis, reduciendo la complejidad del modelo analítico y facilitando su mantenimiento.

---

# Problema

La información de Recursos Humanos se encontraba distribuida en múltiples archivos independientes correspondientes a empleados, departamentos, puestos, sueldos, ausentismo y evaluaciones de desempeño.

Esta situación dificultaba obtener indicadores confiables sobre la dotación de personal, ausentismo, remuneraciones y desempeño, obligando a realizar análisis manuales y aumentando el riesgo de inconsistencias.

---

# Objetivo

Diseñar un pipeline de datos que permita:

- Centralizar la información en PostgreSQL.
- Detectar y corregir problemas de calidad de datos.
- Construir un modelo relacional consistente.
- Exponer vistas optimizadas para análisis.
- Consumir dichas vistas desde Power BI sin incorporar lógica de negocio adicional.

---

# Metodología

El flujo de trabajo implementado fue el siguiente:

```
Archivos CSV
        │
        ▼
Carga en Staging
        │
        ▼
Limpieza de datos
        │
        ▼
Validación de calidad
        │
        ▼
Modelo relacional
        │
        ▼
Vistas SQL
        │
        ▼
Power BI
```

---

# Tecnologías

- PostgreSQL
- SQL
- Neon PostgreSQL
- Power BI
- Git
- GitHub

---

# Resultado

El proyecto entrega una base de datos limpia, validada y documentada, preparada para ser consumida desde Power BI mediante vistas SQL.

La arquitectura permite centralizar la lógica de negocio en la base de datos, simplificando el mantenimiento, mejorando la trazabilidad y facilitando la reutilización del modelo analítico.
