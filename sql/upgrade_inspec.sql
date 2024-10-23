/*SELECT * FROM formularios.inspec_moc_def
ORDER BY fid ASC LIMIT 100

DELETE FROM formularios.inspec_moc_def
WHERE fid>56 ; */


-- DATA WRANGLING DE LA TABLA DE INSPECCION DE DEFENSAS MANUAL


-- MODIFICAR EL TIPO DE DATOS DESDE R
ALTER TABLE formularios.inspec_moc_def
ALTER COLUMN item TYPE NUMERIC
USING item::numeric;

ALTER TABLE formularios.inspec_moc_def
ALTER COLUMN hojas TYPE NUMERIC
USING hojas::numeric;

ALTER TABLE formularios.inspec_moc_def
ALTER COLUMN postes TYPE NUMERIC
USING postes::numeric;

UPDATE formularios.inspec_moc_def
SET fecha='2024-10-01';

ALTER TABLE formularios.inspec_moc_def
ADD COLUMN carril text;

select distinct fecha from formularios.inspec_moc_def;

ALTER TABLE formularios.inspec_moc_def
ADD COLUMN id_tramo numeric;


UPDATE formularios.inspec_moc_def
SET id_tramo =
			case
			when autopista2= 'AU ILLIA' then 3
			when autopista2='AU7' then 5
			when autopista2='AU6' then 4
			when autopista2='DELLEPIANE' then 6
			when autopista2='TRANSICION AU1-AU6' then 99
			when autopista2='AVI SUR' then 7
			when autopista2='CANTILO' then 9
			when autopista2='LUGONES' then 10
			when autopista2='METROBUS' then 2
			when autopista2='PDB' then 8
			when autopista2= 'AU1' then 1 else 0 end

	ALTER TABLE formularios.inspec_moc_def
ADD COLUMN cod_tramo varchar;


UPDATE formularios.inspec_moc_def
SET cod_tramo =
			case
			when autopista2= 'AU ILLIA' then 'AU2'
			when autopista2='AU7' then 'AU7'
			when autopista2='AU6' then 'AU6'
			when autopista2='DELLEPIANE' then 'DEL'
			when autopista2='TRANSICION AU1-AU6' then 'RCA'
			when autopista2='AVI SUR' then 'AU9'
			when autopista2='CANTILO' then 'ACA'
			when autopista2='LUGONES' then 'LUG'
			when autopista2='METROBUS' then 'MET'
			when autopista2='PDB' then 'PDB'
			when autopista2= 'AU1' then 'AU1' else 'MAL'::text end


ALTER TABLE formularios.inspec_moc_def
ADD COLUMN id_ejecucion text;
ALTER TABLE formularios.inspec_moc_def
ADD COLUMN kb_id numeric;
select * from formularios.inspec_moc_def;


-- A PARTIR DE ACA VAMOS A ADAPTAR LO QUE VIENE DE KOBO


-- Vista Materializada de defensas



DROP MATERIALIZED VIEW IF EXISTS formularios.v_inspec_mant_obra_civil_defe;

CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_inspec_mant_obra_civil_defe
TABLESPACE pg_default
AS
 SELECT DISTINCT inspec_mant_obra_civil.gid,
    inspec_mant_obra_civil.fecha::character varying AS fecha_carga,
    inspec_mant_obra_civil.tipo_inspeccion,
        CASE
            WHEN inspec_mant_obra_civil.tipo_inspeccion::text = 'mensual'::text THEN inspec_mant_obra_civil.item
            ELSE 0::numeric
        END AS item,
    v_zonas_pavimentos.cod_tramo,
    v_zonas_pavimentos.nom_tramo,
        CASE
            WHEN v_zonas_pavimentos.id_tramo = 9 THEN 'Provincia'::text
            WHEN v_zonas_pavimentos.id_tramo = 10 THEN 'Centro'::text
            WHEN inspec_mant_obra_civil.banda_c::text = 'S'::text THEN 'Sur'::text
            WHEN inspec_mant_obra_civil.banda_c::text = 'N'::text THEN 'Norte'::text
            ELSE bandas.nombre::text
        END AS nom_banda,
    v_zonas_pavimentos.cod_via,
    v_zonas_pavimentos.nom_via,
    v_zonas_pavimentos.zonatraza,
    inspec_mant_obra_civil.km::numeric(10,3)::text AS km,
    inspec_mant_obra_civil.ubicacion_banda,
    inspec_mant_obra_civil.ubicacion_nro_columna,
        CASE
            WHEN inspec_mant_obra_civil.hojas IS NOT NULL THEN inspec_mant_obra_civil.hojas
            ELSE 0::numeric
        END AS hojas,
        CASE
            WHEN inspec_mant_obra_civil.hojas > 0::numeric THEN inspec_mant_obra_civil.hojas * 7.62
            ELSE 0::numeric
        END AS largo_m,
        CASE
            WHEN inspec_mant_obra_civil.postes IS NOT NULL THEN inspec_mant_obra_civil.postes
            ELSE 0::numeric
        END AS postes,
        CASE
            WHEN inspec_mant_obra_civil.prioridad::text = 'peligroso'::text THEN 'Planificada a la brevedad'::text
            WHEN inspec_mant_obra_civil.prioridad::text = 'no_peligroso'::text THEN 'Planificada'::text
            ELSE NULL::text
        END AS prioridad,
    inspec_mant_obra_civil.obs,
    NULLIF((string_to_array(inspec_mant_obra_civil.kb_lonlat::text, ','::text))[1], ''::text)::numeric AS latitud,
    NULLIF((string_to_array(inspec_mant_obra_civil.kb_lonlat::text, ','::text))[2], ''::text)::numeric AS longitud,
        CASE
            WHEN length(inspec_mant_obra_civil.kb_lonlat::text) > 1 THEN st_setsrid(st_makepoint(split_part(inspec_mant_obra_civil.kb_lonlat::text, ','::text, 2)::numeric::double precision, split_part(inspec_mant_obra_civil.kb_lonlat::text, ','::text, 1)::numeric::double precision), 4326)::geometry(Point,4326)
            ELSE NULL::geometry(Point,4326)
        END AS geom,
        CASE
            WHEN inspec_mant_obra_civil.id_ejecucion::text <> 'n/a'::text THEN ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || inspec_mant_obra_civil.id_ejecucion::text) || '&'' target=''_blank''>Editar registro relacionado en KoboToolBox</a>'::text
            ELSE NULL::text
        END AS linkeditorrelativo,
	inspec_mant_obra_civil.id_ejecucion,
	inspec_mant_obra_civil.kb_lonlat,
	inspec_mant_obra_civil.kb_id,
	inspec_mant_obra_civil.selec_activo as select_activo


   FROM formularios.inspec_mant_obra_civil
     LEFT JOIN gisdata.v_zonas_pavimentos ON inspec_mant_obra_civil.autopista::text = v_zonas_pavimentos.cod_tramo::text
     LEFT JOIN gisdata.bandas ON COALESCE(inspec_mant_obra_civil.banda, inspec_mant_obra_civil.banda_a, inspec_mant_obra_civil.banda_b, inspec_mant_obra_civil.banda_c, inspec_mant_obra_civil.banda_d)::text = bandas.codigo::text
  WHERE inspec_mant_obra_civil.selec_activo::text = 'defensas'::text
WITH DATA;


ALTER TABLE IF EXISTS formularios.v_inspec_mant_obra_civil_defe
    OWNER TO postgres;

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_defe TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe TO postgres;


-- Vista PowerBI


-- View: formularios.v_inspec_mant_obra_civil_defe_powerbi

-- DROP VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi;

