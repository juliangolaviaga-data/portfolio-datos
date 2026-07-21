Prueba
--------------------INICIO Conciliación de Datos--------------------
    
--TABLAS

-------------------------ausentismo----------------------------

---------------------------------------------------------------

-------------------------departamentos-------------------------

---------------------------------------------------------------

-------------------------empleados-----------------------------

---------------------------------------------------------------

-------------------------evaluaciones--------------------------

---------------------------------------------------------------

-------------------------puesto--------------------------------

---------------------------------------------------------------

-------------------------sueldos-------------------------------

---------------------------------------------------------------

-- ------------------------------------------------------------
-- CONTROL 1: VOLUMETRÍA + VALIDEZ DE PK
-- ------------------------------------------------------------

-------------------------ausentismo----------------------------
SELECT
    (SELECT COUNT(*) FROM staging.ausentismo) AS total_origen,
    (SELECT COUNT(*) FROM staging.ausentismo a1
     WHERE a1.ausencia_id IS NULL OR TRIM(a1.ausencia_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.ausentismo a2
     WHERE a2.ausencia_id IS NOT NULL AND TRIM(a2.ausencia_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-------------------------departamentos-------------------------
SELECT
    (SELECT COUNT(*) FROM staging.departamentos) AS total_origen,
    (SELECT COUNT(*) FROM staging.departamentos a1
     WHERE a1.depto_id IS NULL OR TRIM(a1.depto_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.departamentos a2
     WHERE a2.depto_id IS NOT NULL AND TRIM(a2.depto_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-------------------------empleados-----------------------------
SELECT
    (SELECT COUNT(*) FROM staging.empleados) AS total_origen,
    (SELECT COUNT(*) FROM staging.empleados a1
     WHERE a1.empleado_id IS NULL OR TRIM(a1.empleado_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.empleados a2
     WHERE a2.empleado_id IS NOT NULL AND TRIM(a2.empleado_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-------------------------evaluaciones--------------------------
SELECT
    (SELECT COUNT(*) FROM staging.evaluaciones) AS total_origen,
    (SELECT COUNT(*) FROM staging.evaluaciones a1
     WHERE a1.eval_id IS NULL OR TRIM(a1.eval_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.evaluaciones a2
     WHERE a2.eval_id IS NOT NULL AND TRIM(a2.eval_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-------------------------puesto--------------------------------
SELECT
    (SELECT COUNT(*) FROM staging.puesto) AS total_origen,
    (SELECT COUNT(*) FROM staging.puesto a1
     WHERE a1.puesto_id IS NULL OR TRIM(a1.puesto_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.puesto a2
     WHERE a2.puesto_id IS NOT NULL AND TRIM(a2.puesto_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-------------------------sueldos-------------------------------
SELECT
    (SELECT COUNT(*) FROM staging.sueldos) AS total_origen,
    (SELECT COUNT(*) FROM staging.sueldos a1
     WHERE a1.sueldo_id IS NULL OR TRIM(a1.sueldo_id) = '') AS filas_sin_pk_descartadas,
    (SELECT COUNT(*) FROM staging.sueldos a2
     WHERE a2.sueldo_id IS NOT NULL AND TRIM(a2.sueldo_id) != '') AS total_esperado_en_core;
--OK
---------------------------------------------------------------

-- ------------------------------------------------------------
-- CONTROL 2: INTEGRIDAD DE SUMATORIA
-- ------------------------------------------------------------

SELECT
    SUM(COALESCE(utils.limpiar_numero(s.[columna_metrica]), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.[columna_metrica]), 0)) AS suma_con_limpieza_simbolos
FROM [esquema].[tabla_staging] s
WHERE s.[columna_pk] IS NOT NULL AND TRIM(s.[columna_pk]) != '';

-------------------------ausentismo----------------------------

---------------------------------------------------------------

-------------------------departamentos-------------------------
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.latitud), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.latitud), 0)) AS suma_con_limpieza_simbolos
FROM staging.departamentos s
WHERE s.depto_id IS NOT NULL AND TRIM(s.depto_id) != '';
--OK
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.longitud), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.longitud), 0)) AS suma_con_limpieza_simbolos
FROM staging.departamentos s
WHERE s.depto_id IS NOT NULL AND TRIM(s.depto_id) != '';
--OK
---------------------------------------------------------------

-------------------------empleados-----------------------------

---------------------------------------------------------------

-------------------------evaluaciones--------------------------
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.puntaje), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.puntaje), 0)) AS suma_con_limpieza_simbolos
FROM staging.evaluaciones s
WHERE s.eval_id IS NOT NULL AND TRIM(s.eval_id) != '';
--OK
---------------------------------------------------------------

-------------------------puesto--------------------------------
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.banda_salarial_min), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.banda_salarial_min), 0)) AS suma_con_limpieza_simbolos
FROM staging.puesto s
WHERE s.puesto_id IS NOT NULL AND TRIM(s.puesto_id) != '';
--OK
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.banda_salarial_max), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.banda_salarial_max), 0)) AS suma_con_limpieza_simbolos
FROM staging.puesto s
WHERE s.puesto_id IS NOT NULL AND TRIM(s.puesto_id) != '';
--OK
--CONTROL EXTRA PARA CASOS DE CAMSO MIN Y MAX 
SELECT puesto_id, banda_salarial_min, banda_salarial_max
FROM staging.puesto
WHERE utils.limpiar_precio(banda_salarial_min) > utils.limpiar_precio(banda_salarial_max);
--OK
SELECT 
    s.puesto_id AS id_registro, 
    s.banda_salarial_min AS valor_minimo_original, 
    s.banda_salarial_max AS valor_maximo_original,
    utils.limpiar_precio(s.banda_salarial_min) AS minimo_numerico,
    utils.limpiar_precio(s.banda_salarial_max) AS maximo_numerico
