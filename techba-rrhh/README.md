---

# 📋 Descripción del Proyecto

TECHBA es un proyecto de Business Intelligence que demuestra el desarrollo completo de un pipeline de datos para el área de Recursos Humanos.

El proyecto abarca todo el flujo de procesamiento, desde la importación de archivos de origen hasta la generación de dashboards interactivos en Power BI, aplicando procesos de limpieza, validación, modelado relacional y preparación de datos en PostgreSQL.

La arquitectura está diseñada bajo un enfoque **SQL First**, centralizando la lógica de negocio dentro de la base de datos mediante tablas de producción y vistas SQL reutilizables, permitiendo que Power BI se utilice exclusivamente como herramienta de visualización y análisis.

---

# 🚀 Plataforma

| Componente | Tecnología |
|------------|------------|
| Base de datos | Neon PostgreSQL |
| Motor SQL | PostgreSQL |
| Visualización | Power BI |
| Control de versiones | Git |
| Repositorio | GitHub |
---

# 🛠️ Tecnologías y Conceptos Aplicados

- ETL
- Data Cleaning
- Data Validation
- Modelado Relacional
- SQL Views
- Business Intelligence
- Arquitectura SQL First

---

# 📊 Resumen del Proyecto

| Métrica | Valor |
|---------|------:|
| **Tablas de origen** | 6 |
| **Registros procesados** | ~7.350 |
| **Esquemas de la base de datos** | 4 |
| **Tablas de producción** | 6 |
| **Vistas SQL** | 6 |
| **Páginas del Dashboard** | 2 |
| **Documentos técnicos** | 9 |

---

# 🏗️ Arquitectura del Pipeline

El proyecto implementa un pipeline de datos organizado en capas, donde cada etapa cumple una responsabilidad específica dentro del proceso de preparación de la información.

El flujo comienza con la importación de los archivos de origen hacia un entorno de trabajo (*staging*), continúa con las tareas de limpieza, validación y transformación de los datos, para luego consolidar un modelo relacional de producción (*core*). Finalmente, las vistas SQL sirven como fuente única de información para Power BI, evitando duplicar lógica de negocio en la herramienta de visualización.

<p align="center">
  <img src="images/arquitectura.png" width="100%">
</p>

---

# 🗂️ Organización de la Base de Datos

La base de datos se encuentra organizada en esquemas independientes para separar responsabilidades y facilitar el mantenimiento del proyecto.

| Esquema | Descripción |
|----------|-------------|
| **staging** | Área de trabajo donde se importan, limpian y validan los datos provenientes de los archivos de origen. |
| **core** | Contiene el modelo relacional definitivo, las tablas de producción y las vistas SQL utilizadas por Power BI. |
| **utils** | Biblioteca de funciones y utilidades SQL reutilizables desarrolladas durante el proyecto. |
| **geo** | Esquema generado por PostGIS que almacena metadatos espaciales del sistema. No participa del flujo analítico. |

---

# 🔄 Flujo del Pipeline

```text
Archivos de origen
        │
        ▼
 Importación de datos
        │
        ▼
  Esquema staging
        │
        ▼
Limpieza y validación
        │
        ▼
 Transformación SQL
        │
        ▼
   Esquema core
        │
        ▼
    Vistas SQL
        │
        ▼
     Power BI
        │
        ▼
 Dashboards Analíticos
```
---

# 📊 Dashboard

El dashboard fue desarrollado en Power BI utilizando como única fuente de datos las vistas SQL del esquema **core**.

Toda la lógica de transformación y preparación de los datos se implementó previamente en PostgreSQL, permitiendo que Power BI se utilice exclusivamente para la exploración visual y el análisis de indicadores.

<p align="center">
    <img src="images/dashboard_01.png" width="100%">
</p>

<p align="center">
    <img src="images/dashboard_02.png" width="100%">
</p>

---

# 🗄️ Modelo de Datos

El modelo relacional fue diseñado para garantizar la integridad de la información mediante claves primarias, claves foráneas y relaciones normalizadas.

La separación entre las tablas de trabajo (*staging*) y las tablas de producción (*core*) permite mantener un proceso de carga y transformación organizado, reutilizable y fácil de mantener.

<p align="center">
    <img src="images/modelo_datos.png" width="100%">
</p>

---

# 💻 Vista SQL de Producción

Una de las principales decisiones de arquitectura del proyecto fue centralizar la lógica de negocio dentro de PostgreSQL.

En lugar de realizar transformaciones complejas en Power BI, el modelo expone vistas SQL listas para el análisis, simplificando el consumo de información, favoreciendo la reutilización y manteniendo una única fuente de verdad.

La siguiente imagen corresponde a la vista **`vw_empleados_completo`**, utilizada como una de las fuentes de datos del dashboard.

<p align="center">
    <img src="images/sql_view.png" width="100%">
</p>

---

# 📁 Estructura del Proyecto

La estructura del proyecto está organizada para separar los archivos de origen, documentación técnica, recursos visuales y scripts SQL utilizados durante el desarrollo del pipeline.

```text
techba-rrhh/
│
├── Archivos_Bruto/
│
├── Docs/
│   ├── 01_Resumen_Ejecutivo.md
│   ├── 02_Problema_de_Negocio.md
│   ├── 03_Arquitectura.md
│   ├── 04_Modelo_de_Datos.md
│   ├── 05_Preparacion_y_Calidad_de_Datos.md
│   ├── 06_Registro_de_Incidencias.md
│   ├── 07_Dashboard_y_Resultados.md
│   ├── 08_Decisiones_de_Arquitectura.md
│   └── 09_Mejoras_Futuras.md
│
├── Images/
│   ├── arquitectura.png
│   ├── pipeline.png
│   ├── dashboard_01.png
│   ├── dashboard_02.png
│   ├── modelo_datos.png
│   └── sql_view.png
│
├── Script/
│
└── README.md
```

> Nota: las funciones SQL reutilizables utilizadas durante el desarrollo se mantienen en un repositorio independiente de librerías y no forman parte de este repositorio.

---