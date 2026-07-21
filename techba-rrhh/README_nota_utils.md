## Nota sobre la librería de limpieza (`utils.*`)

Este repo **no incluye el código fuente** de la librería de limpieza de datos
(`libreria_limpieza_datos.sql`) ni del framework de controles de calidad
(`controles_calidad_pre_insert.sql`). Es una decisión de diseño intencional,
no un olvido: la idea es no exponer la implementación interna de las
funciones.

Lo que sí vas a encontrar en los scripts de migración es **cómo se invocan**
esas funciones y **qué validan/limpian**, por ejemplo:

```sql
utils.limpiar_fecha_generica(fecha_inicio, 'inicio')
utils.normalizar_booleano(justificado)
```

A grandes rasgos, la librería cubre:

- **Fechas**: formatos mixtos, ambigüedad DD/MM, fechas incompletas
- **Texto**: formato título, espacios, caracteres invisibles (NBSP/NNBSP)
- **Booleanos**: normalización de variantes (S/SI/si/N/NO/no, etc.)
- **Teléfono**: normalización de formato
- **Email**: validación de formato
- **Nulos**: normalización de variantes ("N/A", "Pendiente", "A confirmar", etc.)

Si cloná este repo y al correr un script de migración te aparece un error
tipo `función no existe`, es esperable: esas funciones viven en un módulo
`utils.*` que no está versionado acá a propósito, no es que el repo esté
incompleto por error.