CREATE OR REPLACE VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi
 AS
 SELECT v_inspec_mant_obra_civil_defe.gid,
    v_inspec_mant_obra_civil_defe.fecha_carga,
    v_inspec_mant_obra_civil_defe.tipo_inspeccion,
    v_inspec_mant_obra_civil_defe.item,
    v_inspec_mant_obra_civil_defe.cod_tramo,
    v_inspec_mant_obra_civil_defe.nom_tramo,
    v_inspec_mant_obra_civil_defe.nom_banda,
    v_inspec_mant_obra_civil_defe.cod_via,
    v_inspec_mant_obra_civil_defe.nom_via,
    v_inspec_mant_obra_civil_defe.zonatraza,
    v_inspec_mant_obra_civil_defe.km,
    v_inspec_mant_obra_civil_defe.ubicacion_banda,
    v_inspec_mant_obra_civil_defe.ubicacion_nro_columna,
    v_inspec_mant_obra_civil_defe.hojas,
    v_inspec_mant_obra_civil_defe.largo_m,
    v_inspec_mant_obra_civil_defe.postes,
    v_inspec_mant_obra_civil_defe.prioridad,
    v_inspec_mant_obra_civil_defe.obs,
    v_inspec_mant_obra_civil_defe.latitud,
    v_inspec_mant_obra_civil_defe.longitud,
    v_inspec_mant_obra_civil_defe.geom,
    v_inspec_mant_obra_civil_defe.linkeditorrelativo
   FROM formularios.v_inspec_mant_obra_civil_defe;

ALTER TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO postgres;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO powerbi_reader;

-- MErge de las dos tablas


/* Hasta el fid 56 inclusive son las defensas de octubre que no fueron via kobo */

-- Se insertan las defensas inspeccionadas desde KOBO
INSERT INTO formularios.inspec_moc_def (item, banda,ubicacion,progresiva,hojas,postes,prioridad,observaciones,fecha,kb_lonlat,tipo_inspeccion,kb_id,cod_tramo,select_activo,id_ejecucion,geom)
 SELECT  item, nom_banda, ubicacion_nro_columna,km,hojas,postes,prioridad,ubicacion_banda ||' ' || obs,fecha_carga,kb_lonlat,tipo_inspeccion, kb_id,cod_tramo::text,select_activo,id_ejecucion,geom
 FROM formularios.v_inspec_mant_obra_civil_defe
 where select_activo = 'defensas'



INSERT INTO formularios.inspec_moc_def (item, banda,ubicacion,progresiva,hojas,postes,prioridad,observaciones,fecha,kb_lonlat,tipo_inspeccion,kb_id,cod_tramo,select_activo,id_ejecucion,carril,geom)
 SELECT  item, nom_banda, ubicacion_nro_columna,km,hojas,postes,prioridad, obs,fecha_carga,kb_lonlat,tipo_inspeccion, kb_id,cod_tramo::text,select_activo,id_ejecucion,carril,geom
 FROM formularios.v_inspec_mant_obra_civil_pavi;



INSERT INTO formularios.inspec_moc_def (item, banda,ubicacion,progresiva,hojas,postes,prioridad,observaciones,fecha,kb_lonlat,tipo_inspeccion,cod_tramo,select_activo,id_ejecucion,carril,geom)
 SELECT  item::numeric, banda, ubicacion,km,hojas,postes,prioridad,obse,fecha::text ,kb_lonlat,tipo_inspeccion, autopista2,selec_activo,id_ejecucion,carril,geom
 FROM geodatos.pavi_borrar;




UPDATE formularios.inspec_moc_def
SET prioridad =
			case
			when prioridad = 'Planificada a la brevedad' then '1'
			when prioridad = 'Planificada' then '2'
	else prioridad end

UPDATE formularios.inspec_moc_def
SET banda =
			case
			when banda = 'Centro' then 'A'
			when banda = 'Norte' then 'N'
			when banda = 'Provincia' then 'B'
			when banda = 'Sur' then 'S'
	else banda end;


	
UPDATE formularios.inspec_moc_def
SET id_ejecucion =
			case
			when id_ejecucion = 'n/a' then null
			else id_ejecucion end;

UPDATE formularios.inspec_moc_def
SET select_activo =
			case
			when select_activo in ('defensas','Defensas')then 'Defensa'
			when select_activo in ('pavimento','Pavimentos')then 'Pavimento'
			else select_activo end;

/*
DELETE FROM formularios.inspec_moc_def
WHERE fid>56 ; 
SELECT MAX(fid) FROM formularios.inspec_moc_def;
SELECT setval('formularios.inspec_moc_def_fid_seq', (SELECT MAX(fid) FROM formularios.inspec_moc_def));
*/

