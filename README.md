::: {align="center"}
# TECHBA --- Human Resources Data Pipeline

### Pipeline ETL y Arquitectura SQL para Business Intelligence en Recursos Humanos

Desde archivos de origen hasta dashboards analíticos en Power BI
utilizando PostgreSQL y Neon.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Neon](https://img.shields.io/badge/Neon-00E599?style=for-the-badge)
![Power
BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge)
:::

------------------------------------------------------------------------

```{=html}
<p align="center">
```
`<img src="Images/dashboard_01.png" width="100%">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

# 📋 Descripción del Proyecto

TECHBA es un proyecto de Business Intelligence que demuestra el
desarrollo completo de un pipeline de datos para el área de Recursos
Humanos.

El proyecto abarca todo el flujo de procesamiento, desde la importación
de archivos de origen hasta la generación de dashboards interactivos en
Power BI, aplicando procesos de limpieza, validación, modelado
relacional y preparación de datos en PostgreSQL.

La arquitectura está diseñada bajo un enfoque **SQL First**,
centralizando la lógica de negocio dentro de la base de datos mediante
tablas de producción y vistas SQL reutilizables, permitiendo que Power
BI se utilice exclusivamente como herramienta de visualización y
análisis.

------------------------------------------------------------------------

# 📊 Resumen del Proyecto

  Métrica                                Valor
  ---------------------------------- ---------
  **Tablas de origen**                       6
  **Registros procesados**             \~7.350
  **Esquemas de la base de datos**           4
  **Tablas de producción**                   6
  **Vistas SQL**                             6
  **Páginas del Dashboard**                  2
  **Documentos técnicos**                    9

------------------------------------------------------------------------

# 🚀 Plataforma

  Componente             Tecnología
  ---------------------- -----------------
  Base de datos          Neon PostgreSQL
  Motor SQL              PostgreSQL
  Visualización          Power BI
  Control de versiones   Git
  Repositorio            GitHub

------------------------------------------------------------------------

# 🛠️ Tecnologías y Conceptos Aplicados

-   ETL
-   Data Cleaning
-   Data Validation
-   Modelado Relacional
-   SQL Views
-   Business Intelligence
-   Arquitectura SQL First

------------------------------------------------------------------------

# 🏗️ Arquitectura del Pipeline

El proyecto implementa un pipeline de datos organizado en capas, donde
cada etapa cumple una responsabilidad específica dentro del proceso de
preparación de la información.

El flujo comienza con la importación de los archivos de origen hacia un
entorno de trabajo (**staging**), continúa con las tareas de limpieza,
validación y transformación de los datos, para luego consolidar un
modelo relacional de producción (**core**). Finalmente, las vistas SQL
sirven como fuente única de información para Power BI, evitando duplicar
lógica de negocio en la herramienta de visualización.

```{=html}
<p align="center">
```
`<img src="Images/arquitectura.png" width="100%">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

# 🗂️ Organización de la Base de Datos

La base de datos se encuentra organizada en esquemas independientes para
separar responsabilidades y facilitar el mantenimiento del proyecto.

  -----------------------------------------------------------------------
  Esquema                        Descripción
  ------------------------------ ----------------------------------------
  **staging**                    Área de trabajo donde se importan,
                                 limpian y validan los datos provenientes
                                 de los archivos de origen.

  **core**                       Contiene el modelo relacional
                                 definitivo, las tablas de producción y
                                 las vistas SQL utilizadas por Power BI.

  **utils**                      Biblioteca de funciones y utilidades SQL
                                 reutilizables desarrolladas durante el
                                 proyecto.

  **geo**                        Esquema generado por PostGIS que
                                 almacena metadatos espaciales del
                                 sistema. No participa del flujo
                                 analítico.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 🗄️ Modelo de Datos

El modelo relacional fue diseñado para garantizar la integridad de la
información mediante claves primarias, claves foráneas y relaciones
normalizadas.

La separación entre las tablas de trabajo (**staging**) y las tablas de
producción (**core**) permite mantener un proceso de carga y
transformación organizado, reutilizable y fácil de mantener.

```{=html}
<p align="center">
```
`<img src="Images/modelo_datos.png" width="100%">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

# 💻 Implementación SQL

Una de las principales decisiones de arquitectura del proyecto fue
centralizar la lógica de negocio dentro de PostgreSQL.

Los scripts SQL están organizados por etapas del pipeline (creación de
esquemas, limpieza, conciliación, modelado y vistas analíticas),
permitiendo un proceso reproducible, reutilizable y fácil de mantener.

### Ejemplo de Script SQL

```{=html}
<p align="center">
```
`<img src="Images/SQL_2.png" width="100%">`{=html}
```{=html}
</p>
```
### Vista SQL utilizada por Power BI

```{=html}
<p align="center">
```
`<img src="Images/sql_view_02.png" width="100%">`{=html}
```{=html}
</p>
```
Las vistas SQL del esquema **core** son consumidas directamente por
Power BI, evitando transformaciones complejas en la herramienta de
visualización y manteniendo una única fuente de verdad dentro de la base
de datos.

------------------------------------------------------------------------

# 📊 Dashboard

El dashboard fue desarrollado en Power BI utilizando exclusivamente las
vistas SQL del esquema **core**, manteniendo toda la lógica de
transformación y preparación de datos dentro de PostgreSQL.

```{=html}
<p align="center">
```
`<img src="Images/dashboard_01.png" width="100%">`{=html}
```{=html}
</p>
```
```{=html}
<p align="center">
```
`<img src="Images/dashboard_02.png" width="100%">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

# 📁 Estructura del Proyecto

La estructura del proyecto está organizada para separar los archivos de
origen, los scripts SQL, la documentación técnica y los recursos
visuales utilizados durante el desarrollo del pipeline.

``` text
techba-rrhh/
│
├── Archivos_Bruto/
│
├── Script/
│   ├── crear_esquemas.sql
│   ├── staging_limpieza_datos.sql
│   ├── staging_conciliacion_datos.sql
│   ├── core_crear_tablas.sql
│   └── core_vistas.sql
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
│   ├── arquitectura.svg
│   ├── dashboard_01.png
│   ├── dashboard_02.png
│   ├── modelo_datos.png
│   ├── SQL_2.png
│   └── sql_view_02.png
│
└── README.md
```

------------------------------------------------------------------------

# 📚 Documentación Técnica

El proyecto incluye documentación técnica detallada que describe cada
etapa del desarrollo, desde la definición del problema hasta las
decisiones de arquitectura implementadas.

  --------------------------------------------------------------------------------------------------------------------------
  Documento                                                                           Descripción
  ----------------------------------------------------------------------------------- --------------------------------------
  [01_Resumen_Ejecutivo.md](Docs/01_Resumen_Ejecutivo.md)                             Resumen general del proyecto y sus
                                                                                      objetivos.

  [02_Problema_de_Negocio.md](Docs/02_Problema_de_Negocio.md)                         Contexto y necesidad analítica del
                                                                                      área de Recursos Humanos.

  [03_Arquitectura.md](Docs/03_Arquitectura.md)                                       Diseño de la arquitectura del pipeline
                                                                                      y organización del flujo de datos.

  [04_Modelo_de_Datos.md](Docs/04_Modelo_de_Datos.md)                                 Modelo relacional, esquemas y
                                                                                      relaciones entre entidades.

  [05_Preparacion_y_Calidad_de_Datos.md](Docs/05_Preparacion_y_Calidad_de_Datos.md)   Procesos de limpieza, estandarización
                                                                                      y validación de datos.

  [06_Registro_de_Incidencias.md](Docs/06_Registro_de_Incidencias.md)                 Problemas encontrados y soluciones
                                                                                      aplicadas durante el desarrollo.

  [07_Dashboard_y_Resultados.md](Docs/07_Dashboard_y_Resultados.md)                   Métricas, visualizaciones y resultados
                                                                                      obtenidos.

  [08_Decisiones_de_Arquitectura.md](Docs/08_Decisiones_de_Arquitectura.md)           Justificación de las principales
                                                                                      decisiones técnicas del proyecto.

  [09_Mejoras_Futuras.md](Docs/09_Mejoras_Futuras.md)                                 Posibles extensiones y evolución
                                                                                      futura del pipeline.
  --------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 👨‍💻 Autor

**Julián Olaviaga**

Especialista en procesamiento y análisis de datos, enfocado en
arquitectura SQL, PostgreSQL y preparación de datos para Business
Intelligence.

-   GitHub: https://github.com/juliangolaviaga-data
-   LinkedIn: *(agregar enlace cuando esté actualizado)*

------------------------------------------------------------------------

```{=html}
<p align="center">
```
`<b>`{=html}TECHBA --- Human Resources Data
Pipeline`</b>`{=html}`<br>`{=html} Arquitectura SQL First • PostgreSQL •
Neon • Power BI
```{=html}
</p>
```
