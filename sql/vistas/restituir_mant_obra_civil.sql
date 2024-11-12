


CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_mant_obra_civil
TABLESPACE pg_default
AS
SELECT DISTINCT mant_obra_civil.fecha::character varying AS fecha_carga,

	 CASE WHEN
        mant_obra_civil.autopista::text in ('Deposito_Zuviria_1','cac_predio_zelada',
'Peaje_Avellaneda_1','Peaje_Dellepiane2','Peaje_Dellepiane1','Peaje_illia','peaje_retiro_2' ) then 20 else v_zonas_pavimentos.id_tramo END as id_tramo,
		 CASE WHEN
        mant_obra_civil.autopista::text in ('Deposito_Zuviria_1','cac_predio_zelada',
'Peaje_Avellaneda_1','Peaje_Dellepiane2','Peaje_Dellepiane1','Peaje_illia','peaje_retiro_2' ) then 'FDT' else v_zonas_pavimentos.cod_tramo END as cod_tramo,

    CASE WHEN
        mant_obra_civil.autopista::text in ('Deposito_Zuviria_1','cac_predio_zelada',
	'Peaje_Avellaneda_1','Peaje_Dellepiane2','Peaje_Dellepiane1','Peaje_illia','peaje_retiro_2' ) then 'Fuera de Traza' else v_zonas_pavimentos.nom_tramo END as nom_tramo,

	CASE WHEN
		bandas.codigo is null then 0 else bandas.id END as id_banda,
	CASE WHEN
		bandas.codigo is null then '0' else bandas.codigo END as cod_banda,
	CASE WHEN
		bandas.codigo is null then 'Fuera de traza' else bandas.nombre END as nom_banda,


	CASE WHEN v_zonas_pavimentos.id_via is null then 4 else id_via end as id_via,
	CASE WHEN v_zonas_pavimentos.cod_via is null then 'FDT' else cod_via end as cod_via,
	CASE WHEN v_zonas_pavimentos.cod_via is null then 'Fuera de traza' else nom_via end as nom_via,

	CASE WHEN 
		v_zonas_pavimentos.id_zona_traza is null then 0 else id_zona_traza end as id_zona_traza,
	CASE WHEN 
		v_zonas_pavimentos.zonatraza is null then 'Fuera' else zonatraza end as zonatraza,
    mant_obra_civil.gid,
    mant_obra_civil.kb_id,
    mant_obra_civil.estado_del_tiempo,
    mant_obra_civil.fecha,
    mant_obra_civil.desc_tarea,
    mant_obra_civil.cuadrilla,
    mant_obra_civil.num_integrantes,
    mant_obra_civil.km,
    mant_obra_civil.pk_auto,
    mant_obra_civil.kb_notes,
    mant_obra_civil.imagenes,
    mant_obra_civil.kb_lonlat,
    mant_obra_civil.kb_uuid,
    mant_obra_civil.kb_tags,
    mant_obra_civil.kb_submitted_by,
    mant_obra_civil.kb_xform_id_string,
    mant_obra_civil.kb_status,
    mant_obra_civil.kb_meta_instanceid,
    mant_obra_civil.kb_formhub_uuid,
    mant_obra_civil.banda,
    mant_obra_civil.autopista,
    mant_obra_civil.kb_submission_time,
    mant_obra_civil.kb_attachments,
    mant_obra_civil.kb_start,
    mant_obra_civil.responsable,
    mant_obra_civil.turno,
    mant_obra_civil.kb_validation_status,
    mant_obra_civil.tarea,
    mant_obra_civil.kb_version,
    mant_obra_civil.kb_today,
    mant_obra_civil.img1,
    mant_obra_civil.img2,
    mant_obra_civil.img3,
    mant_obra_civil.img4,
    mant_obra_civil.img5,
    mant_obra_civil.img6,
    mant_obra_civil.img7,
    mant_obra_civil.img8,
    mant_obra_civil.img9,
    mant_obra_civil.img10,
    mant_obra_civil.material,
    mant_obra_civil.banda_a,
    mant_obra_civil.banda_b,
    mant_obra_civil.banda_c,
    mant_obra_civil.banda_d,
    mant_obra_civil.junta1,
    mant_obra_civil.junta2,
    mant_obra_civil.junta3,
    mant_obra_civil.junta4,
    mant_obra_civil.junta,
    mant_obra_civil.nro_junta,
    mant_obra_civil.kb_end,
    mant_obra_civil.usuario_ausa,
    mant_obra_civil.obs,
    NULLIF((string_to_array(mant_obra_civil.kb_lonlat::text, ','::text))[1], ''::text)::numeric AS latitud,
    NULLIF((string_to_array(mant_obra_civil.kb_lonlat::text, ','::text))[2], ''::text)::numeric AS longitud,
        CASE
            WHEN length(mant_obra_civil.kb_lonlat::text) > 1 THEN st_setsrid(st_makepoint(split_part(mant_obra_civil.kb_lonlat::text, ','::text, 2)::numeric::double precision, split_part(mant_obra_civil.kb_lonlat::text, ','::text, 1)::numeric::double precision), 4326)::geometry(Point,4326)
            ELSE NULL::geometry(Point,4326)
        END AS geom,
    (((((((((((((('<a href=''../services/forms/pdfs/mant_obra_civil/'::text || mant_obra_civil.tarea::text) || '/'::text) || mant_obra_civil.fecha) || '_'::text) || concat(v_zonas_pavimentos.zonatraza)) || '_'::text) || mant_obra_civil.autopista::text) || '_'::text) || concat(COALESCE(mant_obra_civil.banda, mant_obra_civil.banda_a, mant_obra_civil.banda_b, mant_obra_civil.banda_c, mant_obra_civil.banda_d))) || '_'::text) || mant_obra_civil.km) || '_mant_obra_civil_'::text) || mant_obra_civil.kb_uuid::text) || '.pdf'''::text) || 'target=''_blank''>Formulario en pdf</a>'::text AS vinculo,
    ((((((((((((('https://maps.ausa.com.ar/services/forms/pdfs/mant_obra_civil/'::text || mant_obra_civil.tarea::text) || '/'::text) || mant_obra_civil.fecha) || '_'::text) || concat(v_zonas_pavimentos.zonatraza)) || '_'::text) || mant_obra_civil.autopista::text) || '_'::text) || concat(COALESCE(mant_obra_civil.banda, mant_obra_civil.banda_a, mant_obra_civil.banda_b, mant_obra_civil.banda_c, mant_obra_civil.banda_d))) || '_'::text) || concat(mant_obra_civil.km)) || '_mant_obra_civil_'::text) || mant_obra_civil.kb_uuid::text) || '.pdf'::text AS urlvinculo,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[1] AS img_orig1,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[10] AS img_orig2,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[19] AS img_orig3,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[28] AS img_orig4,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[37] AS img_orig5,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[46] AS img_orig6,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[55] AS img_orig7,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[64] AS img_orig8,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[73] AS img_orig9,
    (string_to_array(mant_obra_civil.kb_attachments::text, ','::text))[82] AS img_orig10,
    ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || mant_obra_civil.kb_id) || '&'' target=''_blank''>Editar registro en KoboToolBox</a>'::text AS linkeditor
   FROM formularios.mant_obra_civil
     LEFT JOIN gisdata.v_zonas_pavimentos ON mant_obra_civil.autopista::text = v_zonas_pavimentos.cod_tramo::text
     LEFT JOIN gisdata.bandas ON COALESCE(mant_obra_civil.banda, mant_obra_civil.banda_a, mant_obra_civil.banda_b, mant_obra_civil.banda_c, mant_obra_civil.banda_d)::text = bandas.codigo::text
  WHERE mant_obra_civil.kb_validation_status::text ~~ '%validation_status_approved%'::text