/*	
SELECT     column_name,     data_type
FROM     information_schema.columns
WHERE    table_name = 'inspec_moc_def';
*/

ALTER TABLE formularios.inspec_moc
ADD COLUMN lat float;

ALTER TABLE formularios.inspec_moc
ADD COLUMN lon float;

UPDATE formularios.inspec_moc
SET lat = round(st_y(geom)::numeric,6);

UPDATE formularios.inspec_moc
SET lon = round(st_x(geom)::numeric,6);

UPDATE formularios.inspec_moc
SET cod_tramo= case when cod_tramo = 'LUG' then ' ALU'
	 when cod_tramo = 'DEL' then ' AUD'
	when cod_tramo = 'RCA' then 'AU6'
	else cod_tramo end
	

ALTER TABLE formularios.inspec_moc
ADD COLUMN via_cod varchar;

UPDATE formularios.inspec_moc
SET via_cod = case when id_tramo =99 then 'RCA'
	else 'PPL' end;



DROP VIEW formularios.v_inspec_moc_def_powerbi;

DROP MATERIALIZED VIEW IF EXISTS formularios.v_inspec_moc_def;
DROP VIEW formularios.v_inspec_moc_pav_powerbi;


DROP MATERIALIZED VIEW IF EXISTS formularios.v_inspec_moc_def_BORRAR;
CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_inspec_moc_def_BORRAR
TABLESPACE pg_default
AS
 SELECT 
	distinct v.fid as gid, 
	v.fecha as fecha_carga,
	v.tipo_inspeccion,

	  CASE
            WHEN v.tipo_inspeccion::text = 'mensual'::text THEN v.item
            ELSE 0::numeric
        END AS item,

    v_zonas_pavimentos.cod_tramo,
    v_zonas_pavimentos.nom_tramo,

        CASE
            WHEN v.banda = 'A' THEN 'Centro'::text
            WHEN v.banda = 'B' THEN 'Provincia'::text
            WHEN v.banda = 'S'::text THEN 'Sur'::text
            WHEN v.banda = 'N'::text THEN 'Norte'::text
            WHEN v.cod_tramo = 'MET'::text THEN 'Bidireccional'::text
            ELSE v.banda
        END AS nom_banda,
		v.via_cod as cod_via,
	case when 
			v.via_cod = 'PPL' then 'Principal'
			when v.via_cod='RCA' then 'Ramal de enlace'
			else null end as nom_via,


v_zonas_pavimentos.zonatraza,

	v.progresiva as km,
	v.observaciones as ubicacion_banda,
	v.ubicacion as ubicacion_nro_columna,
	 CASE
            WHEN v.hojas IS NOT NULL THEN v.hojas
            ELSE 0::numeric
        END AS hojas,
        CASE
            WHEN v.hojas > 0::numeric THEN v.hojas * 7.62
            ELSE 0::numeric
        END AS largo_m,
        CASE
            WHEN v.postes IS NOT NULL THEN v.postes
            ELSE 0::numeric
        END AS postes,
	        CASE
            WHEN v.prioridad::text = 'peligroso'::text THEN 'Planificada a la brevedad'::text
            WHEN v.prioridad::text = 'no_peligroso'::text THEN 'Planificada'::text
            ELSE NULL::text
        END AS prioridad,
		v.lat as latitud,
		v.lon as longitud,
		v.geom as geom,
	        CASE
            WHEN v.id_ejecucion::text <> 'n/a'::text THEN ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || v.id_ejecucion::text) || '&'' target=''_blank''>Editar registro relacionado en KoboToolBox</a>'::text
            ELSE NULL::text
        END AS linkeditorrelativo

from formularios.inspec_moc v
   LEFT JOIN gisdata.v_zonas_pavimentos ON v.cod_tramo::text = v_zonas_pavimentos.cod_tramo::text

	where select_activo ='Defensa';


ALTER TABLE IF EXISTS formularios.v_inspec_mant_obra_civil_defe
    OWNER TO postgres;

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_defe TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe TO postgres;



-- Vista PowerBI

DROP VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi;

