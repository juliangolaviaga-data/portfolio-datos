----------------------------------------Tablas Staging----------------------------------------

CREATE TABLE staging_clientes (
	cliente_id 		varchar(10) NULL,
	nombre		 	varchar(100) NULL,
	email 			varchar(100) NULL,
	telefono 		varchar(30) NULL,
	ciudad 			varchar(50) NULL,
	fecha_registro 	varchar(20) NULL,
	segmento 		varchar(20) NULL
);

CREATE TABLE staging_productos (
	producto_id varchar(10) NULL,
	nombre		varchar(100) NULL,
	categoria 	varchar(50) NULL,
	precio 		varchar(20) NULL,
	stock 		varchar(10) NULL,
	proveedor 	varchar(50) NULL,
	activo 		varchar(5) NULL
);

CREATE TABLE staging_ventas (
	order_id		varchar(10) NULL,
	fecha 			varchar(20) NULL,
	cliente_id 		varchar(10) NULL,
	producto_id 	varchar(10) NULL,
	cantidad 		varchar(10) NULL,
	precio_unitario varchar(20) NULL,
	descuento 		varchar(10) NULL,
	metodo_pago 	varchar(20) NULL,
	estado 			varchar(20) NULL
);

-----------------------------------------------------------------------------------------

----------------------------------------Clientes----------------------------------------
SELECT COUNT(*) AS total_filas FROM staging_clientes sc;
--54

SELECT
    COUNT(*) FILTER (WHERE sc.cliente_id IS NULL OR sc.cliente_id = '') AS nulos_cliente_id,--0
    COUNT(*) FILTER (WHERE sc.nombre IS NULL OR sc.nombre = '') AS nulos_nombre,--0
    COUNT(*) FILTER (WHERE sc.email IS NULL OR sc.email = '') AS nulos_email,--0
    COUNT(*) FILTER (WHERE sc.telefono IS NULL OR sc.telefono = '') AS nulos_telefono,--0
    COUNT(*) FILTER (WHERE sc.ciudad IS NULL OR sc.ciudad = '') AS nulos_ciudad,--0
    COUNT(*) FILTER (WHERE sc.fecha_registro IS NULL OR sc.fecha_registro = '') AS nulos_fecha_registro,--0
    COUNT(*) FILTER (WHERE sc.segmento IS NULL OR sc.segmento = '') AS nulos_segmento--0
FROM staging_clientes sc;

SELECT sc.cliente_id, COUNT(*) AS repeticiones
FROM staging_clientes sc
GROUP BY sc.cliente_id
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;
/*
	C001	2
	C005	2
	C010	2
	C015	2
*/

SELECT COUNT(*) AS filas_vacias
FROM staging_clientes sc
WHERE sc.cliente_id IS NULL OR sc.cliente_id = '';
--0

SELECT DISTINCT sc.segmento
FROM staging_clientes sc
ORDER BY 1;
/*
	nuevo
	premium
	regular
 */

SELECT sc.*
FROM staging_clientes sc
WHERE sc.nombre <> TRIM(sc.nombre)
or sc.email <> TRIM(sc.email)
or sc.telefono <> TRIM(sc.telefono)
or sc.ciudad <> TRIM(sc.ciudad)
or sc.fecha_registro <> TRIM(sc.fecha_registro)
or sc.segmento <> TRIM(sc.segmento)
--0 registros

SELECT sc.cliente_id , sc.email 
FROM staging_clientes sc
WHERE sc.email <> LOWER(sc.email);
--C010	TOMAS.ROMERO@gmail.COM

SELECT sc.* 
FROM staging_clientes sc
WHERE sc.nombre ~ '^[A-Z]' 
  AND sc.nombre <> INITCAP(sc.nombre);
--C039	Lorena benítez	lorena.benitez@gmail.com	011-7912-4006	Núñez	2023-08-08	nuevo

select
    MIN(sc.fecha_registro) AS fecha_minima,
    MAX(sc.fecha_registro) AS fecha_maxima
FROM staging_clientes sc 
WHERE sc.fecha_registro IS NOT NULL AND sc.fecha_registro <> '';
--2023-01-02	2023-12-23
-----------------------------------------------------------------------------------------

----------------------------------------Productos----------------------------------------

