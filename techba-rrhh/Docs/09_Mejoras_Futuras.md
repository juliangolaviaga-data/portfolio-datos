# 09_Mejoras_Futuras.md

# Mejoras Futuras

## Objetivo

Este documento reúne posibles líneas de evolución del proyecto para incrementar su nivel de automatización, escalabilidad y mantenibilidad.

Las siguientes mejoras no fueron implementadas por no formar parte del alcance del proyecto.

---

# Automatización del proceso ETL

Automatizar la carga de archivos utilizando Python para reducir tareas manuales y facilitar la actualización periódica de la información.

---

# Validaciones automáticas

Incorporar pruebas automáticas de calidad de datos para detectar inconsistencias antes de promover la información al esquema `core`.

---

# Orquestación

Programar la ejecución del pipeline mediante herramientas de orquestación como Apache Airflow o soluciones equivalentes.

---

# Versionado de datos

Implementar estrategias de versionado para conservar históricos de información y facilitar auditorías.

---

# Documentación automática

Generar documentación técnica del modelo de datos y de las transformaciones mediante herramientas especializadas.

---

# Escalabilidad

Adaptar la arquitectura para soportar nuevas entidades relacionadas con Recursos Humanos, manteniendo la misma metodología de preparación y validación de datos.

---

# Integración con nuevas fuentes

Incorporar nuevas fuentes de información, como archivos Excel, APIs o bases de datos transaccionales, reutilizando el pipeline de preparación desarrollado en este proyecto.

---

# Conclusión

La arquitectura implementada constituye una base sólida para futuros desarrollos y permite incorporar nuevas funcionalidades sin modificar los principios fundamentales del proyecto: centralizar la lógica de negocio en PostgreSQL, garantizar la calidad de los datos y exponer información preparada para herramientas de Business Intelligence.