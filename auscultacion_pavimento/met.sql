-- Data wrangling para poder armar la capa de auscultacion. El motivo de todo esto es que las coordenadas están mal....
-- ESTADO PAVIMENTOS
-- SE USA EL EXCEL DE ESTRUCTURA QUE ESTA EN GIS/ESTADOPAVIMENTOS/2025 Y SE PASA DESDE QGIS TODO CRUDO. Si no tenemos el excel la estructura es: 

-- Table: geodatos.estadopavimentos2025_met




-- CREAR CAMPOS

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN cod_tramo VARCHAR(3);


ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN cod_banda VARCHAR(1);

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN pk_ini numeric;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN pk_final numeric;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN borrar numeric;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN pk_georef text;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN pk integer;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN join_field text;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN id_tramo integer;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN id_via integer;

ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN id_banda integer;



ALTER TABLE geodatos.estadopavimentos2025_met
ADD COLUMN geom geometry;




--- ACTUALIZAR COD_TRAMO
UPDATE geodatos.estadopavimentos2025_met
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
	WHEN au = 'MBS' THEN 'MET'
else null
END;



-- select * from geodatos.estadopavimentos2025_met limit 10;
-- select distinct sentido from geodatos.estadopavimentos2025_met ; 



-- ACTUALIZAR BANDAS
UPDATE geodatos.estadopavimentos2025_met
SET cod_banda = 'M';

       


-- ACTUALIZACION PKS INICIO
UPDATE geodatos.estadopavimentos2025_met
SET pk_ini = pk_inicio::numeric;


-- mayores a 1000
UPDATE geodatos.estadopavimentos2025_met
SET pk_ini = pk_inicio::numeric 
where pk_inicio::numeric > 1;


UPDATE geodatos.estadopavimentos2025_met
SET pk_final = pk_fin::numeric  

UPDATE geodatos.estadopavimentos2025_met
SET pk_final = pk_fin::numeric 
where pk_final::numeric > 1;


select pk_ini, pk_final from geodatos.estadopavimentos2025_met where pk_inicio::numeric > 1;



-- menores a mil
UPDATE geodatos.estadopavimentos2025_met
SET pk_ini = pk_inicio::numeric *1000
where pk_inicio::numeric < 1;

UPDATE geodatos.estadopavimentos2025_met
SET pk_final = pk_fin::numeric  * 1000
where pk_fin::numeric < 1;




--select pk_ini, pk_final from geodatos.estadopavimentos2025_met

UPDATE geodatos.estadopavimentos2025_met
SET borrar = (pk_ini - pk_final)/2

select pk_ini, pk_final,pk_georef, pk from geodatos.estadopavimentos2025_met;



UPDATE geodatos.estadopavimentos2025_met
SET pk = pk_final -5;


--select pk_ini, pk_final, pk_georef from geodatos.estadopavimentos2025_met order by pk_ini desc ; 


UPDATE geodatos.estadopavimentos2025_met
SET pk_georef = CASE
    WHEN length(pk::text) = 1 THEN '0+00' || pk::text
    WHEN length(pk::text) = 2 THEN '0+0' || pk::text
    WHEN length(pk::text) = 3 THEN '0+' || pk::text
    WHEN length(pk::text) = 4 THEN substr(pk::text, 1, 1) || '+' || substr(pk::text, 2)
    WHEN length(pk::text) = 5 THEN substr(pk::text, 1, 2) || '+' || substr(pk::text, 3)
    ELSE NULL
END;

--select pk_ini, pk_final, pk_georef from geodatos.estadopavimentos2025_met


-- JOIN FIELD
update geodatos.estadopavimentos2025_met
set  join_field = cod_tramo ||'_' || cod_banda|| '_'|| pk_georef || '_'|| carril_ausa ;

--select * from geodatos.estadopavimentos2025_met limit 10;

-- id_tramo
update geodatos.estadopavimentos2025_met
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
update geodatos.estadopavimentos2025_met
set  id_via = 1;


update geodatos.estadopavimentos2025_met
set  id_banda = case when cod_banda = 'A' then 1
					 when cod_banda = 'B' then 2
					 when cod_banda = 'C' then 3
					 when cod_banda = 'M' then 4
					 when cod_banda = 'FT' then 10
					 when cod_banda = 'N' then 5
					 when cod_banda = 'S' then 6 
					 END;



UPDATE geodatos.estadopavimentos2025_met AS a
SET geom = ST_SetSRID(b.geom, 4326)
FROM  gisdata.v_progresivas_met AS b
WHERE 
   a.pk_georef = b.pk
  ;




update geodatos.estadopavimentos2025_met 
set lat =0
where geom is not null;

select distinct cod_tramo, count(cod_tramo) from geodatos.estadopavimentos2025_met 
where geom is null group by cod_tramo
 limit 1000;


UPDATE geodatos.estadopavimentos2025_met
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

select * from 



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








INSERT INTO gisdata.estadopavimentos2025_10m (
  geom,
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
  pk,
  pk_georef,
  join_field,
  id_tramo,
  id_banda,
  id_via
)
SELECT
  ST_Multi(st_transform(geom,4326)) as geom,
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
 fisuracion_tipo ,

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
  pk,
  pk_georef,
  join_field,
  id_tramo,
  id_banda,
  id_via
FROM geodatos.estadopavimentos2025_met;





CREATE SEQUENCE IF NOT EXISTS gisdata.estadopavimentos2025_10m_id_seq;

ALTER TABLE gisdata.estadopavimentos2025_10m
ALTER COLUMN id SET DEFAULT nextval('gisdata.estadopavimentos2025_10m_id_seq')

SELECT setval(
  'gisdata.estadopavimentos2025_10m_id_seq',
  COALESCE((SELECT MAX(id) FROM gisdata.estadopavimentos2025_10m), 0) + 1
);




UPDATE gisdata.estadopavimentos2025_10m
SET
  lat_ok = ST_Y(ST_Transform(ST_GeometryN(geom, 1), 4326)),
  lon_ok = ST_X(ST_Transform(ST_GeometryN(geom, 1), 4326))
WHERE geom IS  NULL
  AND GeometryType(geom) = 'MULTIPOINT';