SELECT COUNT(*) AS total_filas FROM staging_productos p;
--23

SELECT
    COUNT(*) FILTER (WHERE p.producto_id IS NULL OR p.producto_id = '') AS nulos_producto_id,--3
    COUNT(*) FILTER (WHERE p.nombre IS NULL OR p.nombre = '') AS nulos_nombre,--3
    COUNT(*) FILTER (WHERE p.categoria IS NULL OR p.categoria = '') AS nulos_categoria,--3
    COUNT(*) FILTER (WHERE p.precio IS NULL OR p.precio = '') AS nulos_precio,--3
    COUNT(*) FILTER (WHERE p.stock IS NULL OR p.stock = '') AS nulos_stock,--4
    COUNT(*) FILTER (WHERE p.proveedor IS NULL OR p.proveedor = '') AS nulos_proveedor,--3
    COUNT(*) FILTER (WHERE p.activo IS NULL OR p.activo = '') AS nulos_activo--3
FROM staging_productos p;

-- 2.3 Duplicados por ID. Solo en la columna que va a ser PRIMARY KEY de esa tabla
SELECT p.producto_id, COUNT(*) AS repeticiones
FROM staging_productos p
GROUP BY p.producto_id
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;
-- 3

-- 2.4 Filas completamente vacías. Buscar filas donde el ID principal es NULL o vacío — si no tiene ID, la fila no sirve para nada.
SELECT COUNT(*) AS filas_vacias
FROM staging_productos p
WHERE p.producto_id IS NULL OR p.producto_id = '';
--3

-- 2.5 Valores únicos en columnas categóricas. Son las columnas que deberían tener un conjunto limitado de valores posibles
SELECT DISTINCT p.categoria 
FROM staging_productos p
ORDER BY p.categoria;
/*
	faldas
	Faldas
	outerwear
	Outerwear
	OUTERWEAR
	pantalones
	Pantalones
	PANTALONES
	tops
	Tops
	TOPS
	vestidos
	Vestidos
	VESTIDOS
*/

SELECT DISTINCT p.activo
FROM staging_productos p
ORDER BY p.activo;
/*
	
	SI 
*/
-- 2.6 Valores no numéricos en columnas de número
SELECT p.producto_id, p.precio
FROM staging_productos p
WHERE p.precio IS NOT NULL
  AND p.precio !~ '^[0-9]+(\.[0-9]+)?$'
  AND p.precio <> '';
--P009	N/A

SELECT p.producto_id, p.stock
FROM staging_productos p
WHERE p.stock IS NOT NULL
  AND p.stock !~ '^[0-9]+(\.[0-9]+)?$'
  AND p.stock <> '';

-- 2.7 Espacios al inicio o al final en texto, para todos los campos de la tabla
SELECT p.*
FROM staging_productos p
WHERE producto_id <> TRIM(producto_id)
or nombre <> TRIM(nombre)
or categoria <> TRIM(categoria)
or precio <> TRIM(precio)
or stock <> TRIM(stock)
or proveedor <> TRIM(proveedor)
or activo <> TRIM(activo);
/*
	P004	  Jean Mom  	PANTALONES	5800	150	DenimAR	SI
	P005	  Vestido Casual  	vestidos	6500	90	ModaRos	SI
	P010	  Falda Mini  	faldas	3200	110	TextilBA	SI
	P011	  Falda Midi  	Faldas	4100	85	TextilBA	SI
	P012	  Camisa Oxford  	tops	8500	95	EleganAR	SI
	P014	  Pantal�n Chino  	Pantalones	5500	130	DenimAR	SI
	P016	  Cardigan  	outerwear	6800		ModaRos	SI
	P018	  Short Jean  	pantalones	3600	140	DenimAR	SI
	P020	  Maxi Vestido  	vestidos	8200	50	EleganAR	SI
*/

-- 2.8 En campos que necesiten todo mayuscula o minusculas (como ser email)
SELECT producto_id, activo
FROM staging_productos p
WHERE activo <> UPPER(activo);

--2.8.1 Para campos como nombre completo q necesiten q sea LETRA CAPITAL
SELECT p.producto_id , p.nombre 
FROM staging_productos p 
WHERE p.nombre ~ '^[A-Z]' 
  AND p.nombre <> INITCAP(p.nombre);