WITH DATA;








CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_inspec_moc_def
TABLESPACE pg_default
AS
 SELECT DISTINCT v.fid AS gid,
    v.fecha AS fecha_carga,
    v.tipo_inspeccion,
        CASE
            WHEN v.tipo_inspeccion::text = 'mensual'::text THEN v.item
            ELSE 0::numeric
        END AS item,
    v_zonas_pavimentos.cod_tramo,
    v_zonas_pavimentos.nom_tramo,
        CASE
            WHEN v.banda::text = 'A'::text THEN 'Centro'::text::character varying
            WHEN v.banda::text = 'B'::text THEN 'Provincia'::text::character varying
            WHEN v.banda::text = 'S'::text THEN 'Sur'::text::character varying
            WHEN v.banda::text = 'N'::text THEN 'Norte'::text::character varying
            WHEN v.cod_tramo::text = 'MET'::text THEN 'Bidireccional'::text::character varying
            ELSE v.banda
        END AS nom_banda,
    v.via_cod AS cod_via,
        CASE
            WHEN v.via_cod::text = 'PPL'::text THEN 'Principal'::text
            WHEN v.via_cod::text = 'RCA'::text THEN 'Ramal de enlace'::text
            ELSE NULL::text
        END AS nom_via,
    v_zonas_pavimentos.zonatraza,
    v.progresiva AS km,
    v.observaciones AS ubicacion_banda,
    v.ubicacion AS ubicacion_nro_columna,
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
            WHEN v.prioridad::text = '1'::text THEN 'Planificada a la brevedad'::text
            WHEN v.prioridad::text = '2'::text THEN 'Planificada'::text
            ELSE v.prioridad::text
        END AS prioridad,
    v.lat AS latitud,
    v.lon AS longitud,
    v.geom,
        CASE
            WHEN v.id_ejecucion <> 'n/a'::text THEN ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || v.id_ejecucion) || '&'' target=''_blank''>Editar registro relacionado en KoboToolBox</a>'::text
            ELSE NULL::text
        END AS linkeditorrelativo,
    v.id_ejecucion,
    m.fecha_carga AS fecha_resolucion,
    m.fecha_carga::date - v.fecha::date AS dias_resolucion
   FROM formularios.inspec_moc v
     LEFT JOIN gisdata.v_zonas_pavimentos ON v.cod_tramo::text = v_zonas_pavimentos.cod_tramo::text
     LEFT JOIN formularios.v_mant_obra_civil m ON v.id_ejecucion = m.kb_id::text
  WHERE v.select_activo::text = 'Defensa'::text AND v.activo = true
