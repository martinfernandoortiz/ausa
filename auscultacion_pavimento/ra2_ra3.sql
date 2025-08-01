-- Data wrangling para poder armar la capa de auscultacion.


-- Table: geodatos.estadopavimentos2025_r2

-- DROP TABLE IF EXISTS geodatos.estadopavimentos2025_r2;

CREATE TABLE IF NOT EXISTS geodatos.estadopavimentos2025_r2
(
    id integer NOT NULL,
    au character varying COLLATE pg_catalog."default",
    "carril_s/relev" integer,
    sentido character varying COLLATE pg_catalog."default",
    carril_ausa integer,
    pk_inicio character varying COLLATE pg_catalog."default",
    pk_fin character varying COLLATE pg_catalog."default",
    latitud integer,
    longitud integer,
    "ahu_(mm)" character varying COLLATE pg_catalog."default",
    "rug_(iri_m/km)" character varying COLLATE pg_catalog."default",
    "fisura_lineal_(m)" character varying COLLATE pg_catalog."default",
    fisuracion_tipo character varying COLLATE pg_catalog."default",
    fisuracion_porcentaje character varying COLLATE pg_catalog."default",
    baches_m2 character varying COLLATE pg_catalog."default",
    pel_desp_m2 character varying COLLATE pg_catalog."default",
    bacheo_m2 character varying COLLATE pg_catalog."default",
    field_17 character varying COLLATE pg_catalog."default",
    field_18 character varying COLLATE pg_catalog."default",
    "estado de juntas_bien" character varying COLLATE pg_catalog."default",
    "estado de juntas_regular" character varying COLLATE pg_catalog."default",
    "estado de juntas_mal" character varying COLLATE pg_catalog."default",
    "total deterioros_sup" character varying COLLATE pg_catalog."default",
    "total de deterioros_%" character varying COLLATE pg_catalog."default",
    parametros_d1 integer,
    parametros_d2 integer,
    parametros_d3 integer,
    parametros_d4 integer,
    indice_de_estado character varying COLLATE pg_catalog."default",
    indice_de_serviciab_presente character varying COLLATE pg_catalog."default",
    observaciones character varying COLLATE pg_catalog."default",
    cod_tramo character varying(3) COLLATE pg_catalog."default",
    cod_banda character varying(1) COLLATE pg_catalog."default",
    pk_final numeric,
    pk_ini numeric,
    borrar numeric,
    pk integer,
    pk_georef text COLLATE pg_catalog."default",
    join_field text COLLATE pg_catalog."default",
    id_tramo integer,
    id_via integer,
    id_banda integer,
    geom geometry,
    fid smallint NOT NULL,
    CONSTRAINT estadopavimentos2025_r2_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS geodatos.estadopavimentos2025_r2
    OWNER to postgres;

-- ESTADO PAVIMENTOS
-- SE USA EL EXCEL DE ESTRUCTURA QUE ESTA EN GIS/ESTADOPAVIMENTOS/2025 Y SE PASA DESDE QGIS TODO CRUDO. Si no tenemos el excel la estructura es: 




-- CREAR CAMPOS

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN cod_tramo VARCHAR(3);


ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN cod_banda VARCHAR(1);

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN pk_ini numeric;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN pk_final numeric;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN borrar numeric;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN pk_georef text;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN pk integer;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN join_field text;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN id_tramo integer;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN id_via integer;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN id_banda integer;

ALTER TABLE gisdata.estadopavimentos2025_10m
ADD COLUMN lat_ok double precision,
ADD COLUMN lon_ok double precision;

ALTER TABLE geodatos.estadopavimentos2025_r2
ADD COLUMN geom geometry;




--- ACTUALIZAR COD_TRAMO
UPDATE geodatos.estadopavimentos2025_r2
SET cod_tramo = CASE 
    WHEN au = 'ILL' THEN 'AU2'
    WHEN au = '25M' THEN 'AU1'
    WHEN au = 'CAN' THEN 'ACA'
    WHEN au = 'PDB' THEN 'PDB'
    WHEN au = 'LUG' THEN 'ALU'
    WHEN au = 'PEM' THEN 'AU6'
    WHEN au = 'CAM' THEN 'AU7'
    WHEN au = 'DEL' THEN 'AUD'
    WHEN au = '9JS' THEN 'AU9'
    WHEN au = 'RA3' THEN 'NDL'
    WHEN au = 'RA2' THEN 'NDL'        
else null
END;



-- select * from geodatos.estadopavimentos2025_r2 limit 10;
-- select distinct sentido from geodatos.estadopavimentos2025_r2 ; 



-- ACTUALIZAR BANDAS
UPDATE geodatos.estadopavimentos2025_r2
SET cod_banda = CASE 
    WHEN sentido = 'D' THEN 'B'
    WHEN sentido = 'A' THEN 'A' END;

        
UPDATE geodatos.estadopavimentos2025_r2
SET cod_banda = 'N' 
    WHERE cod_tramo = 'PDB' and sentido ='A';

UPDATE geodatos.estadopavimentos2025_r2
SET cod_banda = 'S' 
    WHERE cod_tramo = 'PDB'and sentido ='D';


-- ACTUALIZACION PKS
UPDATE geodatos.estadopavimentos2025_r2
SET pk_ini = pk_inicio::numeric;

-- mayores a 1000
UPDATE geodatos.estadopavimentos2025_r2
SET pk_ini = pk_inicio::numeric * 1000
where pk_inicio::numeric < 1;
UPDATE geodatos.estadopavimentos2025_r2
SET pk_final = pk_fin::numeric  * 1000
where pk_fin::numeric < 1;

-- menores a mil
UPDATE geodatos.estadopavimentos2025_r2
SET pk_ini = pk_inicio::numeric *1000
where pk_inicio::numeric < 1;

UPDATE geodatos.estadopavimentos2025_r2
SET pk_final = pk_fin::numeric  * 1000
where pk_fin::numeric < 1;


UPDATE geodatos.estadopavimentos2025_r2
SET pk_final = pk_fin::numeric

--select pk_ini, pk_final from geodatos.estadopavimentos2025_r2

UPDATE geodatos.estadopavimentos2025_r2
SET borrar = (pk_ini - pk_final)/2

select borrar from geodatos.estadopavimentos2025_r2 order by borrar asc;



UPDATE geodatos.estadopavimentos2025_r2
SET pk = pk_final + borrar;


--select pk_ini, pk_final, pk_georef from geodatos.estadopavimentos2025_r2 order by pk_ini desc ; 


UPDATE geodatos.estadopavimentos2025_r2
SET pk_georef = CASE
    WHEN length(pk::text) = 1 THEN '0+00' || pk::text
    WHEN length(pk::text) = 2 THEN '0+0' || pk::text
    WHEN length(pk::text) = 3 THEN '0+' || pk::text
    WHEN length(pk::text) = 4 THEN substr(pk::text, 1, 1) || '+' || substr(pk::text, 2)
    WHEN length(pk::text) = 5 THEN substr(pk::text, 1, 2) || '+' || substr(pk::text, 3)
    ELSE NULL
END;



-- JOIN FIELD
update geodatos.estadopavimentos2025_r2
set  join_field = cod_tramo ||'_' || cod_banda|| '_'|| pk_georef || '_'|| carril_ausa ;

--select * from geodatos.estadopavimentos2025_r2 limit 10;

-- id_tramo
update geodatos.estadopavimentos2025_r2
set  id_tramo = case when cod_tramo = 'AU2' then 3
					 when cod_tramo = 'PDB' then 8
					 when cod_tramo = 'ACA' then 9
					 when cod_tramo = 'ALU' then 10
					 when cod_tramo = 'NG1' then 11
					 when cod_tramo = 'AU1' then 1
					 when cod_tramo = 'MET' then 2
					 when cod_tramo = 'AU6' then 4
					 when cod_tramo = 'AU7' then 5
					 when cod_tramo = 'AUD' then 6
					 when cod_tramo = 'NG2' then 12
					 when cod_tramo = 'NG3' then 13
					 when cod_tramo = 'AU9' then 7
					 when cod_tramo = 'FDT' then 20
					 when cod_tramo = 'NDL' then 14
					 when cod_tramo = 'N9J' then 15
					 when cod_tramo = 'NHU' then 16
					 when cod_tramo = 'NPN' then 17
					 when cod_tramo = 'NPP' then 18
					 END;

--select * from gisdata.bandas;

-- cod via OJO SI ES DISTRIBUIDOR!
update geodatos.estadopavimentos2025_r2
set  id_via = 3;


update geodatos.estadopavimentos2025_r2
set  id_banda = case when cod_banda = 'A' then 1
					 when cod_banda = 'B' then 2
					 when cod_banda = 'C' then 3
					 when cod_banda = 'M' then 4
					 when cod_banda = 'FT' then 10
					 when cod_banda = 'N' then 5
					 when cod_banda = 'S' then 6 
					 END;



UPDATE geodatos.estadopavimentos2025_r2 AS a
SET geom = ST_SetSRID(b.geom, 5348)
FROM geodatos.progresivas_carriles AS b
WHERE a.id_tramo = b.id_tramo
  AND a.id_banda = b.id_banda
  AND a.pk_georef = b.pk
  AND a.id_via = b.id_via
  AND a.carril_ausa = b.nro_carril
  AND nom_rama = 'R2';

select id_tramo, id_banda, pk, id_via, nro_carril, geom from geodatos.progresivas_carriles;

select * from geodatos.estadopavimentos2025_r2 where geom is null
--select count(*)from geodatos.estadopavimentos2025_r2 

select geom from geodatos.estadopavimentos2025_r2 limit 10;
select distinct cod_tramo from geodatos.estadopavimentos2025_r2 limit 10;

select distinct cod_banda from geodatos.estadopavimentos2025_r2 limit 10;
select distinct cod_banda from geodatos.estadopavimentos2025_r2 limit 10;


update geodatos.estadopavimentos2025_r2 
set lat =0
where geom is not null;

select distinct cod_tramo, count(cod_tramo) from geodatos.estadopavimentos2025_r2 
where geom is null group by cod_tramo
 limit 1000;


UPDATE geodatos.estadopavimentos2025_r2
SET geom = ST_Transform(
              ST_SetSRID(
                ST_MakePoint(
                  REPLACE(longitud::text, '-58', '-58.')::double precision,
                  REPLACE(latitud::text,  '-34', '-34.')::double precision
                ),
                4326
              ),
              5348
           )
WHERE geom IS NULL AND latitud IS NOT NULL AND longitud IS NOT NULL;





UPDATE gisdata.estadopavimentos2025_10m
SET
  lat_ok = ST_Y(ST_Transform(ST_GeometryN(geom, 1), 4326)),
  lon_ok = ST_X(ST_Transform(ST_GeometryN(geom, 1), 4326))
WHERE geom IS NOT NULL
  AND GeometryType(geom) = 'MULTIPOINT';

  create view gisdata.v_estadopavimentos2025_10m
  as 
  select * from gisdata.estadopavimentos2025_10m


  select * from gisdata.estadopavimentos2025_10m order by id desc



  SELECT column_name FROM information_schema.columns 
WHERE table_name = 'estadopavimentos2025_10m' 
  AND table_schema = 'gisdata';





INSERT INTO gisdata.estadopavimentos2025_10m (
  geom,
  fid,
  au,
  "carril_s/relev",
  sentido,
  carril_ausa,
  pk_inicio,
  pk_fin,
  latitud,
  longitud,
  "ahu_(mm)",
  "rug_(iri_m/km)",
  "fisura_lineal_(m)",
  fisuracion_tipo,
  fisuracion_porcentaje,
  baches_m2,
  pel_desp_m2,
  bacheo_m2,
  "estado de juntas_bien",
  "estado de juntas_regular",
  "estado de juntas_mal",
  "total deterioros_sup",
  "total de deterioros_%",
  parametros_d1,
  parametros_d2,
  parametros_d3,
  parametros_d4,
  indice_de_estado,
  indice_de_serviciab_presente,
  observaciones,
  cod_tramo,
  cod_banda,
  pk_ini,
  pk_final,
  borrar,
  pk,
  pk_georef,
  join_field,
  id_tramo,
  id_banda,
  id_via
)
SELECT
  ST_Multi(st_transform(geom,4326)) as geom,
  fid,
  au,
  "carril_s/relev",
  sentido,
  carril_ausa,
  pk_inicio,
  pk_fin,
  latitud,
  longitud,
  "ahu_(mm)",
  "rug_(iri_m/km)",
  "fisura_lineal_(m)",
CASE 
  WHEN fisuracion_tipo ~ '^\d+$' THEN fisuracion_tipo::integer 
  ELSE NULL 
END,
fisuracion_porcentaje,
  baches_m2,
  pel_desp_m2,
  bacheo_m2,
  "estado de juntas_bien",
  "estado de juntas_regular",
  "estado de juntas_mal",
  "total deterioros_sup",
  "total de deterioros_%",
  parametros_d1,
  parametros_d2,
  parametros_d3,
  parametros_d4,
  indice_de_estado,
  indice_de_serviciab_presente,
  observaciones,
  cod_tramo,
  cod_banda,
  pk_ini,
  pk_final,
  borrar,
  pk,
  pk_georef,
  join_field,
  id_tramo,
  id_banda,
  id_via
FROM geodatos.estadopavimentos2025_r2;


SELECT column_default
FROM information_schema.columns
WHERE table_schema = 'public' -- o el esquema correcto
  AND table_name = 'estadopavimentos2025_10m'
  AND column_name = 'id';



CREATE SEQUENCE IF NOT EXISTS gisdata.estadopavimentos2025_10m_id_seq;

ALTER TABLE gisdata.estadopavimentos2025_10m
ALTER COLUMN id SET DEFAULT nextval('gisdata.estadopavimentos2025_10m_id_seq')

SELECT setval(
  'gisdata.estadopavimentos2025_10m_id_seq',
  COALESCE((SELECT MAX(id) FROM gisdata.estadopavimentos2025_10m), 0) + 1
);
