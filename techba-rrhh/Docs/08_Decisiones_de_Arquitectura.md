# 08_Decisiones_de_Arquitectura.md

# Decisiones de Arquitectura

## Objetivo

Este documento reúne las principales decisiones técnicas adoptadas durante el desarrollo del proyecto y el razonamiento detrás de cada una: qué alternativas se consideraron y por qué se descartaron. Para el detalle de **cómo** está implementada la arquitectura (esquemas, flujo, vistas), ver `03_Arquitectura.md`.

---

# PostgreSQL como núcleo del proyecto

**Alternativa considerada:** resolver la limpieza y las transformaciones dentro de Power Query / DAX, usando PostgreSQL solo como repositorio de datos crudos.

**Por qué se descartó:** distribuir la lógica de negocio entre SQL, Power Query y DAX dificulta la auditoría y duplica reglas en distintos lenguajes. Centralizar en PostgreSQL mantiene una única fuente de verdad, facilita la auditoría y reduce la complejidad del modelo de Power BI.

---

# Separación entre Staging y Core

**Alternativa considerada:** limpiar y transformar los datos directamente sobre las tablas de origen, sin un esquema intermedio.

**Por qué se descartó:** modificar los datos crudos in-place elimina la posibilidad de auditar o reprocesar desde el origen si se detecta un error en una transformación posterior. Separar `staging` (datos tal como fueron recibidos, sin transformaciones) de `core` (modelo relacional definitivo, post-validación) preserva esa trazabilidad.

---

# Vistas como capa de consumo

**Alternativa considerada:** conectar Power BI directamente a las tablas del esquema `core`, replicando la lógica de negocio en medidas DAX.

**Por qué se descartó:** exponer tablas base obliga a reconstruir la misma lógica en Power BI, lo que genera duplicación y dificulta el mantenimiento cuando cambia una regla de negocio. Consumir exclusivamente vistas SQL permite reutilizar consultas, centralizar las reglas y simplificar el modelo analítico.

---

# Tratamiento de datos faltantes

Durante la auditoría se detectaron registros con información incompleta.

Al no existir reglas de negocio definidas para imputar dichos valores, se decidió preservar la información original y documentar las incidencias detectadas.

Esta decisión evita introducir supuestos sin respaldo funcional.

---

# Biblioteca de utilidades

Las tareas repetitivas de limpieza y validación utilizan una biblioteca privada de funciones PostgreSQL reutilizables.

Estas funciones forman parte del entorno de desarrollo y no se incluyen en este repositorio.

La lógica específica del proyecto permanece completamente documentada.

---

# Trazabilidad

Cada transformación realizada durante el proyecto puede identificarse y justificarse.

Las incidencias detectadas fueron documentadas y las modificaciones aplicadas pueden reproducirse siguiendo el mismo flujo de trabajo.

---

# Reproducibilidad

El proyecto fue diseñado para que todas las etapas puedan ejecutarse nuevamente siguiendo el mismo flujo detallado en `03_Arquitectura.md` (CSV → Staging → Limpieza → Validación → Modelo Relacional → Vistas SQL → Power BI). La lógica específica del proyecto está completamente documentada y es reproducible; algunas funciones utilitarias de uso interno (ver sección "Biblioteca de utilidades") no se incluyen en este repositorio, por lo que la reproducción exacta punto por punto requiere reconstruirlas o reemplazarlas por su equivalente en SQL estándar.

---

# Conclusión

La arquitectura implementada prioriza la calidad de los datos, la mantenibilidad y la reutilización, permitiendo construir una base sólida para proyectos de Business Intelligence.