WITH DATA;

ALTER TABLE IF EXISTS formularios.v_inspec_moc_def
    OWNER TO postgres;

GRANT SELECT ON TABLE formularios.v_inspec_moc_def TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_moc_def TO postgres;








CREATE MATERIALIZED VIEW IF NOT EXISTS formularios.v_inspec_moc_pav
TABLESPACE pg_default
AS
 SELECT DISTINCT v.fid AS gid,
    v.fecha AS fecha_carga,
    v.tipo_inspeccion,
        CASE
            WHEN v.tipo_inspeccion::text = 'mensual'::text THEN v.item
            ELSE 0::numeric
        END AS item,
    v_zonas_pavimentos.cod_tramo,
    v_zonas_pavimentos.nom_tramo,
        CASE
            WHEN v.banda::text = 'A'::text THEN 'Centro'::text::character varying
            WHEN v.banda::text = 'B'::text THEN 'Provincia'::text::character varying
            WHEN v.banda::text = 'S'::text THEN 'Sur'::text::character varying
            WHEN v.banda::text = 'N'::text THEN 'Norte'::text::character varying
            WHEN v.cod_tramo::text = 'MET'::text THEN 'Bidireccional'::text::character varying
            ELSE v.banda
        END AS nom_banda,
    v.via_cod AS cod_via,
        CASE
            WHEN v.via_cod::text = 'PPL'::text THEN 'Principal'::text
            WHEN v.via_cod::text = 'RCA'::text THEN 'Ramal de enlace'::text
            ELSE NULL::text
        END AS nom_via,
    v_zonas_pavimentos.id_zona_traza,
    v_zonas_pavimentos.zonatraza,
    v.progresiva AS km,
    v.carril,
    v.observaciones AS ubicacion_banda,
    v.ubicacion AS ubicacion_nro_columna,
        CASE
            WHEN v.prioridad::text = '1'::text THEN 'Planificada a la brevedad'::text
            WHEN v.prioridad::text = '2'::text THEN 'Planificada'::text
            ELSE v.prioridad::text
        END AS prioridad,
    v.lat AS latitud,
    v.lon AS longitud,
    v.geom,
        CASE
            WHEN v.id_ejecucion <> 'n/a'::text THEN ('<a href=''https://maps.ausa.com.ar/services/forms/edit/?uid=a9hd6fBnx7yy56Q3hCErip&id='::text || v.id_ejecucion) || '&'' target=''_blank''>Editar registro relacionado en KoboToolBox</a>'::text
            ELSE NULL::text
        END AS linkeditorrelativo,
    v.id_ejecucion,
    m.fecha_carga AS fecha_resolucion,
    m.fecha_carga::date - v.fecha::date AS dias_resolucion
   FROM formularios.inspec_moc v
     LEFT JOIN gisdata.v_zonas_pavimentos ON v.cod_tramo::text = v_zonas_pavimentos.cod_tramo::text
     LEFT JOIN formularios.v_mant_obra_civil m ON v.id_ejecucion = m.kb_id::text
  WHERE v.select_activo::text = 'Pavimento'::text AND v.activo = true
WITH DATA;

