----------------------Asuentismo por empleados-----------------------
DROP VIEW core.vw_ausencias_x_empleado;

CREATE OR REPLACE VIEW core.vw_ausencias_x_empleado AS
SELECT
	e.empleado_id,
    e.apellido,
    e.nombre,
    a.TIPO AS Tipo_Ausencia,
    a.justificado AS Justificado,
    lower(to_char(a.FECHA_INICIO, 'DD-Mon-YYYY')) || ' - ' || lower(to_char(a.FECHA_FIN, 'DD-Mon-YYYY')) AS Periodo,
    a.FECHA_FIN - a.FECHA_INICIO + 1 AS Dias_Periodo
FROM core.ausentismo a
JOIN core.EMPLEADOS e ON e.EMPLEADO_ID = a.EMPLEADO_ID
GROUP BY
	e.empleado_id,
    e.apellido,
    e.nombre,
    a.TIPO,
    a.justificado,
    Periodo,
    a.FECHA_FIN - a.FECHA_INICIO + 1
--ORDER BY apellido, nombre;
---------------------------------------------------------------------

----------------------Evaluaciones por empleados-----------------------
CREATE OR REPLACE VIEW  core.vw_valuaciones_x_empleado AS
select
	em.empleado_id,
	em.APELLIDO || ', ' || em.NOMBRE AS Empleado,
	ev.periodo_original as Periodo,
	ev.puntaje as Puntaje,
	ev.categoria as Categoria
	--e.APELLIDO || ', ' || e.NOMBRE AS Empleado,
FROM core.evaluaciones ev
JOIN core.empleados em on em.empleado_id = ev.empleado_id
GROUP by
	em.empleado_id,
	Empleado,
	Periodo,
	Puntaje,
	Categoria
ORDER BY Empleado
---------------------------------------------------------------------

-- 1. Empleados completo (sueldo normal más reciente)
DROP VIEW core.vw_empleados_completo;

CREATE OR REPLACE VIEW core.vw_empleados_completo AS
SELECT 
    e.empleado_id, 
    e.apellido, 
    e.nombre, 
    e.email, 
    e.fecha_ingreso, 
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fecha_ingreso)) AS antiguedad_anios,
    e.estado,
    d.depto_id, 
    d.nombre AS departamento, 
    p.puesto_id, 
    p.nombre AS puesto, 
    s.moneda, 
    s.monto AS sueldo, 
    s.periodo_fecha
FROM core.empleados e 
LEFT JOIN core.departamentos d 
    ON e.depto_id = d.depto_id 
LEFT JOIN core.puesto p 
    ON e.puesto_id = p.puesto_id 
LEFT JOIN ( 
    SELECT 
        empleado_id, 
        moneda, 
        monto, 
        periodo_fecha, 
        ROW_NUMBER() OVER ( 
            PARTITION BY empleado_id 
            ORDER BY periodo_fecha DESC 
        ) AS rn 
    FROM core.sueldos 
    WHERE tipo = 'Normal' 
) s 
    ON s.empleado_id = e.empleado_id 
    AND s.rn = 1

SELECT * FROM core.sueldos WHERE empleado_id = 'E1021';
SELECT * FROM core.sueldos WHERE empleado_id = 'E1021';

SELECT COUNT(*) 
FROM core.empleados e
LEFT JOIN core.sueldos s ON e.empleado_id = s.empleado_id
WHERE s.empleado_id IS NULL;

SELECT view_definition 
FROM information_schema.views 
WHERE table_schema = 'core' AND table_name = 'vw_empleados_completo';

-- 2. Bonus y ajustes por separado (histórico completo, no solo el último)
CREATE VIEW core.vw_sueldo_bonus_ajustes AS
SELECT
    empleado_id,
    periodo_fecha,
    tipo,
    monto,
    moneda
FROM core.sueldos
WHERE tipo IN ('Bonus', 'Ajuste');


-- 3. Dotación por departamento
CREATE VIEW core.vw_dotacion_departamento AS
SELECT
    d.depto_id,
    d.nombre AS departamento,
    COUNT(e.empleado_id) AS cantidad_empleados
FROM core.departamentos d
LEFT JOIN core.empleados e ON e.depto_id = d.depto_id
GROUP BY d.depto_id, d.nombre;


-- 4. Ausentismo resumen por empleado
CREATE VIEW core.vw_ausentismo_resumen AS
SELECT
    empleado_id,
    COUNT(*) AS cantidad_eventos,
    SUM(fecha_fin - fecha_inicio + 1) AS dias_ausente_total,
    SUM(CASE WHEN justificado_bool THEN 1 ELSE 0 END) AS eventos_justificados,
    SUM(CASE WHEN NOT justificado_bool THEN 1 ELSE 0 END) AS eventos_no_justificados
FROM core.ausentismo
GROUP BY empleado_id;

SELECT * FROM core.vw_empleados_completo LIMIT 5;