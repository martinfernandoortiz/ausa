

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
		bandas.codigo is null then 'No aplica' else bandas.codigo END as cod_banda,
	CASE WHEN
		bandas.codigo is null then 'No aplica' else bandas.nombre END as nom_banda,


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