ALTER TABLE IF EXISTS formularios.v_inspec_moc_pav
    OWNER TO postgres;

GRANT SELECT ON TABLE formularios.v_inspec_moc_pav TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_moc_pav TO postgres;





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
    v.latitud,
    v.longitud,
    v.geom,
    v.linkeditorrelativo,
    v.fecha_resolucion,
    v.id_ejecucion,
    v.fecha_resolucion::date - v.fecha_carga::date AS dias_resolucion,
        CASE
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NULL AND (CURRENT_DATE - v.fecha_carga::date) > 30 THEN 'Prioritaria Fuera de Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NULL AND (CURRENT_DATE - v.fecha_carga::date) <= 30 THEN 'Prioritaria En Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NOT NULL AND (v.fecha_resolucion::date - v.fecha_carga::date) <= 30 THEN 'Prioritaria Resuelta En Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NOT NULL AND (v.fecha_resolucion::date - v.fecha_carga::date) > 30 THEN 'Prioritaria Resuelta Fuera de Plazo'::text
            WHEN v.prioridad = 'Planificada'::text AND v.id_ejecucion IS NOT NULL THEN 'No Prioritaria Resuelta'::text
            WHEN v.prioridad = 'Planificada'::text AND v.id_ejecucion IS NULL THEN 'No Prioritaria abierta'::text
            ELSE NULL::text
        END AS tipo_resolucion,
        CASE
            WHEN v.id_ejecucion IS NULL THEN CURRENT_DATE - v.fecha_carga::date
            WHEN v.id_ejecucion IS NOT NULL THEN v.fecha_resolucion::date - v.fecha_carga::date
            ELSE NULL::integer
        END AS dias_abierto
   FROM formularios.v_inspec_moc_def v;

ALTER TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_inspec_mant_obra_civil_defe_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO postgres;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_defe_powerbi TO powerbi_reader;






CREATE OR REPLACE VIEW formularios.v_inspec_mant_obra_civil_pavi_powerbi
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
    v.id_zona_traza,
    v.zonatraza,
    v.km,
    v.carril,
    v.prioridad,
    v.latitud,
    v.longitud,
    v.geom,
    v.linkeditorrelativo,
    v.fecha_resolucion,
    v.fecha_resolucion::date - v.fecha_carga::date AS dias_resolucion,
    v.id_ejecucion,
        CASE
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NULL AND (CURRENT_DATE - v.fecha_carga::date) > 30 THEN 'Prioritaria Fuera de Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NULL AND (CURRENT_DATE - v.fecha_carga::date) <= 30 THEN 'Prioritaria En Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NOT NULL AND (v.fecha_resolucion::date - v.fecha_carga::date) <= 30 THEN 'Prioritaria Resuelta En Plazo'::text
            WHEN v.prioridad = 'Planificada a la brevedad'::text AND v.id_ejecucion IS NOT NULL AND (v.fecha_resolucion::date - v.fecha_carga::date) > 30 THEN 'Prioritaria Resuelta Fuera de Plazo'::text
            WHEN v.prioridad = 'Planificada'::text AND v.id_ejecucion IS NOT NULL THEN 'No Prioritaria Resuelta'::text
            WHEN v.prioridad = 'Planificada'::text AND v.id_ejecucion IS NULL THEN 'No Prioritaria abierta'::text
            ELSE NULL::text
        END AS tipo_resolucion,
        CASE
            WHEN v.id_ejecucion IS NULL THEN CURRENT_DATE - v.fecha_carga::date
            WHEN v.id_ejecucion IS NOT NULL THEN v.fecha_resolucion::date - v.fecha_carga::date
            ELSE NULL::integer
        END AS dias_abierto
   FROM formularios.v_inspec_moc_pav v;

ALTER TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_inspec_mant_obra_civil_pavi_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO postgres;
GRANT ALL ON TABLE formularios.v_inspec_mant_obra_civil_pavi_powerbi TO powerbi_reader;



-- View: formularios.v_mant_obra_civil_powerbi

-- DROP VIEW formularios.v_mant_obra_civil_powerbi;