/*
	P007	Campera de Cuero
	P001	Remera B�sica Blanca
*/

SELECT p.producto_id , p.categoria
FROM staging_productos p 
WHERE p.categoria ~ '^[A-Z]' 
  AND p.categoria <> INITCAP(p.categoria);
/*
	P004	PANTALONES
	P007	OUTERWEAR
	P008	OUTERWEAR
	P015	VESTIDOS
	P001	TOPS
	P002	TOPS
*/
--------------------------------------------------------------------------------------
----------------------------------------Ventas----------------------------------------

-- 2.1 Conteo general. Verificar que se  cargaron las mismas filas que tiene el CSV original.
SELECT COUNT(v.*) AS total_filas FROM staging_ventas v;
--300

-- 2.2 Nulos por column. Detectar qué columnas tienen datos faltantes y cuántos.
SELECT
    COUNT(*) FILTER (WHERE v.order_id IS NULL OR v.order_id = '') AS nulos_order_id,--0
	COUNT(*) FILTER (WHERE v.fecha IS NULL OR v.fecha = '') AS nulos_fecha,--0
	COUNT(*) FILTER (WHERE v.cliente_id IS NULL OR v.cliente_id = '') AS nulos_cliente_id,--0
	COUNT(*) FILTER (WHERE v.producto_id IS NULL OR v.producto_id = '') AS nulos_producto_id,--0
	COUNT(*) FILTER (WHERE v.cantidad IS NULL OR v.cantidad = '') AS nulos_cantidad,--0
	COUNT(*) FILTER (WHERE v.precio_unitario IS NULL OR v.precio_unitario = '') AS nulos_precio_unitario,--0
	COUNT(*) FILTER (WHERE v.descuento IS NULL OR v.descuento = '') AS nulos_descuento,--0
	COUNT(*) FILTER (WHERE v.metodo_pago IS NULL OR v.metodo_pago = '') AS nulos_metodo_pago,--0
	COUNT(*) FILTER (WHERE v.estado IS NULL OR v.estado = '') AS nulos_estado--0
FROM staging_ventas v;

-- 2.4 Filas completamente vacías. Buscar filas donde el ID principal es NULL o vacío — si no tiene ID, la fila no sirve para nada.
SELECT COUNT(*) AS filas_vacias
FROM staging_ventas v
WHERE v.order_id IS NULL OR v.order_id = '';
--0

-- 2.5 Valores únicos en columnas categóricas. Son las columnas que deberían tener un conjunto limitado de valores posibles
SELECT DISTINCT v.metodo_pago
FROM staging_ventas v
ORDER BY v.metodo_pago;
/*
 	efectivo
	tarjeta
	transferencia
*/
SELECT DISTINCT v.estado
FROM staging_ventas v
ORDER BY v.estado;
/*
 	cancelado
	completado
	pendiente
*/

-- 2.6 Valores no numéricos en columnas de número
SELECT v.order_id, cantidad
FROM staging_ventas v
WHERE v.cantidad IS NOT NULL
  AND v.cantidad !~ '^[0-9]+(\.[0-9]+)?$'
  AND v.cantidad <> '';
--0

SELECT v.order_id, precio_unitario
FROM staging_ventas v
WHERE v.precio_unitario IS NOT NULL
  AND v.precio_unitario !~ '^[0-9]+(\.[0-9]+)?$'
  AND v.precio_unitario <> '';
--0

-- 2.7 Espacios al inicio o al final en texto, para todos los campos de la tabla
SELECT v.*
FROM staging_ventas v
WHERE v.order_id <> TRIM(v.order_id)
	or v.fecha <> TRIM(v.fecha)
	or v.cliente_id <> TRIM(v.cliente_id)
	or v.producto_id <> TRIM(v.producto_id)
	or v.cantidad <> TRIM(v.cantidad)
	or v.precio_unitario <> TRIM(v.precio_unitario)
	or v.descuento <> TRIM(v.descuento)
	or v.metodo_pago <> TRIM(v.metodo_pago)
	or v.estado <> TRIM(v.estado);
--0

-- 2.9 Integridad referencial
-- Reemplazá según tus tablas
SELECT DISTINCT v.cliente_id
FROM staging_ventas v
WHERE v.cliente_id  NOT IN (SELECT c.cliente_id FROM staging_clientes c);
--0

