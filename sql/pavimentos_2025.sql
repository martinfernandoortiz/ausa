-- Table: geodatos.estadopavimentos2025

-- DROP TABLE IF EXISTS geodatos.estadopavimentos2025;

CREATE TABLE IF NOT EXISTS geodatos.estadopavimentos2025
(
    id integer NOT NULL DEFAULT nextval('geodatos.estadopavimentos2025_id_seq'::regclass),
    geom geometry(Point,4326),
    "AU" character varying COLLATE pg_catalog."default",
    "CARRIL_S/RELEV" integer,
    "SENTIDO" character varying COLLATE pg_catalog."default",
    "CARRIL_AUSA" integer,
    "PK_INICIO" double precision,
    "PK_FIN" double precision,
    "LATITUD" double precision,
    "LONGITUD" double precision,
    "AHU_(MM)" double precision,
    "RUG_(IRI_M/KM)" double precision,
    "FISURA_LINEAL_(M)" character varying COLLATE pg_catalog."default",
    "FISURACION_TIPO" character varying COLLATE pg_catalog."default",
    "FISURACION_porcentaje" character varying COLLATE pg_catalog."default",
    "BACHES_m2" double precision,
    "PEL_DESP_m2" double precision,
    "BACHEO_m2" double precision,
    field_17 character varying COLLATE pg_catalog."default",
    "ESTADO DE JUNTAS_BIEN" double precision,
    "ESTADO DE JUNTAS_REGULAR" double precision,
    "ESTADO DE JUNTAS_MAL" double precision,
    "TOTAL DETERIOROS_SUP" double precision,
    "TOTAL DE DETERIOROS_%" character varying COLLATE pg_catalog."default",
    "PARAMETROS_D1" integer,
    "PARAMETROS_D2" integer,
    "PARAMETROS_D3" integer,
    "PARAMETROS_D4" integer,
    "INDICE_DE_ESTADO" double precision,
    "INDICE_DE_SERVICIAB_PRESENTE" double precision,
    "OBSERVACIONES" character varying COLLATE pg_catalog."default",
    fisura double precision,
    id_tramo bigint,
    id_banda bigint,
    CONSTRAINT estadopavimentos2025_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS geodatos.estadopavimentos2025
    OWNER to postgres;
-- Index: sidx_estadopavimentos2025_geom

-- DROP INDEX IF EXISTS geodatos.sidx_estadopavimentos2025_geom;

CREATE INDEX IF NOT EXISTS sidx_estadopavimentos2025_geom
    ON geodatos.estadopavimentos2025 USING gist
    (geom)
    TABLESPACE pg_default;




	


UPDATE geodatos.estadopavimentos2025 AS pav
SET 

id_tramo = case when "AU" = 'DEL' then 6  
when "AU" ='9JS'  then 7
when "AU" ='RA3'	then 14
when "AU" ='RA2' then 14
when "AU" ='ILL' then 3
when "AU" ='25M' then 1
when "AU" = 'MBS' then 2
when "AU" ='CAN' then 9
when "AU" ='PDB' then 8
when "AU" ='LUG' then 10
when "AU" ='PEM'   then 4
when "AU" ='CAM'  then 5 END ;

UPDATE geodatos.estadopavimentos2025 AS pav
SET 

id_banda = case when "SENTIDO" = 'A' and id_tramo in (6,7,14,1,4,5) then 1  -- todo menos met, pdb, illi, aca,lug
 when "SENTIDO" = 'D' and id_tramo in (6,7,14,1,4,5) then 2  -- todo menos met, pdb, illi, aca,lug
 when "SENTIDO" = 'D' and id_tramo in (8) then 5  --pdb
when "SENTIDO" = 'A' and id_tramo in (8) then 6  --pdb
 when "SENTIDO" = 'A' and id_tramo in (3) then 2  --illia
 when "SENTIDO" = 'D' and id_tramo in (3) then 1  --illia
 when  id_tramo in (9) then 2  --illia
when  id_tramo in (10) then 1
end --illia end

when "AU" ='9JS'  then 7
when "AU" ='RA3'	then 14
when "AU" ='RA2' then 14
when "AU" ='ILL' then 3
when "AU" ='25M' then 1
when "AU" = 'MBS' then 2
when "AU" ='CAN' then 9
when "AU" ='PDB' then 8
when "AU" ='LUG' then 10
when "AU" ='PEM'   then 4
when "AU" ='CAM'  then 5 END ;



SELECT "FISURA_LINEAL_(M)"
FROM geodatos.estadopavimentos2025
WHERE "FISURA_LINEAL_(M)" !~ '^[0-9 ,.-]+$';  -- Ejemplo: "N/A", "Sin dato"

-- 2. Opción: Asignar NULL a valores inválidos
UPDATE geodatos.estadopavimentos2025
SET fisura = CASE 
    WHEN "FISURA_LINEAL_(M)" ~ '^[0-9 ,.-]+$' THEN 
        ROUND(REPLACE(TRIM("FISURA_LINEAL_(M)"), ',', '.')::NUMERIC, 1)
    ELSE 
        NULL 
END;


SELECT  "FISURACION_porcentaje"
FROM geodatos.estadopavimentos2025
WHERE "FISURA_LINEAL_(M)" !~ '^[0-9 ,.-]+$';  -- Ejemplo: "N/A", "Sin dato"

-- 2. Opción: Asignar NULL a valores inválidos
UPDATE geodatos.estadopavimentos2025
SET fisura = CASE 
    WHEN  "FISURACION_porcentaje" ~ '^[0-9 ,.-]+$' THEN 
        ROUND(REPLACE(TRIM( "FISURACION_porcentaje"), ',', '.')::NUMERIC, 1)
    ELSE 
        NULL 
END;


INSERT INTO gisdata.estadopavimentos2025 (
id_tramo,
id_banda,
    geom, 
    carril, 
    latitude, 
    longitude,  
    desde_km, 
    hasta_km, 
    iri, 
    ahuellam, 
    d1, 
    d2, 
    d3, 
    fisur_m,  -- Columna tipo DOUBLE PRECISION
    bache_m2,  
    pelad_m2,  
    d4, 
    nota1, 
    nota2, 
    ie, 
    isp, 
    obs,
	    "CARRIL_S/RELEV" ,
    "BACHEO_m2" ,
    "ESTADO DE JUNTAS_BIEN" ,
    "ESTADO DE JUNTAS_REGULAR" ,
    "ESTADO DE JUNTAS_MAL" ,
    "TOTAL DETERIOROS_SUP" ,
    "TOTAL DE DETERIOROS_%" 
)
SELECT  
id_tramo,
id_banda,
    st_transform(geom,5348),
    "CARRIL_AUSA",
    "LATITUD"::NUMERIC,
    "LONGITUD"::NUMERIC,
   "PK_INICIO",
  "PK_FIN",
 "RUG_(IRI_M/KM)"::NUMERIC AS iri,  -- Conversión explícita
 "AHU_(MM)"::NUMERIC AS ahuellam,
  "PARAMETROS_D1"::NUMERIC AS d1,
   "PARAMETROS_D2"::NUMERIC AS d2,
   "PARAMETROS_D3"::NUMERIC AS d3,
  fisura,
  "BACHES_m2"::NUMERIC AS bache_m2,
 "PEL_DESP_m2"::NUMERIC AS pelad_m2,
  "PARAMETROS_D4"::NUMERIC AS d4,
  "FISURACION_TIPO" AS nota1,
  ROUND(REPLACE(TRIM( "FISURACION_porcentaje"), ',', '.')::NUMERIC, 1),
  -- Asegurar tipo numérico
 "INDICE_DE_ESTADO"::NUMERIC AS ie,
 "INDICE_DE_SERVICIAB_PRESENTE"::NUMERIC AS isp,
  "OBSERVACIONES" AS obs,
  	    "CARRIL_S/RELEV" ,
    "BACHEO_m2" ,
    "ESTADO DE JUNTAS_BIEN" ,
    "ESTADO DE JUNTAS_REGULAR" ,
    "ESTADO DE JUNTAS_MAL" ,
    ROUND(REPLACE( "TOTAL DETERIOROS_SUP"::VARCHAR , ',', '.')::NUMERIC, 1),
    ROUND(REPLACE(TRIM("TOTAL DE DETERIOROS_%" ), ',', '.')::NUMERIC, 1)
FROM geodatos.estadopavimentos2025;




UPDATE geodatos.estadopavimentos2025
SET id_categ = CASE 
    WHEN  "FISURACION_porcentaje" ~ '^[0-9 ,.-]+$' THEN 
        ROUND(REPLACE(TRIM( "FISURACION_porcentaje"), ',', '.')::NUMERIC, 1)
    ELSE 
        NULL 
END;


UPDATE gisdata.estadopavimentos2025
SET id_categ = 12; 

UPDATE gisdata.estadopavimentos2025
SET id_elem = 167; 



-- View: gisdata.v_estadopavimentos2018

-- DROP VIEW gisdata.v_estadopavimentos2018;

CREATE OR REPLACE VIEW gisdata.v_estadopavimentos2025
 AS
 SELECT estadopavimentos2025.gid,
    estadopavimentos2025.id,
    st_transform(estadopavimentos2025.geom, 4326)::geometry(Point,4326) AS geom,
    longitude AS longitud,
    latitude AS latitud,
    estadopavimentos2025.id_tramo,
    tramos.codigo AS cod_tramo,
    tramos.nombre AS nom_tramo,
    estadopavimentos2025.id_banda,
    bandas.codigo AS cod_banda,
    bandas.nombre AS nom_banda,
    estadopavimentos2025.id_categ,
    categorias.codigo AS cod_categ,
    categorias.nombre AS nom_categ,
    estadopavimentos2025.id_elem,
    elementos.nombre AS nom_elem,
    estadopavimentos2025.carril,
    estadopavimentos2025.latitude,
    estadopavimentos2025.longitude,
    estadopavimentos2025.elevation,
    estadopavimentos2025.desde_km,
    estadopavimentos2025.hasta_km,
    estadopavimentos2025.pk,
    estadopavimentos2025.iri,
    estadopavimentos2025.ahuellam,
    estadopavimentos2025.d1,
    estadopavimentos2025.d2,
    estadopavimentos2025.d3,
    estadopavimentos2025.cant,
    estadopavimentos2025.fisur_m,
    estadopavimentos2025.field_27,
    estadopavimentos2025.sellado,
    estadopavimentos2025.bache_m2,
    estadopavimentos2025.field_30,
    estadopavimentos2025.est_bache,
    estadopavimentos2025.pelad_m2,
    estadopavimentos2025.field_33,
    estadopavimentos2025.d4,
    estadopavimentos2025.nota1,
    estadopavimentos2025.nota2,
    estadopavimentos2025.carp_rod,
    estadopavimentos2025.fecha_ejecucion,
    estadopavimentos2025.ult_int,
    estadopavimentos2025.ie,
    estadopavimentos2025.isp,
    estadopavimentos2025.imagen,
    estadopavimentos2025.vinculo,
    estadopavimentos2025.obs
   FROM gisdata.estadopavimentos2025
     LEFT JOIN gisdata.tramos ON estadopavimentos2025.id_tramo = tramos.id
     LEFT JOIN gisdata.bandas ON estadopavimentos2025.id_banda = bandas.id
     LEFT JOIN gisdata.categorias ON estadopavimentos2025.id_categ = categorias.id
     LEFT JOIN gisdata.elementos ON estadopavimentos2025.id_elem = elementos.id;

ALTER TABLE gisdata.v_estadopavimentos2025
    OWNER TO postgres;

GRANT ALL ON TABLE gisdata.v_estadopavimentos2025 TO mcastillo;
GRANT ALL ON TABLE gisdata.v_estadopavimentos2025 TO postgres;
GRANT SELECT ON TABLE gisdata.v_estadopavimentos2025 TO sololectura;
