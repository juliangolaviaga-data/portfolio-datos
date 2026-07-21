----------------------Asuentismo por empleados-----------------------
CREATE OR REPLACE VIEW  core.ausencias_x_empleado AS
Select
	--a.AUSENCIA_ID,
	--a.EMPLEADO_ID,
	e.APELLIDO || ', ' || e.NOMBRE AS Empleado,
	a.TIPO AS Tipo_Ausencia,
	a.justificado as Justificado,
	lower(to_char(a.FECHA_INICIO, 'DD-Mon-YYYY')) || ' - ' || lower(to_char(a.FECHA_FIN, 'DD-Mon-YYYY')) AS Periodo,
	a.FECHA_FIN - a.FECHA_INICIO AS Dias_Periodo	
FROM core.ausentismo a
JOIN core.EMPLEADOS e on e.EMPLEADO_ID = a.EMPLEADO_ID
GROUP BY
	--a.AUSENCIA_ID,
	--a.EMPLEADO_ID,
	Empleado,
	a.TIPO,
	a.justificado,
	lower(to_char(a.FECHA_INICIO, 'DD-Mon-YYYY')) || ' - ' || lower(to_char(a.FECHA_FIN, 'DD-Mon-YYYY')),
	a.FECHA_FIN - a.FECHA_INICIO
ORDER BY Empleado
---------------------------------------------------------------------

----------------------Evaluaciones por empleados-----------------------
CREATE OR REPLACE VIEW  core.valuaciones_x_empleado AS
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


SELECT email, COUNT(DISTINCT empleado_id) AS cant_ids
FROM core.empleados
GROUP BY email
HAVING COUNT(DISTINCT empleado_id) > 1
ORDER BY cant_ids DESC;

SELECT empleado_id, nombre, apellido, telefono, fecha_nacimiento, fecha_ingreso, depto_id
FROM core.empleados
WHERE email IN ('aldana.rojas@techba.com','camila.molina@techba.com','cecilia.cabrera@techba.com',
'cecilia.medina@techba.com','cecilia.nunez@techba.com','ezequiel.gomez@techba.com',
'micaela.herrera@techba.com','natalia.molina@techba.com','ramiro.vera@techba.com')
ORDER BY email, empleado_id;