SELECT DISTINCT v.producto_id
FROM staging_ventas v
WHERE v.producto_id  NOT IN (SELECT p.producto_id  FROM staging_productos p);
--0

-- 2.10 Rango de fechas (para detectar fechas fuera de rango)
SELECT 
    MIN(v.fecha) AS fecha_minima,
    MAX(v.fecha) AS fecha_maxima
FROM staging_ventas v
WHERE v.fecha IS NOT NULL AND v.fecha <> '';
--01-02-2025	Sep 30 2024
--------------------------------------------------------------------------------------

--------------------------Tablas de Produccion----------------------------------------
-- TABLA Clientes
CREATE TABLE clientes (
    cliente_id      VARCHAR(5)   PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email       	VARCHAR(100),
    telefono        VARCHAR(20),
    ciudad          VARCHAR(50),
    fecha_registro  DATE,
    segmento        VARCHAR(20) 
);

-- TABLA Productos
CREATE TABLE productos (
    producto_id     VARCHAR(5)   PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    precio          NUMERIC(10,2),
    stock           INTEGER      DEFAULT 0,
    proveedor       VARCHAR(50),
    activo          VARCHAR(3)
);

-- TABLA Ventas
CREATE TABLE ventas (
    order_id        INTEGER       PRIMARY KEY,
    fecha           DATE          NOT NULL,
    cliente_id      VARCHAR(5)   REFERENCES clientes(cliente_id),
    producto_id     VARCHAR(5)   REFERENCES productos(producto_id),
    cantidad        INTEGER,
    precio_unitario NUMERIC(12,2),
    descuento 		NUMERIC(4,2),
    metodo_pago     VARCHAR(20),
    estado 			VARCHAR(10),
    -- Columna calculada automática (opcional)
    ingreso_neto    NUMERIC(12,2) GENERATED ALWAYS AS (
                        ROUND(cantidad * precio_unitario * (1 - descuento / 100.0), 2)
                    ) STORED
);

--Chequear que los regstros esten cargados correctamente
SELECT 'staging_clientes'  AS tabla, COUNT(*) AS filas FROM staging_clientes
UNION ALL
SELECT 'staging_productos' AS tabla, COUNT(*) AS filas FROM staging_productos
UNION ALL
SELECT 'staging_ventas'    AS tabla, COUNT(*) AS filas FROM staging_ventas;
--------------------------------------------------------------------------------------

----------------------------------LIMPIEZA DE DATOS-----------------------------------
--Eliminamos clientes duplicados, aseguramos id_cliente no null, guardamos todos los mail en lower, fecha en formato date y INITCAP en segmento 
insert into clientes
SELECT DISTINCT ON (sc.cliente_id)
    sc.cliente_id,
    sc.nombre,
    LOWER(sc.email),
    sc.telefono,
    sc.ciudad,
    sc.fecha_registro::DATE,
    INITCAP(sc.segmento)
FROM staging_clientes as sc
where sc.cliente_id is not null
ORDER BY cliente_id;

insert into Productos
select
	sp.producto_id,
	trim(sp.nombre),
	INITCAP(sp.categoria),
	case
		when sp.precio = 'N/A' then null
		ELSE sp.precio::NUMERIC(10,2) 
	END,
	case
		when sp.stock = '' then null
		ELSE sp.stock::INTEGER
	end,
	trim(sp.proveedor),
	UPPER(sp.activo)
from staging_productos sp
where sp.producto_id <> ''
and sp.producto_id  is not NULL
order by sp.producto_id

