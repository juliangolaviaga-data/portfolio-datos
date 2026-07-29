# FashionStore — Documentación completa del proyecto

> Proyecto de portfolio de Julián (Córdoba, Argentina) — primer proyecto de su portfolio de Data Analytics, previo a TechBA. Pipeline completo: PostgreSQL → Power BI. Posicionamiento: Analista de Datos / Analytics Engineer, con PostgreSQL como capa de modelado/transformación y Power BI como capa de visualización.

---

## 1. Origen de los datos

El escenario simulado es el de un cliente (tienda de indumentaria/moda) que entrega **3 archivos exportados de un sistema legacy, sin ningún estándar de calidad**:

| Archivo | Filas | Problemas detectados |
|---|---|---|
| `clientes_arg.csv` (subido como `clientes.csv`) | 54 | 4 clientes duplicados, 1 email en mayúsculas, 1 nombre sin INITCAP correcto |
| `productos_arg.csv` (subido como `Productos.xlsx`) | 23 | 3 filas completamente vacías, 14 variantes de escritura sobre 5 categorías (TOPS/Tops/tops), 1 precio inválido ("N/A"), 9 nombres con espacios sucios al inicio/final, 1 stock vacío |
| `ventas_brutas_arg.csv` (subido como `ventas_brutas.csv`) | 300 | Typo crítico en fecha (`2024-06-2O`, con letra O en vez de cero), formato inválido (`21/06-2024`), **7 formatos de fecha distintos mezclados** |

**Columnas de cada archivo crudo:**
- `clientes`: cliente_id, nombre, email, telefono, ciudad, fecha_registro, segmento
- `productos`: producto_id, nombre, categoria, precio, stock, proveedor, activo (+ columna extra `REVISAR` en el Excel, usada para marcar filas vacías)
- `ventas_brutas`: order_id, fecha, cliente_id, producto_id, cantidad, precio_unitario, descuento, metodo_pago, estado

---

## 2. Arquitectura del pipeline

```
📂 CSVs/XLSX crudos del cliente
        ↓
🗄️ Tablas STAGING en PostgreSQL (sin restricciones de tipo, todo varchar)
        ↓
🔍 Exploración y diagnóstico SQL (documentar problemas antes de tocar nada)
        ↓
🧹 Limpieza y transformación SQL (INSERT INTO tablas de producción con CASTs y reglas de negocio)
        ↓
⚡ Power Query (transformaciones complementarias sobre datos ya limpios)
        ↓
📐 Tablas finales con PK, FK y tipos correctos
        ↓
📊 Power BI conectado directo a PostgreSQL
```

**Principio de staging como "zona de cuarentena":** todo se carga primero a tablas staging con columnas `varchar` sin restricciones, para poder diagnosticar el 100% de los problemas antes de definir tipos/PK/FK reales.

Herramientas: **PostgreSQL** (base de datos), **DBeaver** (cliente SQL para diagnóstico/limpieza/exploración), **Power BI Desktop** (conexión directa a PostgreSQL, sin pasar por Neon como en TechBA), **Power Query (M)** para transformaciones complementarias.

---

## 3. Tablas STAGING (staging_clientes, staging_productos, staging_ventas)

```sql
CREATE TABLE staging_clientes (
    cliente_id      varchar(10) NULL,
    nombre          varchar(100) NULL,
    email           varchar(100) NULL,
    telefono        varchar(30) NULL,
    ciudad          varchar(50) NULL,
    fecha_registro  varchar(20) NULL,
    segmento        varchar(20) NULL
);

CREATE TABLE staging_productos (
    producto_id varchar(10) NULL,
    nombre      varchar(100) NULL,
    categoria   varchar(50) NULL,
    precio      varchar(20) NULL,
    stock       varchar(10) NULL,
    proveedor   varchar(50) NULL,
    activo      varchar(5) NULL
);

CREATE TABLE staging_ventas (
    order_id        varchar(10) NULL,
    fecha           varchar(20) NULL,
    cliente_id      varchar(10) NULL,
    producto_id     varchar(10) NULL,
    cantidad        varchar(10) NULL,
    precio_unitario varchar(20) NULL,
    descuento       varchar(10) NULL,
    metodo_pago     varchar(20) NULL,
    estado          varchar(20) NULL
);
```

