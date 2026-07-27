# Preparación y Calidad de Datos

## Objetivo

El objetivo de esta etapa fue transformar un conjunto de archivos CSV independientes en una base de datos consistente, íntegra y preparada para su consumo desde herramientas de Business Intelligence.

Antes de construir el modelo analítico, se aplicó un proceso sistemático de auditoría, limpieza, validación y documentación de la información.

La preparación de datos se desarrolló íntegramente en PostgreSQL, permitiendo centralizar la lógica de transformación y garantizar la trazabilidad de cada modificación realizada.

---

# Metodología de Trabajo

La preparación de los datos siguió el siguiente flujo:

```
Archivos CSV
↓
Carga en Staging
↓
Auditoría de Calidad
↓
Limpieza y Normalización
↓
Validación
↓
Modelo Relacional
↓
Vistas Analíticas

```

Cada etapa posee un objetivo específico y constituye un paso previo antes de avanzar hacia la siguiente.

---

# Carga de Datos

Los archivos fueron importados inicialmente al esquema **staging**, conservando su estructura original.

Esta estrategia permite:

- preservar los datos de origen;
- repetir el proceso de transformación cuando sea necesario;
- auditar cada modificación realizada;
- mantener separado el origen de los datos procesados.

Durante esta etapa no se aplicaron reglas de negocio ni transformaciones.

---

# Auditoría de Calidad

Antes de modificar la información se realizó una revisión del conjunto de datos para identificar posibles problemas de calidad.

Entre las verificaciones realizadas se incluyen:

- valores nulos;
- registros duplicados;
- tipos de datos inconsistentes;
- formatos incorrectos;
- categorías inválidas;
- relaciones incompletas;
- inconsistencias entre tablas relacionadas.

Las incidencias detectadas fueron documentadas antes de iniciar las tareas de limpieza.

---

# Limpieza y Normalización

Una vez identificados los problemas, se aplicaron las transformaciones necesarias para obtener un conjunto de datos consistente.

Las tareas incluyeron:

- conversión de tipos de datos;
- corrección de formatos;
- normalización de valores;
- eliminación de duplicados;
- corrección de inconsistencias;
- preparación de claves para el modelo relacional.

Las transformaciones fueron implementadas mediante SQL sobre PostgreSQL.

---

# Validación

Luego de la limpieza se ejecutó una segunda etapa de controles para verificar la consistencia del conjunto de datos.

Entre los controles realizados se encuentran:

- integridad referencial;
- consistencia entre entidades;
- verificación de categorías;
- validación de claves;
- revisión de registros incompletos.

Solo los datos que superaron esta etapa fueron promovidos al esquema **core**.

---

# Tratamiento de Datos Faltantes

Durante la auditoría se detectaron registros con información incompleta, como empleados sin sueldo registrado o evaluaciones sin puntaje.

Al no existir un cliente real que definiera las reglas de negocio para completar dicha información, se decidió no modificar estos registros de forma arbitraria.

En su lugar:

- los datos originales fueron preservados;
- las incidencias fueron documentadas;
- los valores permanecieron visibles para el análisis.

Esta decisión evita introducir supuestos sin respaldo funcional y refleja un escenario habitual en proyectos reales de calidad de datos.

---

# Resultado

Como resultado del proceso se obtuvo una base de datos:

- limpia;
- consistente;
- documentada;
- trazable;
- preparada para análisis;
- optimizada para ser consumida desde Power BI mediante vistas SQL.

Toda la lógica de preparación y validación quedó centralizada en PostgreSQL, reduciendo la necesidad de transformaciones posteriores en Power BI.