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

metodología o arquitectura
## Principio de conexión a BI: solo vistas, nunca tablas base

Como parte de la arquitectura del pipeline, Power BI (y cualquier herramienta de 
BI o reporting) se conecta **exclusivamente a vistas del schema `core`**, nunca 
directamente a las tablas de producción.

### Por qué

- **Control de exposición**: las vistas definen explícitamente qué columnas se 
  exponen, evitando arrastrar tipos de datos incompatibles (ej. `geometry` de 
  PostGIS, que Power BI no puede interpretar) o columnas técnicas/sensibles que 
  no aportan al reporte.
- **Lógica centralizada**: cálculos, JOINs y transformaciones viven en SQL, no 
  en Power Query (M). Un cambio en la lógica de negocio se actualiza una vez en 
  la vista y se propaga a todos los reportes que la consumen.
- **Consistencia con el patrón de staging**: extiende el mismo principio de 
  separación de capas usado en el pipeline (staging → producción → vistas) 
  también a la capa de consumo/BI.
- **Rendimiento**: las vistas pueden aprovechar índices y optimizaciones de 
  Postgres, más eficiente que replicar la misma lógica en Power Query.

### Flujo de trabajo

Si un dashboard necesita un dato o combinación que no existe en las vistas 
actuales:

1. Escribir `CREATE VIEW` / `CREATE OR REPLACE VIEW` en el schema `core`
2. Validar con `SELECT * FROM core.vw_nueva LIMIT 10` en DBeaver antes de 
   conectar
3. Conectar la vista (no la tabla) a Power BI

**Excepción**: análisis exploratorios puntuales y descartables, sin destino en 
un reporte final, pueden trabajarse directo sobre tablas — pero cualquier dato 
que alimente un dashboard mantenido en el tiempo pasa siempre por una vista.