Todas las columnas quedan como `varchar` a propósito: el objetivo del staging es que **nada falle al cargar**, para poder diagnosticar los problemas reales con SQL antes de tipar nada.

---

## 4. Diagnóstico SQL (exploración, sin modificar nada todavía)

Queries reutilizables aplicadas a las 3 tablas staging:

- Conteo total de filas (`COUNT(*)`)
- Conteo de nulos/vacíos por columna (`COUNT(*) FILTER (WHERE col IS NULL OR col = '')`)
- Duplicados por ID (`GROUP BY id HAVING COUNT(*) > 1`)
- Filas completamente vacías (ID nulo o vacío)
- Valores únicos en columnas categóricas (`SELECT DISTINCT`)
- Valores no numéricos en columnas que deberían ser numéricas (regex `!~ '^[0-9]+(\.[0-9]+)?$'`)
- Espacios al inicio/final en texto (`col <> TRIM(col)`)
- Normalización de mayúsculas/minúsculas: emails que no están en `LOWER`, nombres/categorías que no están en `INITCAP`
- Integridad referencial: IDs de `ventas` que no existen en `clientes` o `productos`
- Rango de fechas (`MIN`/`MAX`) para detectar outliers de formato

**Hallazgos concretos por tabla:**

### staging_clientes (54 filas)
- 0 nulos en todas las columnas
- 4 IDs duplicados: `C001`, `C005`, `C010`, `C015` (cada uno 2 veces)
- Segmentos válidos: `nuevo`, `premium`, `regular`
- 1 email en mayúsculas: `TOMAS.ROMERO@gmail.COM` (cliente C010)
- 1 nombre sin capitalización correcta: `Lorena benítez` (cliente C039)
- Rango de fecha_registro: 2023-01-02 a 2023-12-23

### staging_productos (23 filas)
- 3 nulos/vacíos en **todas** las columnas simultáneamente (= 3 filas totalmente vacías)
- 3 IDs duplicados (filas vacías, mismo conteo)
- **14 variantes de escritura sobre solo 5 categorías reales**: faldas/Faldas, outerwear/Outerwear/OUTERWEAR, pantalones/Pantalones/PANTALONES, tops/Tops/TOPS, vestidos/Vestidos/VESTIDOS
- Valores de `activo`: vacío o `SI`
- 1 precio no numérico: producto `P009` con precio = `"N/A"`
- 9 filas con espacios sucios al inicio/final en `nombre` (afectando también en algunos casos `categoria`): P004, P005, P010, P011, P012, P014, P016, P018, P020
- 1 stock vacío: producto P016 (Cardigan)
- Nombres sin INITCAP correcto: P001 (Remera Básica), P007 (Campera de Cuero)
- Categorías sin INITCAP correcto: P001, P002, P004, P007, P008, P015

### staging_ventas (300 filas)
- 0 nulos en todas las columnas
- Métodos de pago válidos: `efectivo`, `tarjeta`, `transferencia`
- Estados válidos: `cancelado`, `completado`, `pendiente`
- 0 valores no numéricos en `cantidad` y `precio_unitario`
- 0 problemas de espacios sucios
- 0 problemas de integridad referencial (todos los `cliente_id` y `producto_id` de ventas existen en las tablas maestras)
- **Rango de fechas devuelto como texto (`MIN`/`MAX` sobre varchar) mostró el problema más grave del dataset: `01-02-2025` a `Sep 30 2024`** → confirmó que había múltiples formatos de fecha mezclados en la misma columna, incluyendo:
  1. Typo: `2024-06-2O` (letra O en vez de cero al final del día)
  2. `01 Oct 2025` (día + mes en texto + año)
  3. `Apr 20 2024` (mes en texto + día + año)
  4. `2026-07-07` o `2026/07/07` (ISO estándar)
  5. `07-07-2026` o `07/07/2026` (DD-MM-YYYY clásico)
  6. `15.02.2024` (con puntos)
  7. `07/07/26` (año corto)
  8. `2026-07-07 10:51:00` (con hora incorporada)

