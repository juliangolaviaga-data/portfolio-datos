--------------------INICIO Tablas Staging--------------------
--Armado de tablas Staging para el analisis de los datos

CREATE TABLE staging.ausentismo 
(
	ausencia_id TEXT,
	empleado_id TEXT,
	fecha_inicio TEXT,
	fecha_fin TEXT,
	tipo TEXT,
	justificado TEXT
);

CREATE TABLE staging.departamentos 
(
	depto_id TEXT,
	nombre TEXT,
	gerente_id TEXT,
	ubicacion TEXT,
	latitud TEXT,
	longitud TEXT
);

CREATE TABLE staging.empleados 
(
	empleado_id TEXT,
	nombre TEXT,
	apellido TEXT,
	email TEXT,
	telefono TEXT,
	fecha_nacimiento TEXT,
	fecha_ingreso TEXT,
	depto_id TEXT,
	puesto_id TEXT,
	estado TEXT
);

CREATE TABLE staging.evaluaciones 
(
	eval_id TEXT,
	empleado_id TEXT,
	periodo TEXT,
	puntaje TEXT,
	categoria TEXT,
	evaluador_id TEXT
)

CREATE TABLE staging.puesto
(
	puesto_id TEXT,
	nombre TEXT,
	nivel TEXT,
	banda_salarial_min TEXT,
	banda_salarial_max TEXT,
	moneda TEXT
);

CREATE TABLE staging.sueldos
(
	sueldo_id TEXT,
	empleado_id TEXT,
	periodo TEXT,
	monto TEXT,
	moneda TEXT,
	tipo TEXT
);
--------------------FIN Tablas Staging--------------------

----------------------CONTROL DE DUPLICADOS--------------------


--Manual de Uso (Paso a Paso)
--Paso 1: El Diagnóstico General.
SELECT * FROM utils.control_duplicados_exactos('staging.empleados', 'empleado_id')

--Paso 2: La Limpieza Automática. Si el diagnóstico mostro duplicados puros, ejecutando esto los mostrara:
SELECT * FROM utils.eliminar_duplicados_exactos_puros('staging.empleados', 'empleado_id');

--Paso 3: Listar los "Enfermos" con Diferencias. Si después del Paso 2 volvés a correr el diagnóstico y todavía quedan duplicados, 
--significa que son duplicados con diferencias (mismo ID, distinto contenido). Listamos cuáles son esos IDs:
SELECT * FROM utils.listar_duplicados_exactos('staging.empleados', 'empleado_id');

--Paso 4: La Radiografía JSON (Inspección Ocular)
--Querés ver por qué el empleado 1024 tiene dos variantes. 
--Ejecutás la extracción para ver el contenido completo de las filas que chocan sin tener que declarar la estructura de la tabla:
SELECT * FROM utils.extraer_filas_duplicadas_json('staging.empleados', 'empleado_id');

--CONSULTAS PARA VER DUPLICADOS
SELECT empleado_id, COUNT(*)
FROM staging.empleados
GROUP BY empleado_id
HAVING COUNT(*) > 1;

SELECT *
FROM staging.empleados
WHERE empleado_id IN ('E1091','E1110','E1045')
ORDER BY empleado_id;

SELECT COUNT(*) AS filas_totales,
       COUNT(DISTINCT empleado_id) AS ids_unicos,
       COUNT(*) - COUNT(DISTINCT empleado_id) AS filas_duplicadas
FROM staging.empleados;

----------------------------------------------------------------

--------------------INICIO Limpieza de datos--------------------

-----------AUSENTISMO-----------
--Analisis general de la tabla ausentismo
EXPLAIN ANALYZE
select * from staging.ausentismo a

SELECT * FROM utils.control_duplicados_exactos('staging.ausentismo', 'ausencia_id')

--Obtener columnas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' AND table_name = 'ausentismo';

--Chequear con DISTINCT para establecer datos categoricos
select distinct(a.tipo) from staging.ausentismo a

--Cantidad x tipo
SELECT a.tipo, COUNT(*) 
FROM staging.ausentismo a
GROUP BY a.tipo 
ORDER BY a.tipo;

--Chequear con DISTINCT para establecer datos categoricos
select distinct(a.justificado ) from staging.ausentismo a

--Cantidad de ausencias justificadas, y el %
SELECT 
    utils.normalizar_booleano(a.justificado) AS respuesta_limpia,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM staging.ausentismo a
GROUP BY utils.normalizar_booleano(a.justificado)
ORDER BY total DESC;

--Se revisa de manera rapida si los datos son de tpo DATE o Timestamp 
SELECT a.fecha_inicio, LENGTH(a.fecha_inicio)
FROM staging.ausentismo a
LIMIT 10;

SELECT 
    COUNT(*) FILTER (WHERE utils.limpiar_fecha_generica(a.fecha_inicio) IS NULL) AS fechas_invalidas,
    COUNT(*) FILTER (WHERE utils.normalizar_booleano(a.justificado) IS NULL) AS justificado_invalido
from staging.ausentismo a