FROM staging.puesto s 
WHERE s.puesto_id IS NOT NULL 
  AND TRIM(s.puesto_id) != ''
  -- Filtra filas donde el mínimo limpio supere al máximo limpio (Error de lógica)
  AND utils.limpiar_precio(s.banda_salarial_min) > utils.limpiar_precio(s.banda_salarial_max);
--OK
---------------------------------------------------------------

-------------------------sueldos-------------------------------
SELECT
    SUM(COALESCE(utils.limpiar_numero(s.monto), 0)) AS suma_directa,
    SUM(COALESCE(utils.limpiar_precio(s.monto), 0)) AS suma_con_limpieza_simbolos
FROM staging.sueldos s
WHERE s.sueldo_id IS NOT NULL AND TRIM(s.sueldo_id) != '';
--OK
---------------------------------------------------------------

-- ------------------------------------------------------------
-- CONTROL 3: CONVERSIONES ROTAS POR COLUMNA (genérico, cualquier tipo)
-- Requiere utils.clasificar_conversion.
-- IMPORTANTE: este bloque de abajo es solo UN ejemplo (una columna).
-- Para cubrir la tabla completa, agregar un UNION ALL por cada columna
-- que pase por una función de limpieza -- ese es el reporte completo
-- (mismo patrón que ya armamos a mano para staging.ausentismo).
-- ------------------------------------------------------------
SELECT '[columna_fecha]' AS columna_analizada,
       utils.clasificar_conversion(s.[columna_fecha], utils.limpiar_fecha_generica(s.[columna_fecha])) AS estado_fecha,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
UNION ALL
SELECT '[columna_texto]' AS columna_analizada,
       utils.clasificar_conversion(s.[columna_texto], utils.formato_titulo(utils.limpiar_espacios(s.[columna_texto]))) AS estado_texto,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
UNION ALL
-- Números: clasificar_conversion espera TEXT en ambos lados -- limpiar_numero
-- devuelve NUMERIC, hay que castear con ::TEXT o Postgres no encuentra la función.
SELECT '[columna_numero]' AS columna_analizada,
       utils.clasificar_conversion(s.[columna_numero], utils.limpiar_numero(s.[columna_numero])::TEXT) AS estado_numero,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
UNION ALL
-- Precios: mismo cast, mismo motivo.
SELECT '[columna_precio]' AS columna_analizada,
       utils.clasificar_conversion(s.[columna_precio], utils.limpiar_precio(s.[columna_precio])::TEXT) as estado_precio,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