---

## 5. Limpieza SQL — decisiones de negocio (staging → producción)

Tabla de decisiones documentada en el portfolio (cada limpieza tiene una justificación de negocio explícita, no se inventan valores):

| Problema | Solución SQL | Decisión de negocio |
|---|---|---|
| Duplicados en clientes | `DISTINCT ON (cliente_id)` | Se conserva la primera ocurrencia |
| Email en mayúsculas | `LOWER(email)` | Normalización estándar |
| Categorías inconsistentes | `INITCAP(categoria)` | Estandarización con mayúscula inicial |
| Nombres con espacios | `TRIM(nombre)` | Limpieza de espacios al inicio y final |
| Precio "N/A" | `CASE WHEN precio = 'N/A' THEN NULL` | **Null es más honesto que inventar un valor** (mismo principio que en TechBA con los sueldos faltantes) |
| Stock vacío | `CASE WHEN stock = '' THEN NULL` (nota: el portfolio dice "asume 0" pero el SQL real deja `NULL`) | Sin registro de stock se deja explícito el faltante |
| Typo en fecha | Regex `~ '^\d{4}-\d{2}-2O$'` + `REPLACE('2O','20')` | Corrección quirúrgica del error puntual detectado |
| Filas vacías | `WHERE producto_id IS NOT NULL AND producto_id <> ''` | Exclusión de filas sin datos utilizables |

### Tablas de producción (PostgreSQL)

```sql
CREATE TABLE clientes (
    cliente_id      VARCHAR(5)   PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    telefono        VARCHAR(20),
    ciudad          VARCHAR(50),
    fecha_registro  DATE,
    segmento        VARCHAR(20)
);

CREATE TABLE productos (
    producto_id     VARCHAR(5)   PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    precio          NUMERIC(10,2),
    stock           INTEGER      DEFAULT 0,
    proveedor       VARCHAR(50),
    activo          VARCHAR(3)
);

CREATE TABLE ventas (
    order_id        INTEGER       PRIMARY KEY,
    fecha           DATE          NOT NULL,
    cliente_id      VARCHAR(5)    REFERENCES clientes(cliente_id),
    producto_id     VARCHAR(5)    REFERENCES productos(producto_id),
    cantidad        INTEGER,
    precio_unitario NUMERIC(12,2),
    descuento       NUMERIC(4,2),
    metodo_pago     VARCHAR(20),
    estado          VARCHAR(10),
    -- Columna calculada automática por PostgreSQL (GENERATED ALWAYS)
    ingreso_neto    NUMERIC(12,2) GENERATED ALWAYS AS (
                        ROUND(cantidad * precio_unitario * (1 - descuento / 100.0), 2)
                    ) STORED
);
```

**Punto destacado del modelo:** `ingreso_neto` es una **columna generada (STORED)**, calculada y mantenida automáticamente por el motor de PostgreSQL — nunca se actualiza manualmente ni se recalcula en DAX. Esto elimina la posibilidad de inconsistencias entre lo que se ve en el dashboard y lo que hay en la base. Es un patrón más "puro" que el de TechBA (donde las columnas de display con "Sin dato" se resuelven en DAX); acá la lógica de negocio del ingreso vive 100% en SQL.

### Carga de datos limpios (INSERT INTO)

