
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