CREATE OR REPLACE VIEW formularios.v_mant_obra_civil_powerbi
 AS
 WITH inspecciones AS (
         SELECT a.gid,
            a.fecha_carga,
            a.item,
            a.id_ejecucion
           FROM formularios.v_inspec_moc_def a
        UNION ALL
         SELECT b.gid,
            b.fecha_carga,
            b.item,
            b.id_ejecucion
           FROM formularios.v_inspec_moc_pav b
        )
 SELECT v_mant_obra_civil.fecha_carga,
    v_mant_obra_civil.gid,
    v_mant_obra_civil.kb_id,
    v_mant_obra_civil.estado_del_tiempo,
    v_mant_obra_civil.fecha,
    v_mant_obra_civil.desc_tarea,
    v_mant_obra_civil.cuadrilla,
    v_mant_obra_civil.num_integrantes,
    v_mant_obra_civil.km,
    v_mant_obra_civil.kb_notes,
    v_mant_obra_civil.imagenes,
    v_mant_obra_civil.kb_lonlat,
    v_mant_obra_civil.kb_uuid,
    v_mant_obra_civil.kb_tags,
    v_mant_obra_civil.kb_submitted_by,
    v_mant_obra_civil.kb_xform_id_string,
    v_mant_obra_civil.kb_status,
    v_mant_obra_civil.kb_meta_instanceid,
    v_mant_obra_civil.kb_formhub_uuid,
    v_mant_obra_civil.banda,
    v_mant_obra_civil.autopista,
    v_mant_obra_civil.kb_submission_time,
    v_mant_obra_civil.kb_attachments,
    v_mant_obra_civil.kb_start,
    v_mant_obra_civil.responsable,
    v_mant_obra_civil.turno,
    v_mant_obra_civil.kb_validation_status,
    v_mant_obra_civil.tarea,
    v_mant_obra_civil.kb_version,
    v_mant_obra_civil.kb_today,
    v_mant_obra_civil.img1,
    v_mant_obra_civil.img2,
    v_mant_obra_civil.img3,
    v_mant_obra_civil.img4,
    v_mant_obra_civil.img5,
    v_mant_obra_civil.img6,
    v_mant_obra_civil.img7,
    v_mant_obra_civil.img8,
    v_mant_obra_civil.img9,
    v_mant_obra_civil.img10,
    v_mant_obra_civil.material,
    v_mant_obra_civil.banda_a,
    v_mant_obra_civil.banda_b,
    v_mant_obra_civil.banda_c,
    v_mant_obra_civil.banda_d,
    v_mant_obra_civil.junta1,
    v_mant_obra_civil.junta2,
    v_mant_obra_civil.junta3,
    v_mant_obra_civil.junta4,
    v_mant_obra_civil.junta,
    v_mant_obra_civil.nro_junta,
    v_mant_obra_civil.kb_end,
    v_mant_obra_civil.usuario_ausa,
    v_mant_obra_civil.obs,
    v_mant_obra_civil.latitud,
    v_mant_obra_civil.longitud,
    v_mant_obra_civil.geom,
    v_mant_obra_civil.id_tramo,
    v_mant_obra_civil.cod_tramo,
    v_mant_obra_civil.nom_tramo,
    v_mant_obra_civil.id_banda,
    v_mant_obra_civil.cod_banda,
    v_mant_obra_civil.nom_banda,
    v_mant_obra_civil.id_via,
    v_mant_obra_civil.cod_via,
    v_mant_obra_civil.nom_via,
    v_mant_obra_civil.id_zona_traza,
    v_mant_obra_civil.zonatraza,
    v_mant_obra_civil.vinculo,
    v_mant_obra_civil.urlvinculo,
    v_mant_obra_civil.img_orig1,
    v_mant_obra_civil.img_orig2,
    v_mant_obra_civil.img_orig3,
    v_mant_obra_civil.img_orig4,
    v_mant_obra_civil.img_orig5,
    v_mant_obra_civil.img_orig6,
    v_mant_obra_civil.img_orig7,
    v_mant_obra_civil.img_orig8,
    v_mant_obra_civil.img_orig9,
    v_mant_obra_civil.img_orig10,
    v_mant_obra_civil.linkeditor,
    v_mant_obra_civil.pk_auto AS pk_calculado,
        CASE
            WHEN d.id_ejecucion IS NOT NULL THEN 'Con Inspección Asociada'::text
            ELSE 'Sin Inspección Asociada'::text
        END AS inspecciones
   FROM formularios.v_mant_obra_civil
     LEFT JOIN inspecciones d ON v_mant_obra_civil.kb_id::text = d.id_ejecucion;

ALTER TABLE formularios.v_mant_obra_civil_powerbi
    OWNER TO postgres;
COMMENT ON VIEW formularios.v_mant_obra_civil_powerbi
    IS 'Vista compatible con PowerBI';

GRANT SELECT ON TABLE formularios.v_mant_obra_civil_powerbi TO ausa_reader;
GRANT ALL ON TABLE formularios.v_mant_obra_civil_powerbi TO postgres;