- **Clientes:** `INSERT INTO clientes SELECT DISTINCT ON (cliente_id) ... ORDER BY cliente_id` con `LOWER(email)`, `fecha_registro::DATE`, `INITCAP(segmento)`. Filtra `cliente_id IS NOT NULL`.
- **Productos:** `INSERT INTO productos` (tabla nombrada `"Productos"` con mayúscula en el modelo final) con `TRIM(nombre)`, `INITCAP(categoria)`, `CASE WHEN precio = 'N/A' THEN NULL ELSE precio::NUMERIC(10,2)`, `CASE WHEN stock = '' THEN NULL ELSE stock::INTEGER`, `TRIM(proveedor)`, `UPPER(activo)`.
- **Ventas:** `INSERT INTO ventas` con un `CASE` de **8 ramas** que detecta y parsea cada uno de los 7 formatos de fecha + el typo corregido, usando `TO_DATE` con distintas máscaras según el patrón regex detectado (dejando `NULL` como fallback de seguridad si aparece un formato nuevo no contemplado). Filtra por integridad referencial: solo inserta filas cuyo `cliente_id` y `producto_id` ya existen en las tablas maestras limpias.

---

## 6. Power Query — transformaciones complementarias

Con Power BI conectado directo a PostgreSQL, Power Query se usó para pulir aún más los datos ya limpios en SQL:

- **ventas_brutas:**
  - Unificación de los 7 formatos de fecha con una fórmula M personalizada (capa adicional sobre lo ya resuelto en SQL)
  - Detección de formato inválido tipo `YYYY-DD-MM`
  - Columna `ingreso_neto` recalculada = `cantidad × precio × (1 − descuento)` (redundante con la columna generada de SQL, usada como control cruzado / capa de M)
- **productos:**
  - Recorte de espacios con `Text.Trim`
  - Categorías con "En mayúscula inicial" (Capitalize Each Word)
  - Reemplazo de `"N/A"` por `null` en precio
- **clientes:**
  - Normalización de emails a minúsculas
  - Eliminación de duplicados por `cliente_id`
  - Resultado final: **50 clientes únicos** (de los 54 originales, se eliminaron los 4 duplicados)

---

## 7. Modelo relacional final

```
clientes                    ventas                       productos
─────────────                ─────────────                 ─────────────
cliente_id (PK)  ──1────*──  cliente_id (FK)               producto_id (PK)
nombre                       order_id (PK)     ──*────1──   producto_id (FK)
email                        producto_id (FK)               nombre
telefono                     fecha                          categoria
ciudad                       cantidad                       precio
fecha_registro                precio_unitario                stock
segmento                     descuento                     proveedor
                             metodo_pago                   activo
                             estado
                             ingreso_neto (GENERATED)
```

Esquema simple de estrella: `ventas` como tabla de hechos, `clientes` y `productos` como dimensiones, ambas relaciones 1-a-muchos. A diferencia de TechBA (que usa un esquema `core` con vistas como capa de exposición obligatoria), en FashionStore Power BI se conecta directo a las tablas de producción **y** a un set de vistas adicionales (ver sección 9) — es un patrón más simple, sin la regla arquitectónica formal de "solo vistas" que sí se documentó en TechBA.

---

## 8. Consultas de negocio (SQL) — bloque de análisis

Antes de pasar a Power BI, se construyó un bloque completo de consultas de negocio directamente en SQL, organizadas en:

**KPIs generales:**
```sql
SELECT
    COUNT(*)                     AS total_ordenes,
    SUM(ingreso_neto)            AS total_ventas,
    ROUND(AVG(ingreso_neto), 2)  AS ticket_promedio,
    COUNT(DISTINCT cliente_id)   AS clientes_activos,
    COUNT(DISTINCT producto_id)  AS productos_vendidos
FROM ventas;
```
Resultado: **300 órdenes, $5.879.330 en ventas totales, $19.597 de ticket promedio, 50 clientes activos.**

**Análisis de clientes:** top 10 por ingreso, ventas por segmento (con `%` sobre el total usando `SUM() OVER()`), clientes sin compras (`LEFT JOIN ... WHERE v.order_id IS NULL`).

**Análisis de productos:** top 10 por ingreso, ventas por categoría, productos sin ventas.

**Análisis temporal:** ventas mensuales, comparativo año a año, mejor mes de cada año (`DISTINCT ON`).

**Descuentos y pagos:** impacto de cada nivel de descuento (venta bruta vs. neta vs. monto descontado), ventas por método de pago.

---

