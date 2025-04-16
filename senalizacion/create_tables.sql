-- Crear el esquema si no existe
CREATE SCHEMA IF NOT EXISTS senializacion;

-- Tabla de Categorías
CREATE TABLE senializacion.categorias (
    id_categoria SERIAL PRIMARY KEY,
    codigo character varying(2) COLLATE pg_catalog."default" NOT NULL,
    nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    obs character varying COLLATE pg_catalog."default"
);


-- Tabla de Elementos (Ej: Reglamentarias, Preventivas, Informativas)
CREATE TABLE senializacion.elementos (
    id SERIAL PRIMARY KEY,
	id_categoria INTEGER NOT NULL REFERENCES senializacion.categorias(id_categoria),
    nombre character varying COLLATE pg_catalog."default" NOT NULL,
    obs character varying COLLATE pg_catalog."default",
	iconografia character varying(100) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
    cod_elemento character varying(3) COLLATE pg_catalog."default",
    CONSTRAINT cod_elemento_unico UNIQUE (cod_elemento)
);




-- Tabla de Subelementos (Ej: Prohibición, Restricción, Fin de prescripción)
CREATE TABLE senializacion.subelementos (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    elemento_id INTEGER NOT NULL REFERENCES senializacion.elementos(id),
    descripcion TEXT
);

-- Tabla de Señales (Ej: R1 - Prohibido Avanzar)
CREATE TABLE senializacion.senales (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    subelemento_id INTEGER REFERENCES senializacion.subelementos(id),
    forma TEXT, -- cuadrado, rectangular, circular
    dimensiones TEXT, -- esta no iria, sino en la de gis
    soporte TEXT, -- esta no iria, sino que va en la de gis
    contenido TEXT, -- cuando hay muchos casos va a la tabla de senal modificadores
    imagen TEXT, -- tiene que ser generica
    observaciones TEXT
);

CREATE TABLE senializacion.senal_modificadores (
    id SERIAL PRIMARY KEY,
    senal_id INTEGER REFERENCES senializacion.senales(id),
	contenido TEXT,
	tipo_vehiculo TEXT,         -- ejemplo: "texto adicional", "tipo vehículo", "horario", etc.
	leyenda_extra TEXT, -- ejemplo: valor de velocidad 60, 40 ,etc
    valor TEXT,         -- ejemplo: "solo camiones", "excepto emergencia", "de 22 a 6 hs"
	imagen TEXT
);




CREATE TABLE senializacion.senializacionvertical (
    id SERIAL PRIMARY KEY,
    
    -- Relaciones clave
    id_tramo BIGINT REFERENCES gisdata.tramos(id),
    id_banda BIGINT REFERENCES gisdata.bandas(id),
    id_senal INTEGER NOT NULL REFERENCES senializacion.senales(id),
	id_modificador INTEGER NOT NULL REFERENCES senializacion.senal_modificadores(id),

    
    -- Datos físicos del cartel
    forma VARCHAR(20),
    dimensiones VARCHAR(10),
    soporte VARCHAR(30),
    id_soporte INTEGER,
    
    -- Información operativa
    estado VARCHAR(24),
    pk VARCHAR(6),
    contenido VARCHAR(254),
    imagen VARCHAR(254),
    activo BOOLEAN DEFAULT TRUE,

    -- Fechas de gestión
    f_instalacion DATE,
    f_ult_interv DATE,
    fmodif DATE,
    create_timestamp TIMESTAMPTZ DEFAULT now(),
    edit_timestamp TIMESTAMPTZ,
    delete_timestamp TIMESTAMPTZ,

    -- Auditoría
    create_user VARCHAR,
    edit_user VARCHAR,
    delete_user VARCHAR,
    
    -- Historial
    padre INTEGER, -- ID del registro anterior, si corresponde

    -- Datos espaciales
    area DOUBLE PRECISION,
    geom geometry(Point, 4326)
);