insert into ventas
SELECT 
    sv.order_id::INTEGER,
    CASE 
        -- 1. LIMPIEZA EXTRAORDINARIA: Corrige la letra 'O' por un cero '0' si viene al final de la fecha
        WHEN TRIM(sv.fecha) ~ '^\d{4}-\d{2}-2O$' 
            THEN TO_DATE(REPLACE(TRIM(sv.fecha), '2O', '20'), 'YYYY-MM-DD')

        -- 2. Formato: 01 Oct 2025 (Día Mes_Texto Año)
        WHEN TRIM(sv.fecha) ~ '^\d{2}\s[A-Za-z]{3}\s\d{4}' 
            THEN TO_DATE(TRIM(sv.fecha), 'DD Mon YYYY')

        -- 3. Formato: Apr 20 2024 (Mes_Texto Día Año)
        WHEN TRIM(sv.fecha) ~ '^[A-Za-z]{3}\s\d{2}\s\d{4}' 
            THEN TO_DATE(TRIM(sv.fecha), 'Mon DD YYYY')

        -- 4. Formato estándar: 2026-07-07 o 2026/07/07
        WHEN TRIM(sv.fecha) ~ '^\d{4}[-/]\d{2}[-/]\d{2}' 
            THEN TO_DATE(TRIM(sv.fecha), 'YYYY-MM-DD')
        
        -- 5. Formato clásico: 07-07-2026 o 07/07/2026
        WHEN TRIM(sv.fecha) ~ '^\d{2}[-/]\d{2}[-/]\d{4}' 
            THEN TO_DATE(TRIM(sv.fecha), 'DD-MM-YYYY')

        -- 6. Formato con puntos: 15.02.2024
        WHEN TRIM(sv.fecha) ~ '^\d{2}\.\d{2}\.\d{4}' 
            THEN TO_DATE(TRIM(sv.fecha), 'DD.MM.YYYY')
        
        -- 7. Formato corto: 07/07/26
        WHEN TRIM(sv.fecha) ~ '^\d{2}[-/]\d{2}[-/]\d{2}$' 
            THEN TO_DATE(TRIM(sv.fecha), 'DD-MM-YY')

        -- 8. Formato con hora incorporada: 2026-07-07 10:51:00
        WHEN TRIM(sv.fecha) ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}' 
            THEN CAST(TRIM(sv.fecha) AS TIMESTAMP)::DATE

        -- Mantenemos el NULL de seguridad por si en el futuro entra un formato nuevo
        ELSE NULL 
    END AS fecha_limpia,
    sv.cliente_id, 
    sv.producto_id, 
    sv.cantidad::INTEGER,
    sv.precio_unitario::NUMERIC(10,2), 
    sv.descuento::NUMERIC(4,2), 
    INITCAP(sv.metodo_pago), 
    INITCAP(sv.estado)
FROM staging_ventas sv
WHERE cliente_id IN (SELECT cliente_id FROM clientes)
  AND producto_id IN (SELECT producto_id FROM productos);

-- VERIFICACIÓN GENERAL DE TABLAS
SELECT 'clientes'  AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL
SELECT 'productos' AS tabla, COUNT(*) AS filas FROM productos
UNION ALL
SELECT 'ventas'    AS tabla, COUNT(*) AS filas FROM ventas;

-- ============================================================
-- BLOQUE 3: CONSULTAS DE NEGOCIO
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 KPIs GENERALES
-- ------------------------------------------------------------

-- Total de ventas, órdenes y ticket promedio
SELECT
    COUNT(*)                          AS total_ordenes,
    SUM(ingreso_neto)                 AS total_ventas,
    ROUND(AVG(ingreso_neto), 2)       AS ticket_promedio,
    COUNT(DISTINCT cliente_id)        AS clientes_activos,
    COUNT(DISTINCT producto_id)       AS productos_vendidos
FROM ventas;

-- Ventas por estado
SELECT
    estado,
    COUNT(*)                                    AS cantidad,
    SUM(ingreso_neto)                           AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM ventas
GROUP BY estado
ORDER BY cantidad DESC;

-- ------------------------------------------------------------
-- 3.2 ANÁLISIS DE CLIENTES
-- ------------------------------------------------------------

-- Top 10 clientes por ingreso
SELECT
    c.nombre,
    c.ciudad,
    c.segmento,
    COUNT(v.order_id)           AS total_ordenes,
    SUM(v.ingreso_neto)         AS total_compras,
    ROUND(AVG(v.ingreso_neto), 2) AS ticket_promedio
FROM ventas v
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nombre, c.ciudad, c.segmento
ORDER BY total_compras DESC
LIMIT 10;

