Prueba
--------------------INICIO Tablas CORE--------------------
--Armado de tablas Core para el insert de los datos

DROP TABLE IF EXISTS core.ausentismo CASCADE;
DROP TABLE IF EXISTS core.evaluaciones CASCADE;
DROP TABLE IF EXISTS core.sueldos CASCADE;
DROP TABLE IF EXISTS core.empleados CASCADE;
DROP TABLE IF EXISTS core.puesto CASCADE;
DROP TABLE IF EXISTS core.departamentos CASCADE;

---------------------------------------------------------------
------------------------- 1. DEPARTAMENTOS --------------------
---------------------------------------------------------------
CREATE TABLE core.departamentos (
    depto_id VARCHAR(7) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    gerente_id VARCHAR(7),
    ubicacion VARCHAR(150),
    latitud NUMERIC(9,6),
    longitud NUMERIC(9,6),
    punto_geometrico "geo"."geometry"(Point, 4326),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_depto_punto_geo ON core.departamentos USING GIST (punto_geometrico);

INSERT INTO core.departamentos (
    depto_id, 
    nombre, 
    gerente_id, 
    ubicacion, 
    latitud, 
    longitud, 
    punto_geometrico
)
SELECT 
    utils.limpiar_espacios(d.depto_id), 
    utils.formato_titulo(utils.normalizar_nulos(d.nombre)), 
    utils.limpiar_espacios(d.gerente_id), 
    utils.formato_titulo(utils.normalizar_nulos(d.ubicacion)), 
    utils.limpiar_coordenada(d.latitud, 'LAT'), 
    utils.limpiar_coordenada(d.longitud, 'LON'), 
    -- Se limpian los datos y se convierten a TEXT para que tu función PostGIS los acepte
    utils.crear_punto_postgis(
        utils.limpiar_coordenada(d.latitud, 'LAT')::TEXT, 
        utils.limpiar_coordenada(d.longitud, 'LON')::TEXT
    ) as postgis
FROM staging.departamentos d 
WHERE d.depto_id IS NOT NULL AND TRIM(d.depto_id) != '' 
AND d.gerente_id IS NOT NULL AND TRIM(d.gerente_id) != '';

---------------------------------------------------------------
------------------------- 2. PUESTO ---------------------------
---------------------------------------------------------------
CREATE TABLE core.puesto (
    puesto_id VARCHAR(7) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nivel VARCHAR(50) NOT NULL,
    banda_salarial_min NUMERIC(12,2),
    banda_salarial_max NUMERIC(12,2),
    moneda VARCHAR(3) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Acepta desde 1 hasta 6 números después de la letra (ej: P01, E1031)
    CONSTRAINT chk_puesto_id_formato CHECK (puesto_id ~ '^[A-Z][0-9]{1,6}$'),
    CONSTRAINT chk_bandas_salariales CHECK (banda_salarial_max >= banda_salarial_min)
);

INSERT INTO core.puesto (
    puesto_id, 
    nombre, 
    nivel, 
    banda_salarial_min, 
    banda_salarial_max, 
    moneda
)
SELECT 
    utils.limpiar_espacios(p.puesto_id), 
    utils.formato_titulo(utils.normalizar_nulos(p.nombre)), 
    utils.formato_titulo(utils.normalizar_nulos(p.nivel)), 
    utils.limpiar_numero(p.banda_salarial_min), 
    utils.limpiar_numero(p.banda_salarial_max), 
    UPPER(utils.formato_titulo(utils.normalizar_nulos(p.moneda)))
FROM staging.puesto p 
WHERE p.puesto_id IS NOT NULL AND TRIM(p.puesto_id) != '';

---------------------------------------------------------------
------------------------- 3. EMPLEADOS ------------------------
---------------------------------------------------------------

-- PASO 2: Crear la tabla limpia con el formato de IDs flexible y las columnas correctas
CREATE TABLE core.empleados (
    empleado_id VARCHAR(7) PRIMARY KEY,
    depto_id VARCHAR(7) NOT NULL,
    puesto_id VARCHAR(7) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    telefono VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    fecha_nacimiento_incompleta BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_ingreso DATE NOT NULL,
    fecha_ingreso_incompleta BOOLEAN NOT NULL DEFAULT FALSE,
    estado VARCHAR(30),
    es_activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Validación de formato flexible {1,6} para IDs cortos o largos
    CONSTRAINT chk_emp_id_formato CHECK (empleado_id ~ '^[A-Z][0-9]{1,6}$'),
    CONSTRAINT chk_dep_id_formato CHECK (depto_id ~ '^[A-Z][0-9]{1,6}$'),
    CONSTRAINT chk_pue_id_formato CHECK (puesto_id ~ '^[A-Z][0-9]{1,6}$')
);

-- Recreamos el índice de la tabla
CREATE INDEX idx_empleados_activos ON core.empleados(es_activo) WHERE es_activo = TRUE;

INSERT INTO core.empleados (
    empleado_id, 
    depto_id, 
    puesto_id, 
    nombre, 
    apellido, 
    email, 
    telefono, 
    fecha_nacimiento, 
    fecha_nacimiento_incompleta, 
    fecha_ingreso, 
    fecha_ingreso_incompleta, 
    estado, 
    es_activo
)
SELECT 
    utils.limpiar_espacios(e.empleado_id), 
    utils.limpiar_espacios(e.depto_id), 
    utils.limpiar_espacios(e.puesto_id), 
    utils.formato_titulo(utils.normalizar_nulos(e.nombre)), 
    utils.formato_titulo(utils.normalizar_nulos(e.apellido)), 
    utils.normalizar_email(e.email), 
    utils.limpiar_telefono(e.telefono), 
    utils.limpiar_fecha_generica(e.fecha_nacimiento)::DATE, 
    utils.es_fecha_incompleta(e.fecha_nacimiento)::BOOLEAN, 
    utils.limpiar_fecha_generica(e.fecha_ingreso)::DATE, 
    utils.es_fecha_incompleta(e.fecha_ingreso)::BOOLEAN, 
    utils.formato_titulo(utils.normalizar_nulos(e.estado)), 
    utils.normalizar_booleano(e.estado)::BOOLEAN
FROM staging.empleados e 
WHERE e.empleado_id IS NOT NULL AND TRIM(e.empleado_id) != '';

-- LLAVE FORÁNEA CIRCULAR PARA EL GERENTE
ALTER TABLE core.departamentos 
    ADD CONSTRAINT fk_depto_gerente FOREIGN KEY (gerente_id) 
    REFERENCES core.empleados(empleado_id) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;


---------------------------------------------------------------
------------------------- 4. SUELDOS --------------------------
---------------------------------------------------------------
CREATE TABLE core.sueldos (
    sueldo_id VARCHAR(7) PRIMARY KEY,
    empleado_id VARCHAR(7) NOT NULL,
    periodo_fecha DATE NOT NULL,
    periodo_incompleto BOOLEAN NOT NULL DEFAULT FALSE,
    monto NUMERIC(12,2),
    moneda VARCHAR(3) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sueldos_empleado FOREIGN KEY (empleado_id)
        REFERENCES core.empleados(empleado_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_sueldo_id_formato CHECK (sueldo_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_empleado_sueldo CHECK (empleado_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_monto_positivo CHECK (monto >= 0.0)
);

CREATE INDEX idx_sueldos_empleado_id ON core.sueldos(empleado_id);

INSERT INTO core.sueldos (
    sueldo_id,
    empleado_id,
    periodo_fecha,
    periodo_incompleto,
    monto,
    moneda,
    tipo
)
SELECT
    utils.limpiar_espacios(sueldo_id),
    utils.limpiar_espacios(empleado_id),
    utils.limpiar_fecha_generica(s.periodo)::DATE,
    utils.es_fecha_incompleta(s.periodo)::BOOLEAN,
    utils.limpiar_simbolo_moneda(s.monto)::numeric,
    UPPER(utils.formato_titulo(utils.normalizar_nulos(s.moneda))),
    utils.formato_titulo(utils.normalizar_nulos(s.tipo))
FROM staging.sueldos s
WHERE s.sueldo_id IS NOT NULL AND TRIM(s.sueldo_id) != '';

---------------------------------------------------------------
------------------------- 5. EVALUACIONES ---------------------
---------------------------------------------------------------
CREATE TABLE core.evaluaciones (
    eval_id VARCHAR(7) PRIMARY KEY,
    empleado_id VARCHAR(7) NOT NULL,
    evaluador_id VARCHAR(7) NOT NULL,
    periodo_original VARCHAR(20) NOT NULL,
    periodo_orden_key INT NOT NULL,
    puntaje NUMERIC(3,1),
    categoria VARCHAR(50),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_evaluaciones_empleado FOREIGN KEY (empleado_id)
        REFERENCES core.empleados(empleado_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_evaluaciones_evaluador FOREIGN KEY (evaluador_id)
        REFERENCES core.empleados(empleado_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_eval_id_formato CHECK (eval_id ~ '^EV[0-9]{4,6}$'),						   
    CONSTRAINT chk_empleado_eval CHECK (empleado_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_evaluador_id CHECK (evaluador_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_puntaje_rango CHECK (puntaje >= 0.0 AND puntaje <= 10.0)
);

CREATE INDEX idx_eval_empleado ON core.evaluaciones(empleado_id);

INSERT INTO core.evaluaciones (
    eval_id, 
    empleado_id, 
    evaluador_id, 
    periodo_original, 
    periodo_orden_key, 
    puntaje, 
    categoria
)
SELECT 
    utils.limpiar_espacios(e.eval_id), 
    utils.limpiar_espacios(e.empleado_id), 
    utils.limpiar_espacios(e.evaluador_id), 
    utils.limpiar_periodo(e.periodo), 
    utils.periodo_generar_orden_key(e.periodo)::INT, 
    utils.limpiar_espacios(utils.normalizar_nulos(e.puntaje))::numeric, 
    utils.formato_titulo(utils.normalizar_nulos(e.categoria))
FROM staging.evaluaciones e 
WHERE e.eval_id IS NOT NULL AND TRIM(e.eval_id) != '';

---------------------------------------------------------------
------------------------- 6. AUSENTISMO -----------------------
---------------------------------------------------------------
CREATE TABLE core.ausentismo (
    ausencia_id VARCHAR(7) PRIMARY KEY,
    empleado_id VARCHAR(7) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_inicio_incompleta BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_fin DATE NOT NULL,
    fecha_fin_incompleta BOOLEAN NOT NULL DEFAULT FALSE,
    tipo VARCHAR(50) NOT NULL,
    justificado VARCHAR(10),
    justificado_bool BOOLEAN,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ausentismo_empleado FOREIGN KEY (empleado_id) 
        REFERENCES core.empleados(empleado_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_ausencia_id_formato CHECK (ausencia_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_empleado_id_formato CHECK (empleado_id ~ '^[A-Z][0-9]{4,6}$'),
    CONSTRAINT chk_orden_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE INDEX idx_ausentismo_empleado ON core.ausentismo(empleado_id);

INSERT INTO core.ausentismo (
    ausencia_id,
    empleado_id,
    fecha_inicio,
    fecha_inicio_incompleta,
    fecha_fin,
    fecha_fin_incompleta,
    tipo,
    justificado,
    justificado_bool
)
SELECT
    utils.limpiar_espacios(a.ausencia_id),
    utils.limpiar_espacios(a.empleado_id),
    utils.limpiar_fecha_generica(a.fecha_inicio, 'inicio')::DATE,
    utils.es_fecha_incompleta(a.fecha_inicio)::BOOLEAN,
    utils.limpiar_fecha_generica(a.fecha_fin, 'fin')::DATE,
    utils.es_fecha_incompleta(a.fecha_fin)::BOOLEAN,
    utils.formato_titulo(utils.normalizar_nulos(a.tipo)),
	CASE WHEN utils.normalizar_booleano(a.justificado) THEN 'Sí'
     WHEN utils.normalizar_booleano(a.justificado) IS FALSE THEN 'No'
     ELSE NULL
	END,                                      -- justificado (VARCHAR)
	utils.normalizar_booleano(a.justificado)   -- justificado_bool
FROM staging.ausentismo a
WHERE a.ausencia_id IS NOT NULL AND TRIM(a.ausencia_id) != ''
AND a.empleado_id IS NOT NULL AND TRIM(a.empleado_id) != '';
---------------------------------------------------------------

--------------------FIN Tablas CORE--------------------
 