## 9. SQL avanzado (CTEs, Window Functions, Subqueries)

- **CTE + NTILE(3):** segmenta clientes automáticamente en terciles de valor (Alto/Medio/Bajo Valor) según `total_compras`, usando `RANK()` para el ranking y `NTILE(3)` para la categoría.
- **Productos sobre el promedio:** CTE que calcula el promedio general de `ingreso_neto` y compara cada producto contra él (`veces_sobre_promedio`).
- **Running total mensual:** `SUM(SUM(ingreso_neto)) OVER (ORDER BY mes)` para ventas acumuladas.
- **RANK() PARTITION BY categoría:** ranking de productos dentro de cada categoría.
- **LAG() — variación mes a mes (MoM%):** compara cada mes contra el anterior, con `NULLIF` para evitar división por cero.
- **Subquery de pertenencia:** clientes que compraron en 2024 **y** en 2025 (doble `IN`).
- **Subquery correlacionada:** órdenes por encima del ticket promedio general.
- **Subquery con RANK + filtro externo:** top producto por ciudad de cliente (`WHERE rk = 1`).

---

## 10. Vistas para Power BI

Se crearon **4 vistas** en PostgreSQL que Power BI consume directamente. Cuando los datos se actualizan, alcanza con un "Actualizar" en Power BI — las vistas recalculan todo automáticamente:

| Vista | Contenido | Uso en el dashboard |
|---|---|---|
| `v_resumen_ejecutivo` | KPIs generales del negocio (total órdenes, clientes activos, total ventas, ticket promedio, tasa de cancelación %) | Tarjetas del dashboard ejecutivo |
| `v_tendencia_mensual` | Ventas por mes + acumulado + variación MoM% | Gráfico de tendencia |
| `v_ventas_cliente` | Métricas por cliente (órdenes, compras totales, ticket promedio, primera/última compra) | Tabla de top clientes |
| `v_ventas_producto` | Métricas por producto + % sobre el total | Gráfico de productos |

Nota técnica: en el script, estas vistas apuntan a `ventas_brutas` y `"Productos"` (con mayúscula) como nombres de tabla base — sugiere que en algún punto del desarrollo se renombraron/mantuvieron alias distintos a los de las tablas de staging originales; vale la pena revisar en el repo real cuál es el nombre definitivo de la tabla de hechos en producción (`ventas` vs `ventas_brutas`).

---

## 11. Power BI — Medidas DAX

6 medidas calculadas que alimentan los KPIs de ambos dashboards:

| Medida | Fórmula | Para qué sirve |
|---|---|---|
| Total Ventas | `SUM(ingreso_neto)` | KPI principal |
| Total Órdenes | `DISTINCTCOUNT(order_id)` | Volumen de operaciones |
| Ticket Promedio | `DIVIDE(Total Ventas, Total Órdenes)` | Valor promedio por orden |
| Clientes Activos | `DISTINCTCOUNT(cliente_id)` | Alcance del negocio |
| Tasa Cancelación | `DIVIDE(canceladas, total)` | Indicador de riesgo |
| % Sobre Total | `DIVIDE(ventas producto, ALL ventas)` | Participación por producto |

---

## 12. Dashboards Power BI

### Dashboard Ejecutivo
- 6 KPIs clave: ventas, órdenes, ticket, clientes, tasa de cancelación, producto líder
- Ranking de los 10 clientes por ingreso neto
- Distribución por segmento: **Premium 52%, Regular 38%, Nuevo 10%**
- Ventas por categoría: **Outerwear domina con $2.809.845**
- Clientes por ciudad, con mayor concentración en **Lomas de Zamora y San Telmo**

### Dashboard de Ventas
- Seguimiento de órdenes por estado: **243 completadas, 33 pendientes, 24 canceladas**
- Top 10 productos por % de participación en ventas
- Tendencia mensual de ventas durante 2024
- Detalle de las 10 órdenes de mayor valor
- Distribución por método de pago: **tarjeta 61,6% · transferencia 16% · efectivo 22,4%**

---

## 13. Resultados / storytelling del proyecto (para presentar a clientes)