-- Ventas por segmento
SELECT
    c.segmento,
    COUNT(DISTINCT c.cliente_id)    AS cantidad_clientes,
    COUNT(v.order_id)               AS total_ordenes,
    SUM(v.ingreso_neto)             AS total_ventas,
    ROUND(SUM(v.ingreso_neto) * 100.0 / SUM(SUM(v.ingreso_neto)) OVER(), 2) AS porcentaje_ventas
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
GROUP BY c.segmento
ORDER BY total_ventas DESC;

-- Clientes sin compras
SELECT
    c.cliente_id,
    c.nombre,
    c.segmento,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
WHERE v.order_id IS NULL;

-- ------------------------------------------------------------
-- 3.3 ANÁLISIS DE PRODUCTOS
-- ------------------------------------------------------------

-- Top 10 productos por ingreso
SELECT
    p.nombre,
    p.categoria,
    COUNT(v.order_id)               AS veces_vendido,
    SUM(v.cantidad)                 AS unidades_vendidas,
    SUM(v.ingreso_neto)             AS ingreso_total,
    ROUND(SUM(v.ingreso_neto) * 100.0 / SUM(SUM(v.ingreso_neto)) OVER(), 2) AS pct_sobre_total
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
GROUP BY p.nombre, p.categoria
ORDER BY ingreso_total DESC
LIMIT 10;

-- Ventas por categoría
SELECT
    p.categoria,
    COUNT(v.order_id)               AS total_ordenes,
    SUM(v.cantidad)                 AS unidades_vendidas,
    SUM(v.ingreso_neto)             AS ingreso_total,
    ROUND(SUM(v.ingreso_neto) * 100.0 / SUM(SUM(v.ingreso_neto)) OVER(), 2) AS porcentaje
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
GROUP BY p.categoria
ORDER BY ingreso_total DESC;

-- Productos sin ventas
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.stock
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
WHERE v.order_id IS NULL;

-- ------------------------------------------------------------
-- 3.4 ANÁLISIS TEMPORAL
-- ------------------------------------------------------------

-- Ventas mensuales 2024-2025
SELECT
    DATE_TRUNC('month', fecha)      AS mes,
    TO_CHAR(fecha, 'Mon YYYY')      AS periodo,
    COUNT(*)                        AS total_ordenes,
    SUM(ingreso_neto)               AS total_ventas,
    ROUND(AVG(ingreso_neto), 2)     AS ticket_promedio
FROM ventas
GROUP BY DATE_TRUNC('month', fecha), TO_CHAR(fecha, 'Mon YYYY')
ORDER BY mes;

-- Comparativo año a año
SELECT
    EXTRACT(YEAR FROM fecha)        AS anio,
    COUNT(*)                        AS total_ordenes,
    SUM(ingreso_neto)               AS total_ventas,
    ROUND(AVG(ingreso_neto), 2)     AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(YEAR FROM fecha)
ORDER BY anio;

-- Mejor mes de cada año
SELECT DISTINCT ON (anio)
    EXTRACT(YEAR FROM fecha)        AS anio,
    TO_CHAR(fecha, 'Mon YYYY')      AS mejor_mes,
    SUM(ingreso_neto)               AS total_ventas
FROM ventas
GROUP BY EXTRACT(YEAR FROM fecha), TO_CHAR(fecha, 'Mon YYYY')
ORDER BY anio, total_ventas DESC;

-- ------------------------------------------------------------
-- 3.5 ANÁLISIS DE DESCUENTOS Y PAGOS
-- ------------------------------------------------------------

-- Impacto de descuentos
SELECT
    descuento,
    COUNT(*)                                    AS ordenes,
    SUM(cantidad * precio_unitario)             AS venta_bruta,
    SUM(ingreso_neto)                           AS venta_neta,
    SUM(cantidad * precio_unitario) - SUM(ingreso_neto) AS monto_descontado
FROM ventas
GROUP BY descuento
ORDER BY descuento;

-- Ventas por método de pago
SELECT
    metodo_pago,
    COUNT(*)                        AS total_ordenes,
    SUM(ingreso_neto)               AS total_ventas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM ventas
GROUP BY metodo_pago
ORDER BY total_ordenes DESC;

-- ============================================================
-- BLOQUE 4: CONSULTAS AVANZADAS
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 CTEs — Common Table Expressions
-- ------------------------------------------------------------