CREATE OR REPLACE VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi
 AS
 SELECT v.gid,
    v.fecha_carga,
    v.tipo_inspeccion,
    v.item,
    v.cod_tramo,
    v.nom_tramo,
    v.nom_banda,
    v.cod_via,
    v.nom_via,
    v.zonatraza,
    v.km,
    v.ubicacion_banda,
    v.ubicacion_nro_columna,
    v.hojas,
    v.largo_m,
    v.postes,
    v.prioridad,
   -- v.observaciones as obs,
    v.latitud,
    v.longitud,
    v.geom,
    v.linkeditorrelativo
   FROM formularios.v_inspec_moc_def_BORRAR v;
ALTER TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO postgres;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO powerbi_reader;





DROP MATERIALIZED VIEW IF EXISTS formularios.v_inspec_moc_pav_BORRAR;
CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_inspec_moc_pav_BORRAR
TABLESPACE pg_default
AS
 SELECT 
	distinct v.fid as gid, 
	v.fecha as fecha_carga,
	v.tipo_inspeccion,
	  CASE WHEN v.tipo_inspeccion::text = 'mensual'::text THEN v.item
            ELSE 0::numeric
        END AS item,
    v_zonas_pavimentos.cod_tramo,
    v_zonas_pavimentos.nom_tramo,
        CASE
            WHEN v.banda = 'A' THEN 'Centro'::text
            WHEN v.banda = 'B' THEN 'Provincia'::text
            WHEN v.banda = 'S'::text THEN 'Sur'::text
            WHEN v.banda = 'N'::text THEN 'Norte'::text
            WHEN v.cod_tramo = 'MET'::text THEN 'Bidireccional'::text
            ELSE v.banda
        END AS nom_banda,
		v.via_cod as cod_via,
	case when via_cod = 'PPL' then 'Principal'
			when v.via_cod='RCA' then 'Ramal de enlace'
			else null end as nom_via,
    v_zonas_pavimentos.id_zona_traza,
    v_zonas_pavimentos.zonatraza,
	v.progresiva as km,
	v.carril,
	v.observaciones as ubicacion_banda,
	v.ubicacion as ubicacion_nro_columna,
	      CASE WHEN v.prioridad::text = 'peligroso'::text THEN 'Planificada a la brevedad'::text
            WHEN v.prioridad::text = 'no_peligroso'::text THEN 'Planificada'::text
            ELSE NULL::text
        END AS prioridad,
		v.lat as latitud,
		v.lon as longitud,
		v.geom as geom,
	        CASE
            WHEN v.id_ejecucion::text <> 'n/a'::text THEN ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || v.id_ejecucion::text) || '&'' target=''_blank''>Editar registro relacionado en KoboToolBox</a>'::text
            ELSE NULL::text
        END AS linkeditorrelativo

from formularios.inspec_moc v
   LEFT JOIN gisdata.v_zonas_pavimentos ON v.cod_tramo::text = v_zonas_pavimentos.cod_tramo::text
	where select_activo ='Pavimento';


ALTER TABLE IF EXISTS formularios.v_inspec_moc_pav_BORRAR
    OWNER TO postgres;

GRANT SELECT ON TABLE formularios.v_inspec_moc_pav_BORRAR TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_moc_pav_BORRAR TO postgres;




/*
DELETE FROM formularios.inspec_moc_def
WHERE fid>146 ; 
SELECT MAX(fid) FROM formularios.inspec_moc_def;
SELECT setval('formularios.inspec_moc_def_fid_seq', (SELECT MAX(fid) FROM formularios.inspec_moc_def));
*/



CREATE OR REPLACE VIEW formularios.v_inspec_mant_obra_civil_pavi_powerbi
 AS
 SELECT 
 v.gid,
    v.fecha_carga,
    v.tipo_inspeccion,
    v.item,
    v.cod_tramo,
    v.nom_tramo,
    v.nom_banda,
    v.cod_via,
    v.nom_via,
    v.id_zona_traza,
    v.zonatraza,
    v.km,
    v.carril,
    v.prioridad,
    v.latitud,
    v.longitud,
    v.geom,
    v.linkeditorrelativo
   FROM formularios.v_inspec_moc_pav_BORRAR v;

ALTER TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_inspec_mant_obra_civil_pavi_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO postgres;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO powerbi_reader;
