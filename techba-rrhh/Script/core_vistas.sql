----------------------Asuentismo por empleados-----------------------
CREATE VIEW core.ausencias_x_empleado AS
Select
	--a.AUSENCIA_ID,
	--a.EMPLEADO_ID,
	e.APELLIDO || ', ' || e.NOMBRE AS Empleado,
	a.TIPO AS Tipo_Ausencia,
	a.justificado as Justificado,
	lower(to_char(a.FECHA_INICIO, 'DD-Mon-YYYY')) || ' - ' || lower(to_char(a.FECHA_FIN, 'DD-Mon-YYYY')) AS Periodo
FROM core.ausentismo a
JOIN core.EMPLEADOS e on e.EMPLEADO_ID = a.EMPLEADO_ID
GROUP BY
	--a.AUSENCIA_ID,
	--a.EMPLEADO_ID,
	Empleado,
	a.TIPO,
	a.justificado,
	lower(to_char(a.FECHA_INICIO, 'DD-Mon-YYYY')) || ' - ' || lower(to_char(a.FECHA_FIN, 'DD-Mon-YYYY'))
ORDER BY Empleado
---------------------------------------------------------------------

--ANLITICAS

--Cálculo de días de ausencia
    --Solo si ambas fechas pudieron ser rescatadas y limpiadas correctamente
    CASE 
        WHEN utils.limpiar_fecha_generica(a.fecha_fin) IS NOT NULL 
         AND utils.limpiar_fecha_generica(a.fecha_inicio) IS NOT NULL
        THEN 
            -- Si la fecha fin es menor, calculamos la diferencia invertida (rescatamos el dato)
            CASE 
                WHEN utils.limpiar_fecha_generica(a.fecha_fin)::DATE < utils.limpiar_fecha_generica(a.fecha_inicio)::DATE 
                THEN (utils.limpiar_fecha_generica(a.fecha_inicio)::DATE - utils.limpiar_fecha_generica(a.fecha_fin)::DATE) + 1
                ELSE (utils.limpiar_fecha_generica(a.fecha_fin)::DATE - utils.limpiar_fecha_generica(a.fecha_inicio)::DATE) + 1
            END
        ELSE NULL 
    END AS dias_duracion_ausencia,

    -- COLUMNA DE ALERTA: Cantidad de dias de ausencia qeu daban negativos, 
    --se invierten las fechas para el calculo y se deja constancia (True=fecha invertida)
    CASE 
        WHEN utils.limpiar_fecha_generica(a.fecha_fin)::DATE < utils.limpiar_fecha_generica(a.fecha_inicio)::DATE 
        THEN TRUE ELSE FALSE 
    END AS alerta_fechas_invertidas
    
    
    
    
    -- 3. NORMALIZACIÓN FINANCIERA (Convertimos todo a Pesos Argentinos para poder sumar y promediar)
    CASE 
        WHEN utils.limpiar_espacios(p.moneda) = 'USD' THEN utils.limpiar_numero(p.salario_min)::NUMERIC * 1000.0 -- Cotización ejemplo
        ELSE utils.limpiar_numero(p.salario_min)::NUMERIC 
    END::NUMERIC(12,2) AS salario_min_ars,

    CASE 
        WHEN utils.limpiar_espacios(p.moneda) = 'USD' THEN utils.limpiar_numero(p.salario_max)::NUMERIC * 1000.0 -- Cotización ejemplo
        ELSE utils.limpiar_numero(p.salario_max)::NUMERIC 
    END::NUMERIC(12,2) AS salario_max_ars
    
    