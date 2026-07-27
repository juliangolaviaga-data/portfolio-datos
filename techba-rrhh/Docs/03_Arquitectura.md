# Arquitectura del Proyecto

## Objetivo de la Arquitectura

La arquitectura de TechBA fue diseñada para centralizar toda la preparación de datos en PostgreSQL, separando claramente cada etapa del procesamiento antes de su consumo desde Power BI.

Este enfoque permite construir un flujo de trabajo reproducible, mantener la lógica de negocio en la base de datos y simplificar el modelo analítico.

---

# Arquitectura General

```
                 Archivos CSV
                       │
                       ▼
               Schema: staging
            (Carga de datos crudos)
                       │
                       ▼
            Limpieza y Transformación
                       │
                       ▼
              Validación de Calidad
                       │
                       ▼
                Modelo Relacional
                  (Schema core)
                       │
                       ▼
                   Vistas SQL
              (Capa de Consumo BI)
                       │
                       ▼
                   Power BI
```

---

# Descripción del Flujo

## 1. Recepción de datos

El proyecto comienza con la recepción de archivos CSV que representan diferentes entidades del área de Recursos Humanos.

Los archivos contienen información de:

- Empleados
- Departamentos
- Puestos
- Salarios
- Ausentismo
- Evaluaciones de desempeño

---

## 2. Carga en Staging

Los datos son importados sin modificaciones al esquema **staging**.

Este esquema funciona como una copia del origen y permite conservar los datos originales para realizar auditorías, validaciones y reprocesamientos cuando sea necesario.

En esta etapa no se aplican reglas de negocio ni transformaciones.

---

## 3. Limpieza y Transformación

Una vez cargados los datos, se ejecuta un proceso de limpieza destinado a corregir problemas de calidad.

Entre las tareas realizadas se incluyen:

- Conversión de tipos de datos.
- Tratamiento de valores nulos.
- Corrección de formatos.
- Eliminación de registros duplicados.
- Normalización de información.
- Corrección de inconsistencias detectadas durante la auditoría de datos.

---

## 4. Validación

Antes de construir el modelo analítico, los datos son sometidos a controles de calidad para verificar su consistencia.

Entre las validaciones implementadas se encuentran:

- Integridad de claves.
- Consistencia entre tablas relacionadas.
- Valores fuera de rango.
- Categorías inválidas.
- Registros incompletos.

Las incidencias detectadas quedan documentadas y corregidas antes de continuar con el proceso.

---

## 5. Modelo Relacional

Los datos validados son cargados en el esquema **core**, donde se construye el modelo relacional definitivo.

Este modelo constituye la fuente oficial de información del proyecto y establece las relaciones entre las distintas entidades del negocio mediante claves primarias y foráneas.

---

## 6. Vistas Analíticas

Sobre el modelo relacional se desarrollan vistas SQL destinadas exclusivamente al consumo analítico.

Estas vistas encapsulan la lógica de negocio necesaria para responder preguntas frecuentes sin exponer directamente las tablas base.

Power BI consume únicamente estas vistas.

---

## 7. Visualización

Power BI se conecta directamente al esquema **core** utilizando las vistas analíticas como única fuente de información.

Esta decisión permite:

- Reducir el uso de transformaciones en Power Query.
- Minimizar la complejidad del modelo.
- Centralizar la lógica de negocio en PostgreSQL.
- Facilitar el mantenimiento y la reutilización del proyecto.

---

# Principios de Diseño

La arquitectura de TechBA se basa en los siguientes principios:

- Separación entre datos crudos y datos procesados.
- Centralización de la lógica de negocio en PostgreSQL.
- Reutilización de componentes SQL.
- Modelo relacional normalizado.
- Trazabilidad de las transformaciones.
- Consumo de datos mediante vistas analíticas.
- Mantenimiento simplificado del modelo de Power BI.