-- Ranking de clientes con categoría de valor
WITH ventas_cliente AS (
    SELECT
        c.cliente_id,
        c.nombre,
        c.segmento,
        SUM(v.ingreso_neto)     AS total_compras,
        COUNT(v.order_id)       AS total_ordenes
    FROM clientes c
    JOIN ventas v ON c.cliente_id = v.cliente_id
    GROUP BY c.cliente_id, c.nombre, c.segmento
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_compras DESC) AS ranking,
        NTILE(3) OVER (ORDER BY total_compras DESC) AS tercil
    FROM ventas_cliente
)
SELECT
    ranking,
    nombre,
    segmento,
    total_ordenes,
    total_compras,
    CASE tercil
        WHEN 1 THEN 'Alto Valor'
        WHEN 2 THEN 'Valor Medio'
        WHEN 3 THEN 'Bajo Valor'
    END AS categoria_valor
FROM ranked
ORDER BY ranking;

-- Productos con rendimiento sobre el promedio
WITH promedio_productos AS (
    SELECT AVG(ingreso_neto) AS promedio_general
    FROM ventas
),
rendimiento AS (
    SELECT
        p.nombre,
        p.categoria,
        SUM(v.ingreso_neto)     AS ingreso_total,
        COUNT(v.order_id)       AS ordenes
    FROM ventas v
    JOIN productos p ON v.producto_id = p.producto_id
    GROUP BY p.nombre, p.categoria
)
SELECT
    r.nombre,
    r.categoria,
    r.ingreso_total,
    r.ordenes,
    ROUND(r.ingreso_total / pp.promedio_general, 2) AS veces_sobre_promedio
FROM rendimiento r, promedio_productos pp
WHERE r.ingreso_total > pp.promedio_general
ORDER BY veces_sobre_promedio DESC;

-- ------------------------------------------------------------
-- 4.2 WINDOW FUNCTIONS
-- ------------------------------------------------------------

-- Ventas acumuladas por mes (running total)
SELECT
    TO_CHAR(fecha, 'Mon YYYY')          AS mes,
    SUM(ingreso_neto)                   AS ventas_mes,
    SUM(SUM(ingreso_neto)) OVER (
        ORDER BY DATE_TRUNC('month', fecha)
    )                                   AS ventas_acumuladas
FROM ventas
GROUP BY DATE_TRUNC('month', fecha), TO_CHAR(fecha, 'Mon YYYY')
ORDER BY DATE_TRUNC('month', fecha);

-- Rank de productos por categoría
SELECT
    p.categoria,
    p.nombre,
    SUM(v.ingreso_neto)                 AS ingreso_total,
    RANK() OVER (
        PARTITION BY p.categoria
        ORDER BY SUM(v.ingreso_neto) DESC
    )                                   AS rank_en_categoria
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
GROUP BY p.categoria, p.nombre
ORDER BY p.categoria, rank_en_categoria;

-- Variación mes a mes (MoM)
WITH ventas_mes AS (
    SELECT
        DATE_TRUNC('month', fecha)      AS mes,
        SUM(ingreso_neto)               AS total
    FROM ventas
    GROUP BY DATE_TRUNC('month', fecha)
)
SELECT
    TO_CHAR(mes, 'Mon YYYY')            AS periodo,
    total                               AS ventas_mes,
    LAG(total) OVER (ORDER BY mes)      AS mes_anterior,
    ROUND(
        (total - LAG(total) OVER (ORDER BY mes)) * 100.0 /
        NULLIF(LAG(total) OVER (ORDER BY mes), 0), 2
    )                                   AS variacion_pct
FROM ventas_mes
ORDER BY mes;

-- ------------------------------------------------------------
-- 4.3 SUBQUERIES
-- ------------------------------------------------------------

-- Clientes que compraron en ambos años
SELECT
    c.nombre,
    c.segmento
FROM clientes c
WHERE c.cliente_id IN (
    SELECT cliente_id FROM ventas WHERE EXTRACT(YEAR FROM fecha) = 2024
)
AND c.cliente_id IN (
    SELECT cliente_id FROM ventas WHERE EXTRACT(YEAR FROM fecha) = 2025
)
ORDER BY c.nombre;

-- Órdenes por encima del ticket promedio
SELECT
    v.order_id,
    c.nombre,
    p.nombre        AS producto,
    v.ingreso_neto
