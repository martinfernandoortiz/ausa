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