--Contar nulos de id
SELECT 
    COUNT(*) AS total_registros,
    COUNT(CASE WHEN ausencia_id IS NULL THEN 1 END) AS ausencia_id_nulos,
    COUNT(CASE WHEN empleado_id IS NULL THEN 1 END) AS empleado_id_nulos
FROM staging.ausentismo;

--SELECT LISTO PARA INSERT
SELECT 
    utils.limpiar_espacios(a.ausencia_id) AS ausencia_id_limpio,
    utils.limpiar_espacios(a.empleado_id) AS empleado_id_limpio,
    utils.formato_titulo(utils.normalizar_nulos(a.tipo)) AS tipo_ausencia_limpio,
    utils.formato_titulo(utils.normalizar_nulos(a.justificado)) AS esta_justificado,
    utils.normalizar_booleano(a.justificado)::BOOLEAN AS esta_justificada,
    utils.limpiar_fecha_generica(a.fecha_inicio)::DATE AS fecha_inicio_clean,
    utils.es_fecha_incompleta(a.fecha_inicio) AS fecha_inicio_incompleta,
    utils.limpiar_fecha_generica(a.fecha_fin)::DATE AS fecha_fin_clean,
    utils.es_fecha_incompleta(a.fecha_fin) AS fecha_fin_incompleta
FROM staging.ausentismo a
-- Filtros de calidad de datos para asegurar la integridad referencial en Core
WHERE a.ausencia_id IS NOT NULL 
  AND TRIM(a.ausencia_id) != ''
  AND a.empleado_id IS NOT NULL 
  AND TRIM(a.empleado_id) != '';
--------------------------------------------------------------------------------------

-----------DEPARTAMENTOS-----------
EXPLAIN ANALYZE
select * from staging.departamentos d

SELECT * FROM utils.control_duplicados_exactos('staging.departamentos', 'depto_id')

select utils.formato_titulo(utils.normalizar_nulos(d.nombre)) AS nombre_limpio from staging.departamentos d
select distinct(d.nombre) from staging.departamentos d

select utils.formato_titulo(utils.normalizar_nulos(d.ubicacion)) AS nombre_limpio from staging.departamentos d
select distinct(d.ubicacion) from staging.departamentos d

--Cant x ubicacion
SELECT d.ubicacion, COUNT(*) 
FROM staging.departamentos d 
GROUP BY d.ubicacion 
ORDER BY d.ubicacion;

select distinct(a.justificado ) from staging.ausentismo a;

--SELECT LISTO PARA INSERT
SELECT 
    utils.limpiar_espacios(d.depto_id) AS depto_id_limpio,
    utils.formato_titulo(utils.normalizar_nulos(d.nombre)) AS nombre_limpio,
    utils.limpiar_espacios(d.gerente_id) AS gerente_id_limpio,
    utils.formato_titulo(utils.normalizar_nulos(d.ubicacion)) AS ubicacion_limpia,
    utils.limpiar_coordenada(d.latitud, 'LAT') AS latitud_limpia,
    utils.limpiar_coordenada(d.longitud, 'LON') AS longitud_limpia,
    -- Se agrega el campo geográfico PostGIS
    utils.crear_punto_postgis(d.latitud, d.longitud) AS punto_geometrico
FROM staging.departamentos d
-- Filtros de calidad de datos para asegurar la integridad referencial en Core
WHERE d.depto_id IS NOT NULL 
  AND TRIM(d.depto_id) != ''
  AND d.gerente_id IS NOT NULL 
  AND TRIM(d.gerente_id) != '';
--------------------------------------------------------------------------------------

-----------EMPLEADOS-----------
EXPLAIN ANALYZE
select * from staging.empleados e

SELECT * FROM utils.control_duplicados_exactos('staging.empleados', 'empleado_id')

--Obtener columnas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' AND table_name = 'empleados';

select utils.limpiar_espacios(e.empleado_id) AS empleado_id_limpio from staging.empleados e
select utils.limpiar_espacios(e.depto_id) AS depto_id_limpio from staging.empleados e
select utils.limpiar_espacios(e.puesto_id) AS puesto_id_limpio from staging.empleados e

select utils.formato_titulo(utils.normalizar_nulos(e.nombre)) AS nombre_limpio from staging.empleados e
select utils.formato_titulo(utils.normalizar_nulos(e.apellido)) AS apellido_limpio from staging.empleados e

select utils.normalizar_email(e.email) AS email_limpio from staging.empleados e
select utils.limpiar_telefono(e.telefono) AS telefono_limpio from staging.empleados e

select utils.limpiar_fecha_generica(e.fecha_nacimiento)::DATE AS fecha_nacimiento from staging.empleados e
select utils.es_fecha_incompleta(e.fecha_nacimiento) AS fecha_nacimiento_incompleta from staging.empleados e
    
select utils.limpiar_fecha_generica(e.fecha_ingreso)::DATE AS fecha_ingreso from staging.empleados e
select utils.es_fecha_incompleta(e.fecha_ingreso) AS fecha_ingreso_incompleta from staging.empleados e

select distinct(e.estado ) from staging.empleados e