- **$5.879.330** en ventas totales
- **300** órdenes procesadas
- **50** clientes activos
- **8%** de tasa de cancelación
- **Outerwear** representa el **47%** del total de ventas
- **Tapado Invierno** lidera con **16,5%** de participación sobre el total
- **80,6%** de las órdenes se completaron exitosamente
- **Tarjeta** es el método de pago dominante (61,6%)
- **Marzo y septiembre** son los picos de facturación del año
- **Lomas de Zamora y San Telmo** concentran la mayor cantidad de clientes

---

## 14. Stack tecnológico

- **PostgreSQL** — base de datos relacional: staging, limpieza con DDL/DML, modelo final con PK/FK, columnas generadas y vistas
- **DBeaver** — cliente SQL: gestión de esquemas, ejecución de queries de diagnóstico y limpieza, exploración del modelo
- **Power BI Desktop** — conexión directa a PostgreSQL (no vía Neon como en TechBA), modelado relacional, medidas DAX, dos dashboards interactivos
- **Power Query (M)** — transformaciones complementarias: fechas, tipos de datos, normalización de texto, columnas calculadas

**SQL aplicado (resumen técnico):** DDL · DML · CTEs · Window Functions (`RANK`, `LAG`, `LEAD`, `NTILE`) · Subqueries correlacionadas · Vistas · Columnas generadas (`GENERATED ALWAYS ... STORED`) · `DISTINCT ON` · `CASE WHEN`

---

## 15. Comparación de patrones: FashionStore vs. TechBA

| Aspecto | FashionStore (1er proyecto) | TechBA (2do proyecto) |
|---|---|---|
| Dataset | E-commerce de moda (ficticio) | HR analytics (ficticio) |
| Hosting DB | PostgreSQL local / DBeaver | PostgreSQL en Neon |
| Conexión Power BI | Directa a PostgreSQL (tablas + vistas) | Solo a vistas del esquema `core` (regla arquitectónica formal) |
| Manejo de nulos | `NULL` explícito (precio N/A, stock vacío) — "null es más honesto que inventar" | Columnas DAX con fallback "Sin dato" + columnas numéricas preservadas para KPIs |
| Cálculo de métrica clave | `ingreso_neto` como columna **generada por PostgreSQL** (STORED) | Cálculos vía DAX sobre vistas `core` |
| Fechas sucias | 7 formatos distintos + 1 typo, resueltos con `CASE` de 8 ramas y regex | No documentado como problema mayor |
| Categorías inconsistentes | 14 variantes de escritura → `INITCAP` | `categoria` en evaluaciones corregida por thresholds numéricos |
| Vistas para BI | 4 vistas (`v_resumen_ejecutivo`, `v_tendencia_mensual`, `v_ventas_cliente`, `v_ventas_producto`) | Vistas `core vw_...` como única superficie de exposición |
| Dashboards | 2 páginas (Ejecutivo, Ventas) | 2 páginas (Dotación y Ausentismo, Evaluaciones de Desempeño) |

Este cuadro es útil para mostrarle a otra IA (o a un cliente técnico) la evolución de criterio entre el primer y el segundo proyecto del portfolio: de un modelo más simple con lógica en columnas generadas SQL, a un modelo con arquitectura de vistas más formal y gobernanza explícita de la capa de exposición.
Es esperable y correcto que FashionStore tenga menor complejidad arquitectónica que TechBA: es el proyecto fundacional del portfolio, mientras que TechBA ya incorpora aprendizajes y buenas prácticas más 
avanzadas (gobernanza de vistas, manejo de nulos con doble capa, modelado geoespacial, etc.). La simplicidad de FashionStore no es una carencia sino el punto de partida que muestra la progresión de nivel 
entre ambos proyectos.
---

*Documento generado a partir de: `FashionStore_-_Portfolio_de_Datos.html`, `limpieza_datos_fashionstore.sql`, `clientes.csv`, `Productos.xlsx`, `ventas_brutas.csv`, subidos el 28/07/2026.*