UNION ALL
-- Booleanos: la función real es utils.normalizar_booleano (no "limpiar_booleano").
SELECT '[columna_booleana]' AS columna_analizada,
       utils.clasificar_conversion(s.[columna_booleana], utils.normalizar_booleano(s.[columna_booleana])::TEXT) as estado_bool,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
UNION ALL
-- Email: NO usar clasificar_conversion acá -- utils.normalizar_email (LOWER+TRIM)
-- casi nunca devuelve NULL, así que "PERDIDA" nunca se dispara aunque el email
-- esté mal formado. Lo que hay que medir es VALIDEZ, con utils.es_email_valido.
SELECT '[columna_email]' AS columna_analizada,
       CASE WHEN utils.normalizar_nulos(s.[columna_email]) IS NULL THEN 'NULO_ORIGEN'
            WHEN utils.es_email_valido(utils.normalizar_email(s.[columna_email])) THEN 'OK'
            ELSE 'EMAIL_INVALIDO'
       END,
       COUNT(*)
FROM [esquema].[tabla_staging] s
GROUP BY 1, 2
-- Agregar más bloques UNION ALL acá para columnas restantes, siguiendo estos patrones.
ORDER BY 1, 2;

--OK
 
-------------------------ausentismo----------------------------
SELECT 'ausencia_id' AS columna_analizada,
       utils.clasificar_conversion(s.ausencia_id, utils.limpiar_numero(s.ausencia_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.ausentismo s
GROUP BY 1, 2
UNION ALL
SELECT 'fecha_inicio' AS columna_analizada,
	   utils.clasificar_conversion(s.fecha_inicio, utils.limpiar_fecha_generica(s.fecha_inicio)) AS estado_fecha,
       COUNT(*)
FROM staging.ausentismo s
GROUP BY 1, 2
UNION ALL
SELECT 'fecha_fin' AS columna_analizada,
       utils.clasificar_conversion(s.fecha_fin, utils.limpiar_fecha_generica(s.fecha_fin)) AS estado_fecha,
       COUNT(*)
FROM staging.ausentismo s
GROUP BY 1, 2
UNION ALL
SELECT 
    'tipo' AS columna_analizada,
    utils.clasificar_conversion(p.tipo, utils.formato_titulo(utils.limpiar_espacios(p.tipo))) AS estado_texto, 
    COUNT(*)
FROM staging.ausentismo p
GROUP BY 1, 2
UNION ALL
SELECT 
    'justificado' AS columna_analizada, 
    utils.clasificar_conversion(p.justificado, utils.formato_titulo(utils.limpiar_espacios(p.justificado))) AS estado_texto,
    COUNT(*)
FROM staging.ausentismo p
GROUP BY 1, 2
ORDER BY 1, 2;
--OK
---------------------------------------------------------------

-------------------------departamentos-------------------------
SELECT 'depto_id' AS columna_analizada,
       utils.clasificar_conversion(s.depto_id, utils.limpiar_numero(s.depto_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.departamentos s
GROUP BY 1, 2
UNION ALL
SELECT 
    'nombre' AS columna_analizada, 
    utils.clasificar_conversion(p.nombre, utils.formato_titulo(utils.limpiar_espacios(p.nombre))) as estado_texto, 
    COUNT(*)
FROM staging.departamentos p
GROUP BY 1, 2
UNION ALL
SELECT 'gerente_id' AS columna_analizada,
       utils.clasificar_conversion(s.gerente_id, utils.limpiar_numero(s.gerente_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.departamentos s
GROUP BY 1, 2
UNION ALL
SELECT 
    'ubicacion' AS columna_analizada, 
    utils.clasificar_conversion(p.ubicacion, utils.formato_titulo(utils.limpiar_espacios(p.ubicacion))) AS estado_texto, 
    COUNT(*)
FROM staging.departamentos p
GROUP BY 1, 2
UNION ALL
SELECT 'ubicacion' AS columna_analizada,
       utils.clasificar_conversion(d.ubicacion, utils.formato_titulo(utils.limpiar_espacios(d.ubicacion))),
       COUNT(*)
FROM staging.departamentos d
GROUP BY 1, 2
UNION ALL
SELECT 'latitud' AS columna_analizada,
       utils.clasificar_conversion(d.latitud, utils.limpiar_coordenada(d.latitud, 'LAT')::TEXT),
       COUNT(*)
FROM staging.departamentos d
GROUP BY 1, 2
UNION ALL
SELECT 'longitud' AS columna_analizada,
       utils.clasificar_conversion(d.longitud, utils.limpiar_coordenada(d.longitud, 'LON')::TEXT),
       COUNT(*)
FROM staging.departamentos d
GROUP BY 1, 2
UNION ALL
SELECT 'coordenadas' AS columna_analizada,
       CASE
           WHEN utils.normalizar_nulos(d.latitud) IS NULL AND utils.normalizar_nulos(d.longitud) IS NULL THEN 'NULO_ORIGEN'
           WHEN utils.crear_punto_postgis(d.latitud, d.longitud) IS NULL THEN 'PERDIDA DE DATOS'
           ELSE 'OK'
       END,
       COUNT(*)
FROM staging.departamentos d
GROUP BY 1, 2
ORDER BY 1, 2;
--OK
---------------------------------------------------------------

-------------------------empleados-----------------------------
SELECT 'empleado_id' AS columna_analizada,
       utils.clasificar_conversion(s.empleado_id, utils.limpiar_numero(s.empleado_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 
    'nombre' AS columna_analizada, 
    utils.clasificar_conversion(p.nombre, utils.formato_titulo(utils.limpiar_espacios(p.nombre))) AS estado_texto,  
    COUNT(*)
FROM staging.empleados p
GROUP BY 1, 2
UNION ALL
SELECT 
    'apellido' AS columna_analizada, 
    utils.clasificar_conversion(p.apellido, utils.formato_titulo(utils.limpiar_espacios(p.apellido))) AS estado_texto,  
    COUNT(*)
FROM staging.empleados p
GROUP BY 1, 2
UNION ALL
SELECT 'email' AS columna_analizada,
       CASE WHEN utils.normalizar_nulos(s.email) IS NULL THEN 'NULO_ORIGEN'
            WHEN utils.es_email_valido(utils.normalizar_email(s.email)) THEN 'OK'
            ELSE 'EMAIL_INVALIDO'
       END AS estado_mail,
       COUNT(*)
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 'telefono' AS columna_analizada,
       utils.clasificar_conversion(s.telefono, utils.limpiar_telefono(s.telefono)) AS estado_telefono,
       COUNT(*)
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 'fecha_nacimiento' AS columna_analizada,
       utils.clasificar_conversion(s.fecha_nacimiento, utils.limpiar_fecha_generica(s.fecha_nacimiento)) AS estado_fecha,
       COUNT(*)
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 'fecha_ingreso' AS columna_analizada,
       utils.clasificar_conversion(s.fecha_ingreso, utils.limpiar_fecha_generica(s.fecha_ingreso)) AS estado_fecha,
       COUNT(*)
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 'depto_id' AS columna_analizada,
       utils.clasificar_conversion(s.depto_id, utils.limpiar_numero(s.depto_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 'puesto_id' AS columna_analizada,
       utils.clasificar_conversion(s.puesto_id, utils.limpiar_numero(s.puesto_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.empleados s
GROUP BY 1, 2
UNION ALL
SELECT 
    'estado' AS columna_analizada, 
    utils.clasificar_conversion(p.estado, utils.formato_titulo(utils.limpiar_espacios(p.estado))) AS estado_texto,  
    COUNT(*)
FROM staging.empleados p
GROUP BY 1, 2
ORDER BY 1, 2;
--OK
---------------------------------------------------------------

-------------------------evaluaciones--------------------------
SELECT 'eval_id' AS columna_analizada,
       utils.clasificar_conversion(s.eval_id, utils.limpiar_numero(s.eval_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.evaluaciones s
GROUP BY 1, 2
UNION ALL
SELECT 'empleado_id' AS columna_analizada,
       utils.clasificar_conversion(s.empleado_id, utils.limpiar_numero(s.empleado_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.evaluaciones s
GROUP BY 1, 2
UNION ALL
--Esta analiza el dato asi "202301", "202302", que se crea con la funcion periodo_generar_orden_key
SELECT 'periodo_texto' AS columna_analizada,
       utils.clasificar_conversion(s.periodo, utils.limpiar_periodo(s.periodo)) AS estado_periodo,
       COUNT(*)
FROM staging.evaluaciones s
GROUP BY 1, 2
UNION ALL
SELECT 'puntaje' AS columna_analizada,
       utils.clasificar_conversion(
           e.puntaje, 
           CASE
               WHEN utils.normalizar_nulos(utils.limpiar_espacios(e.puntaje)) IS NULL THEN NULL
               ELSE utils.limpiar_espacios(e.puntaje)::NUMERIC(3,1)::TEXT
           END
       ) AS estado,
       COUNT(*)
FROM staging.evaluaciones e
GROUP BY 1, 2
UNION ALL
SELECT 
    'categoria' AS columna_analizada, 
    utils.clasificar_conversion(p.categoria, utils.formato_titulo(utils.limpiar_espacios(p.categoria))) AS estado_texto,  
    COUNT(*)
FROM staging.evaluaciones p
GROUP BY 1, 2
UNION ALL
SELECT 'evaluador_id' AS columna_analizada,
       utils.clasificar_conversion(s.evaluador_id, utils.limpiar_numero(s.evaluador_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.evaluaciones s
GROUP BY 1, 2
ORDER BY 1, 2;
---------------------------------------------------------------

-------------------------puesto--------------------------------
SELECT 'empleado_id' AS columna_analizada,
       utils.clasificar_conversion(s.puesto_id, utils.limpiar_numero(s.puesto_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.puesto s
GROUP BY 1, 2
UNION ALL
SELECT 
    'nombre' AS columna_analizada, 
    utils.clasificar_conversion(p.nombre, utils.formato_titulo(utils.limpiar_espacios(p.nombre))) AS estado_texto,  
    COUNT(*)
FROM staging.puesto p
GROUP BY 1, 2
UNION ALL 
SELECT 
    'nivel' AS columna_analizada, 
    utils.clasificar_conversion(p.nivel, utils.formato_titulo(utils.limpiar_espacios(p.nivel))) AS estado_texto, 
    COUNT(*)
FROM staging.puesto p
GROUP BY 1, 2
UNION ALL 
SELECT 
    'banda_salarial_min' as columna_analizada, 
    utils.clasificar_conversion(p.banda_salarial_min, utils.limpiar_precio(p.banda_salarial_min)::TEXT) as estado_precio,   
    COUNT(*)
FROM staging.puesto p
GROUP BY 1, 2
UNION ALL 
SELECT 
    'banda_salarial_max' AS columna_analizada, 
    utils.clasificar_conversion(p.banda_salarial_max, utils.limpiar_precio(p.banda_salarial_max)::TEXT) as estado_precio,
    COUNT(*)
FROM staging.puesto p
GROUP BY 1, 2
UNION ALL 
SELECT 
    'moneda' AS columna_analizada, 
    utils.clasificar_conversion(p.moneda, UPPER(utils.formato_titulo(utils.normalizar_nulos(p.moneda)))) as estado_precio, 
    COUNT(*)
FROM staging.puesto p
GROUP BY 1, 2
ORDER BY 1, 2;
--OK
---------------------------------------------------------------

-------------------------sueldos-------------------------------
SELECT 'sueldo_id' AS columna_analizada,
       utils.clasificar_conversion(s.sueldo_id, utils.limpiar_numero(s.sueldo_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.sueldos s
GROUP BY 1, 2
UNION ALL
SELECT 'empleado_id' AS columna_analizada,
       utils.clasificar_conversion(s.empleado_id, utils.limpiar_numero(s.empleado_id)::TEXT) AS estado_numero,
       COUNT(*) AS total_filas
FROM staging.sueldos s
GROUP BY 1, 2
UNION ALL
SELECT 'periodo' AS columna_analizada,
       utils.clasificar_conversion(s.periodo, utils.limpiar_fecha_generica(s.periodo)) AS estado_fecha,
       COUNT(*)
FROM staging.sueldos s
GROUP BY 1, 2
UNION ALL
SELECT 
    'monto' AS columna_analizada, 
    utils.clasificar_conversion(p.monto, utils.limpiar_precio(p.monto)::TEXT) as estado_precio, 
    COUNT(*)
FROM staging.sueldos p
GROUP BY 1, 2
UNION ALL
SELECT 
    'moneda' AS columna_analizada, 
    utils.clasificar_conversion(p.moneda, utils.formato_titulo(utils.limpiar_espacios(p.moneda))) AS estado_texto,  
    COUNT(*)
FROM staging.sueldos p
GROUP BY 1, 2
UNION ALL
SELECT 
    'tipo' AS columna_analizada, 
    utils.clasificar_conversion(p.tipo, utils.formato_titulo(utils.limpiar_espacios(p.tipo))) AS estado_texto,  
    COUNT(*)
FROM staging.sueldos p
GROUP BY 1, 2
ORDER BY 1, 2;
--OK
---------------------------------------------------------------
 
-- ------------------------------------------------------------
-- CONTROL 4: PLAUSIBILIDAD (detecta corrupción silenciosa -- valores
-- que NO dieron NULL pero quedaron fuera de un rango razonable,
-- ej. fecha futura imposible, sueldo con separador decimal mal leído)
-- ------------------------------------------------------------
SELECT s.[columna_pk], s.[columna_fecha], utils.limpiar_fecha_generica(s.[columna_fecha])::DATE AS fecha_convertida
FROM [esquema].[tabla_staging] s
WHERE utils.limpiar_fecha_generica(s.[columna_fecha]) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.[columna_fecha])::DATE);
 
SELECT s.[columna_pk], s.[columna_metrica], utils.limpiar_precio(s.[columna_metrica]) AS monto_convertido
FROM [esquema].[tabla_staging] s
WHERE utils.limpiar_precio(s.[columna_metrica]) IS NOT NULL
  AND NOT utils.numero_en_rango(utils.limpiar_precio(s.[columna_metrica]), [minimo_esperado], [maximo_esperado]);
 
-- Qué esperar: 0 filas en ambos. Si aparece algo, no es un NULL --
-- es un valor que "parece" válido pero está fuera de lo razonable
-- para ese campo (ej. sueldo de $50.000.000 en vez de $500.000).
-- Definir [minimo_esperado]/[maximo_esperado] según el contexto real
-- de cada columna (rango salarial del sector, fechas desde que existe
-- la empresa hasta hoy, etc.).
 
SELECT s.[columna_pk], s.[columna_telefono], utils.limpiar_telefono(s.[columna_telefono]) AS telefono_convertido
FROM [esquema].[tabla_staging] s
WHERE utils.limpiar_telefono(s.[columna_telefono]) IS NOT NULL
  AND NOT utils.telefono_en_rango(utils.limpiar_telefono(s.[columna_telefono]));

--Qué esperar: 0 filas. Si aparece algo, es un teléfono que "sobrevivió" la limpieza (no dio NULL, 
--pasó el Control 3 sin problema) pero tiene una cantidad de dígitos poco creíble — muy corto (typo, dato incompleto) 
--o muy largo (concatenación accidental de dos números, o de un DNI).

SELECT s.[columna_pk], s.[columna_periodo], utils.periodo_extraer_anio(s.[columna_periodo]) AS anio_extraido
FROM [esquema].[tabla_staging] s
WHERE utils.periodo_extraer_anio(s.[columna_periodo]) IS NOT NULL
  AND NOT utils.numero_en_rango(
        utils.periodo_extraer_anio(s.[columna_periodo]),
        [anio_minimo_esperado],
        EXTRACT(YEAR FROM CURRENT_DATE)::NUMERIC
      );

-- Qué esperar: 0 filas. Si aparece algo, es un período con formato válido
-- (pasó el Control 3 sin problema) pero con un año fuera de lo razonable
-- para tu empresa -- típicamente un typo (ej. "1998-S1" en vez de "2018-S1").
-- Definir [anio_minimo_esperado] según desde qué año existen registros reales.

SELECT s.[columna_pk], s.[columna_numerica], utils.limpiar_numero(s.[columna_numerica]) AS valor_convertido
FROM [esquema].[tabla_staging] s
WHERE utils.limpiar_numero(s.[columna_numerica]) IS NOT NULL
  AND NOT utils.numero_en_rango(
        utils.limpiar_numero(s.[columna_numerica]),
        [minimo_esperado],
        [maximo_esperado]
      );

-- Qué esperar: 0 filas. Si aparece algo, es un valor que "parece" válido
-- (pasó el Control 3 sin problema) pero está fuera de lo razonable para
-- ese campo -- ej. un puntaje de 85 en una escala 1-10.

-------------------------ausentismo----------------------------
SELECT s.ausencia_id, s.fecha_inicio, utils.limpiar_fecha_generica(s.fecha_inicio)::DATE AS fecha_convertida
FROM staging.ausentismo s
WHERE utils.limpiar_fecha_generica(s.fecha_inicio) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.fecha_inicio)::DATE);

SELECT s.ausencia_id, s.fecha_fin, utils.limpiar_fecha_generica(s.fecha_fin)::DATE AS fecha_convertida
FROM staging.ausentismo s
WHERE utils.limpiar_fecha_generica(s.fecha_fin) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.fecha_fin)::DATE);

---------------------------------------------------------------

-------------------------departamentos-------------------------

---------------------------------------------------------------

-------------------------empleados-----------------------------
SELECT s.empleado_id, s.telefono, utils.limpiar_telefono(s.telefono) AS telefono_convertido
FROM staging.empleados s
WHERE utils.limpiar_telefono(s.telefono) IS NOT NULL
  AND NOT utils.telefono_en_rango(utils.limpiar_telefono(s.telefono));

SELECT s.empleado_id, s.fecha_nacimiento, utils.limpiar_fecha_generica(s.fecha_nacimiento)::DATE AS fecha_convertida
FROM staging.empleados s
WHERE utils.limpiar_fecha_generica(s.fecha_nacimiento) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.fecha_nacimiento)::DATE);

--Este control puntual se da ya que el control fecha_en_rango tiene un minimo de fecha del año 2000, 
--sirve para fechas mas actualues, pero en fechas anteriors las detectas como errores,
--este control permite contolar con fechas razonables para una fecha de nacimeinto
--pudiendo ingresar un minimo y un maximo de edad razonable para un empleado.
SELECT s.empleado_id, s.fecha_nacimiento, utils.limpiar_fecha_generica(s.fecha_nacimiento)::DATE AS fecha_convertida
FROM staging.empleados s
WHERE utils.limpiar_fecha_generica(s.fecha_nacimiento) IS NOT NULL
  AND NOT utils.fecha_en_rango(
        utils.limpiar_fecha_generica(s.fecha_nacimiento)::DATE,
        (CURRENT_DATE - INTERVAL '70 years')::DATE,
        (CURRENT_DATE - INTERVAL '18 years')::DATE
      );

SELECT s.empleado_id, s.fecha_ingreso, utils.limpiar_fecha_generica(s.fecha_ingreso)::DATE AS fecha_convertida
FROM staging.empleados s
WHERE utils.limpiar_fecha_generica(s.fecha_ingreso) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.fecha_ingreso)::DATE);
---------------------------------------------------------------

-------------------------evaluaciones--------------------------
--minimo = 2020 → el límite de abajo.
--maximo = EXTRACT(YEAR FROM CURRENT_DATE) → el límite de arriba, calculado
SELECT e.eval_id, e.periodo, utils.periodo_extraer_anio(e.periodo) AS anio_extraido
FROM staging.evaluaciones e
WHERE utils.periodo_extraer_anio(e.periodo) IS NOT NULL
  AND NOT utils.numero_en_rango(utils.periodo_extraer_anio(e.periodo), 2020, EXTRACT(YEAR FROM CURRENT_DATE)::NUMERIC);

--minimo = 1 → el límite de abajo.
--maximo = 10 → el límite de arriba.
SELECT e.eval_id, e.puntaje, utils.limpiar_numero(e.puntaje) AS puntaje_convertido
FROM staging.evaluaciones e
WHERE utils.limpiar_numero(e.puntaje) IS NOT NULL
  AND NOT utils.numero_en_rango(utils.limpiar_numero(e.puntaje), 1, 10);
---------------------------------------------------------------

-------------------------puesto--------------------------------
 --Este control solo en el futuro, si se cargan datos nuevos a staging.puestos (por ejemplo, dentro de 6 meses agregás más filas) 
 --y alguno de esos valores nuevos cae fuera del rango que estableci ahora.
 --Ahí el control sí serviría — pero no para auditar los datos que tenés ahora, sino como una alarma a futuro.

--Obtengo el min y max para cada banda salarial, asi establezco el control
SELECT
    MIN(utils.limpiar_precio(banda_salarial_min)) AS minimo_actual,
    MAX(utils.limpiar_precio(banda_salarial_min)) AS maximo_actual,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY utils.limpiar_precio(banda_salarial_min)) AS mediana_min,
    MIN(utils.limpiar_precio(banda_salarial_max)) AS minimo_actual_max,
    MAX(utils.limpiar_precio(banda_salarial_max)) AS maximo_actual_max,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY utils.limpiar_precio(banda_salarial_max)) AS mediana_max
FROM staging.puesto;

SELECT s.puesto_id, s.banda_salarial_min, utils.limpiar_precio(s.banda_salarial_min) AS monto_convertido
FROM staging.puesto s
WHERE utils.limpiar_precio(s.banda_salarial_min) IS NOT NULL
  AND NOT utils.numero_en_rango(utils.limpiar_precio(s.banda_salarial_min), 1200, 900000);

SELECT s.puesto_id, s.banda_salarial_max, utils.limpiar_precio(s.banda_salarial_max) AS monto_convertido
FROM staging.puesto s
WHERE utils.limpiar_precio(s.banda_salarial_max) IS NOT NULL
  AND NOT utils.numero_en_rango(utils.limpiar_precio(s.banda_salarial_max), 2000, 1400000);
---------------------------------------------------------------

-------------------------sueldos-------------------------------
SELECT s.sueldo_id, s.periodo, utils.limpiar_fecha_generica(s.periodo)::DATE AS fecha_convertida
FROM staging.sueldos s
WHERE utils.limpiar_fecha_generica(s.periodo) IS NOT NULL
  AND NOT utils.fecha_en_rango(utils.limpiar_fecha_generica(s.periodo)::DATE);
---------------------------------------------------------------

-- ------------------------------------------------------------
-- CONTROL 5: CIERRE -- staging vs core, post-INSERT
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM [esquema].[tabla_staging]) AS filas_staging,
    (SELECT COUNT(*) FROM [esquema_core].[tabla_core]) AS filas_core;

SELECT
    (SELECT COUNT(*) FROM staging.ausentismo) AS staging,
    (SELECT COUNT(*) FROM core.ausentismo) AS core
UNION ALL
SELECT
    (SELECT COUNT(*) FROM staging.departamentos) AS staging,
    (SELECT COUNT(*) FROM core.departamentos) AS core    
UNION ALL
SELECT
    (SELECT COUNT(*) FROM staging.empleados) AS staging,
    (SELECT COUNT(*) FROM core.empleados) AS core
UNION ALL
SELECT
    (SELECT COUNT(*) FROM staging.evaluaciones) AS staging,
    (SELECT COUNT(*) FROM core.evaluaciones) AS core
UNION ALL
SELECT
    (SELECT COUNT(*) FROM staging.puesto) AS staging,
    (SELECT COUNT(*) FROM core.puesto) AS core
UNION ALL
SELECT
    (SELECT COUNT(*) FROM staging.sueldos) AS staging,
    (SELECT COUNT(*) FROM core.sueldos) AS core

-- Qué esperar: coinciden, salvo deduplicación intencional (documentar
-- la diferencia si la hay -- no debería ser una sorpresa).
 