FROM ventas v
JOIN clientes c ON v.cliente_id = c.cliente_id
JOIN productos p ON v.producto_id = p.producto_id
WHERE v.ingreso_neto > (
    SELECT AVG(ingreso_neto) FROM ventas
)
ORDER BY v.ingreso_neto DESC;

-- Top producto por ciudad de cliente
SELECT
    ciudad,
    producto,
    ingreso_total
FROM (
    SELECT
        c.ciudad,
        p.nombre                        AS producto,
        SUM(v.ingreso_neto)             AS ingreso_total,
        RANK() OVER (
            PARTITION BY c.ciudad
            ORDER BY SUM(v.ingreso_neto) DESC
        )                               AS rk
    FROM ventas v
    JOIN clientes c ON v.cliente_id = c.cliente_id
    JOIN productos p ON v.producto_id = p.producto_id
    GROUP BY c.ciudad, p.nombre
) ranked
WHERE rk = 1
ORDER BY ciudad;

-- ============================================================
-- BLOQUE 5: VISTAS PARA DASHBOARD
-- ============================================================

-- Vista resumen ejecutivo
CREATE OR REPLACE VIEW v_resumen_ejecutivo AS
SELECT
    COUNT(*)                        AS total_ordenes,
    COUNT(DISTINCT cliente_id)      AS clientes_activos,
    SUM(ingreso_neto)               AS total_ventas,
    ROUND(AVG(ingreso_neto), 2)     AS ticket_promedio,
    ROUND(
        COUNT(*) FILTER (WHERE estado = 'cancelado') * 100.0 / COUNT(*), 2
    )                               AS tasa_cancelacion_pct
FROM ventas_brutas;

-- Vista ventas por producto
CREATE OR REPLACE VIEW v_ventas_producto AS
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio,
    COUNT(v.order_id)               AS veces_vendido,
    SUM(v.cantidad)                 AS unidades_vendidas,
    SUM(v.ingreso_neto)             AS ingreso_total,
    ROUND(SUM(v.ingreso_neto) * 100.0 / SUM(SUM(v.ingreso_neto)) OVER(), 2) AS pct_total
FROM "Productos" p
LEFT JOIN ventas_brutas v ON p.producto_id = v.producto_id
GROUP BY p.producto_id, p.nombre, p.categoria, p.precio;

-- Vista ventas por cliente
CREATE OR REPLACE VIEW v_ventas_cliente AS
SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    c.segmento,
    COUNT(v.order_id)               AS total_ordenes,
    SUM(v.ingreso_neto)             AS total_compras,
    ROUND(AVG(v.ingreso_neto), 2)   AS ticket_promedio,
    MIN(v.fecha)                    AS primera_compra,
    MAX(v.fecha)                    AS ultima_compra
FROM clientes c
LEFT JOIN ventas_brutas v ON c.cliente_id = v.cliente_id
GROUP BY c.cliente_id, c.nombre, c.ciudad, c.segmento;

-- Vista tendencia mensual
CREATE OR REPLACE VIEW v_tendencia_mensual AS
WITH base AS (
    SELECT
        DATE_TRUNC('month', fecha)  AS mes,
        SUM(ingreso_neto)           AS ventas_mes,
        COUNT(*)                    AS ordenes_mes
    FROM ventas_brutas
    GROUP BY DATE_TRUNC('month', fecha)
)
SELECT
    TO_CHAR(mes, 'Mon YYYY')        AS periodo,
    ventas_mes,
    ordenes_mes,
    SUM(ventas_mes) OVER (ORDER BY mes) AS ventas_acumuladas,
    ROUND(
        (ventas_mes - LAG(ventas_mes) OVER (ORDER BY mes)) * 100.0 /
        NULLIF(LAG(ventas_mes) OVER (ORDER BY mes), 0), 2
    )                               AS variacion_mom_pct
FROM base
ORDER BY mes;

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================

SELECT 'clientes'  AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL
SELECT 'productos' AS tabla, COUNT(*) AS filas FROM "Productos"
UNION ALL
SELECT 'ventas'    AS tabla, COUNT(*) AS filas FROM ventas_brutas;

SELECT * FROM v_resumen_ejecutivo;
SELECT * FROM v_tendencia_mensual;
--------------------------------------------------------------------------------------
