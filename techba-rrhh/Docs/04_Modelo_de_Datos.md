# Modelo de Datos

## Objetivo

El modelo de datos de TechBA fue diseñado para consolidar la información del área de Recursos Humanos en una estructura relacional consistente, eliminando redundancias y facilitando el análisis mediante consultas SQL y herramientas de Business Intelligence.

El modelo constituye la fuente oficial de información del proyecto y representa la capa sobre la que se construyen todas las vistas analíticas utilizadas por Power BI.

---

# Arquitectura del Modelo

El modelo está compuesto por seis entidades principales.

```

```
                Departamentos
                      │
                      │
                      │
                  Empleados
               ╱      │      ╲
              ╱       │       ╲
             ▼        ▼        ▼
        Puestos   Salarios  Ausentismo
                         │
                         ▼
                   Evaluaciones
```

---

# Entidades

## Empleados

Representa la entidad principal del modelo.

Contiene la información básica de cada colaborador y actúa como punto de integración con el resto de las tablas.

Información almacenada:

- Identificador del empleado
- Nombre
- Fecha de ingreso
- Departamento
- Puesto

---

## Departamentos

Define la estructura organizacional de la empresa.

Permite agrupar empleados y construir indicadores por área.

Ejemplos:

- Recursos Humanos
- Finanzas
- Tecnología
- Comercial
- Operaciones

---

## Puestos

Describe el cargo ocupado por cada empleado.

Se utiliza para segmentar información y enriquecer el análisis organizacional.

---

## Salarios

Almacena la información salarial correspondiente a cada empleado.

Permite analizar:

- salario actual
- bonos
- ajustes
- distribución salarial

---

## Ausentismo

Registra las ausencias de los empleados.

Esta entidad permite construir indicadores relacionados con:

- cantidad de ausencias
- días perdidos
- motivos
- comportamiento por departamento

---

## Evaluaciones

Contiene los resultados de las evaluaciones de desempeño.

Permite analizar:

- desempeño individual
- desempeño por departamento
- categorías de evaluación
- evolución del rendimiento

---

# Relaciones

El modelo utiliza claves primarias y foráneas para garantizar la integridad referencial entre las entidades.

Las relaciones permiten navegar la información desde la entidad Empleados hacia el resto del modelo sin generar duplicidad de datos.

---

# Principios de Diseño

Durante el diseño del modelo se priorizaron los siguientes criterios:

- Integridad referencial.
- Eliminación de redundancias.
- Consistencia entre entidades.
- Facilidad de mantenimiento.
- Escalabilidad.
- Preparación para análisis en Power BI.

---

# Capa Analítica

El modelo relacional no es consumido directamente por Power BI.

Sobre este modelo se construye una capa de vistas SQL que encapsula la lógica de negocio necesaria para el análisis.

Este enfoque permite:

- mantener consultas reutilizables;
- reducir transformaciones en Power BI;
- centralizar la lógica de negocio en PostgreSQL;
- facilitar futuras modificaciones sin afectar el dashboard.

---

# Resultado

El resultado es un modelo relacional organizado, consistente y preparado para soportar procesos analíticos, sirviendo como base para la generación de indicadores y visualizaciones en Power BI.