--SELECT LISTO PARA INSERT
select
	utils.limpiar_espacios(e.empleado_id) AS empleado_id_limpio,
	utils.limpiar_espacios(e.depto_id) AS depto_id_limpio,
	utils.limpiar_espacios(e.puesto_id) AS puesto_id_limpio,
	utils.formato_titulo(utils.normalizar_nulos(e.nombre)) AS nombre_limpio,
	utils.formato_titulo(utils.normalizar_nulos(e.apellido)) AS apellido_limpio,
	utils.normalizar_email(e.email) AS email_limpio,
	utils.limpiar_telefono(e.telefono) AS telefono_limpio,
	utils.limpiar_fecha_generica(e.fecha_nacimiento)::DATE AS fecha_nacimiento,
	utils.es_fecha_incompleta(e.fecha_nacimiento) AS fecha_nacimiento_incompleta,
	utils.limpiar_fecha_generica(e.fecha_ingreso)::DATE AS fecha_ingreso,
	utils.es_fecha_incompleta(e.fecha_ingreso) AS fecha_ingreso_incompleta,
    utils.formato_titulo(utils.normalizar_nulos(e.estado)) AS estado,
    utils.normalizar_booleano(e.estado)::BOOLEAN AS es_activos
FROM staging.empleados e
WHERE e.empleado_id IS NOT NULL 
  AND TRIM(e.empleado_id) != '';

--------------------------------------------------------------------------------------

-----------EVALUACIONES-----------

EXPLAIN ANALYZE
select * from staging.evaluaciones e

SELECT * FROM utils.control_duplicados_exactos('staging.evaluaciones', 'eval_id')

--Obtener columnas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' AND table_name = 'evaluaciones';

--SELECT LISTO PARA INSERT
SELECT
    utils.limpiar_espacios(e.eval_id) AS evaluacion_id_limpio,
    utils.limpiar_espacios(e.empleado_id) AS empleado_id_limpio,
    utils.limpiar_espacios(e.evaluador_id) AS evaluador_id_limpio,
    utils.limpiar_periodo(e.periodo) AS periodo_original,
    utils.periodo_generar_orden_key(e.periodo) AS periodo_orden_key,
    CASE
        WHEN utils.normalizar_nulos(utils.limpiar_espacios(e.puntaje)) IS NULL THEN NULL
        ELSE utils.limpiar_espacios(e.puntaje)::NUMERIC(3,1)
    END AS puntaje,
    utils.formato_titulo(utils.normalizar_nulos(e.categoria)) AS categoria_limpia
FROM staging.evaluaciones e
WHERE e.eval_id IS NOT NULL
  AND TRIM(e.eval_id) != '';

--------------------------------------------------------------------------------------

-----------PUESTO-----------
EXPLAIN ANALYZE
select * from staging.puesto p

SELECT * FROM utils.control_duplicados_exactos('staging.puesto', 'puesto_id')

--Obtener columnas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' AND table_name = 'puesto';

--SELECT LISTO PARA INSERT
SELECT 
    utils.limpiar_espacios(p.puesto_id) AS puesto_id_limpio,
    utils.formato_titulo(utils.normalizar_nulos(p.nombre)) AS nombre_limpio,
    utils.formato_titulo(utils.normalizar_nulos(p.nivel)) AS nivel_limpio,
    utils.limpiar_numero(p.banda_salarial_min)  AS banda_salarial_min_limpia,
    utils.limpiar_numero(p.banda_salarial_max)  AS banda_salarial_max_limpia,
    UPPER(utils.formato_titulo(utils.normalizar_nulos(p.moneda))) AS moneda_limpia
FROM staging.puesto p 
WHERE p.puesto_id IS NOT NULL 
  AND TRIM(p.puesto_id) != '';
--------------------------------------------------------------------------------------

-----------SUELDOS-----------
EXPLAIN ANALYZE
select * from staging.sueldos s

SELECT * FROM utils.control_duplicados_exactos('staging.sueldos', 'sueldo_id')

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'staging' AND table_name = 'sueldos';

--SELECT LISTO PARA INSERT
select
	utils.limpiar_espacios(sueldo_id) AS sueldo_id_limpio,
	utils.limpiar_espacios(empleado_id) as empleado_id_limpio,
	utils.limpiar_fecha_generica(s.periodo)::DATE AS fecha_nacimiento,
	utils.es_fecha_incompleta(s.periodo) AS fecha_nacimiento_incompleta,
CASE 
    -- 1. Si el dato viene con "N/A", vacío o nulo, se intercepta en primer plano
    WHEN utils.normalizar_nulos(utils.limpiar_espacios(s.monto)) IS NULL THEN NULL
    
    -- 2. Si trae número, tu función remueve el '$' y luego realizamos el cast decimal nativo
    ELSE utils.limpiar_simbolo_moneda(s.monto)::NUMERIC(12,2)
END AS monto_limpio,
	UPPER(utils.formato_titulo(utils.normalizar_nulos(s.moneda))) AS moneda_limpia,
	utils.formato_titulo(utils.normalizar_nulos(s.tipo)) AS tipo_limpio
FROM staging.sueldos s
WHERE s.sueldo_id IS NOT NULL 
  AND TRIM(s.sueldo_id) != '';
--------------------FIN Limpieza de datos--------------------