<div align="center">

# Portfolio de Datos

### Analytics Engineering · PostgreSQL · SQL · Business Intelligence

Transformación de datos, modelado relacional y preparación de información para análisis y toma de decisiones.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Neon](https://img.shields.io/badge/Neon-00E599?style=for-the-badge)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

</div>

---

# Sobre este portafolio

Este repositorio reúne proyectos de **Business Intelligence y Analytics Engineering** desarrollados con un enfoque centrado en **PostgreSQL como capa principal de transformación y modelado de datos**.

Cada proyecto documenta el proceso completo, desde la recepción de archivos de origen hasta la construcción de dashboards analíticos en Power BI, incluyendo diagnóstico de calidad, limpieza, modelado relacional, vistas SQL y documentación técnica.

El objetivo es demostrar una forma de trabajo orientada a la **reutilización, mantenibilidad y separación clara entre la lógica de negocio y la capa de visualización**.

---

```text
Archivos CSV / Excel
        │
        ▼
PostgreSQL (STAGING)
        │
        ▼
Diagnóstico SQL
        │
        ▼
Limpieza y Transformación
        │
        ▼
PostgreSQL (CORE / PRODUCCIÓN)
        │
        ▼
Vistas SQL
        │
        ▼
Power BI
```

Este enfoque permite mantener una única fuente de verdad dentro de la base de datos y minimizar las transformaciones posteriores en Power BI.

---

# Tecnologías

| Tecnología | Uso |
|------------|-----|
| **PostgreSQL** | Modelado relacional, ETL y consultas analíticas |
| **Neon PostgreSQL** | Base de datos serverless para proyectos en la nube |
| **Power BI** | Dashboards y visualización de indicadores |
| **Power Query** | Transformaciones complementarias |
| **DBeaver** | Gestión y exploración de bases de datos |
| **Git & GitHub** | Control de versiones y documentación |

---

# Proyectos

## FashionStore — E-commerce Data Pipeline

Pipeline de datos para una tienda de moda, incluyendo:

- limpieza de datos provenientes de archivos CSV/XLSX;
- normalización de categorías y textos;
- manejo de múltiples formatos de fecha;
- modelado relacional;
- vistas SQL para Power BI;
- dashboards ejecutivos y comerciales.

**Tecnologías:** PostgreSQL · SQL · Power BI

📁 `fashionstore/`

---

## TechBA — Human Resources Data Pipeline

Pipeline de datos para el área de Recursos Humanos con una arquitectura **SQL First**, incluyendo:

- esquemas `staging`, `core`, `utils` y `geo`;
- limpieza y validación de datos;
- modelo relacional de producción;
- vistas SQL reutilizables;
- dashboards de dotación, ausentismo y desempeño;
- documentación técnica completa.

**Tecnologías:** Neon PostgreSQL · PostgreSQL · SQL · Power BI

📁 `techba-rrhh/`

---

# Comparación de proyectos

| Aspecto  |                                         FashionStore                | TechBA                            |
|---------------------------------------------------|----------------------------|-----------------------------------|
| **Dominio**                                       | E-commerce                 | Recursos Humanos                  |
| **Base de datos**                                 | PostgreSQL local           | Neon PostgreSQL                   |
| **Arquitectura**                                  | Staging + Producción       | SQL First + Vistas `core`         |
| **Organización por esquemas**                     | Básica                     | `staging`, `core`, `utils`, `geo` |
| **Biblioteca SQL reutilizable**                   | No                         | Sí (`utils`)                      |
| **Pipeline por etapas**                           | Parcial                    | Estandarizado                     |
| **Framework reutilizable para futuros proyectos** | No                         | Sí                                |
| **Gobernanza de la capa de exposición**           | Limitada                   | Formal (solo vistas `core`)       |
| **Documentación técnica**                         | Completa                   | Completa y modular                |
| **Dashboards**                                    | 2                          | 2                                 |

**Evolución metodológica**

FashionStore representa el proyecto fundacional del portafolio y demuestra la capacidad de construir un pipeline completo de limpieza, transformación y visualización de datos.

TechBA incorpora una evolución significativa del enfoque de trabajo: introduce una **arquitectura estandarizada basada en esquemas, una biblioteca SQL reutilizable (`utils`) y una ejecución del pipeline organizada por etapas**, estableciendo un patrón de desarrollo pensado para ser reutilizado en futuros proyectos. Este proyecto define la metodología que será aplicada como estándar en los siguientes pipelines del portafolio y sienta las bases para la **automatización de procesos y reportes mediante Python**, reutilizando funciones, validaciones y componentes comunes del esquema `utils`.

---

# Estructura del repositorio

```text
portfolio-datos/
│
├── fashionstore/
│   ├── Archivos_Bruto/
│   ├── Script/
│   ├── Docs/
│   ├── Images/
│   └── README.md
│
├── techba-rrhh/
│   ├── Archivos_Bruto/
│   ├── Script/
│   ├── Docs/
│   ├── Images/
│   └── README.md
│
└── README.md
```

---

# Qué demuestra este portafolio

- Diseño de pipelines ETL.
- Preparación y limpieza de datos.
- Modelado relacional en PostgreSQL.
- Implementación de reglas de negocio en SQL.
- Construcción de vistas analíticas reutilizables.
- Integración con Power BI.
- Documentación técnica de proyectos de datos.

---

# Autor

**Julián Olaviaga**

Analytics Engineer / BI Analyst especializado en **PostgreSQL, SQL y preparación de datos para Business Intelligence**.

- GitHub: https://github.com/juliangolaviaga-data
- LinkedIn: *(agregar enlace cuando esté actualizado)*

---

<p align="center">
  <b>Portfolio de Datos</b><br>
  PostgreSQL · SQL · Analytics Engineering · Business Intelligence
</p>