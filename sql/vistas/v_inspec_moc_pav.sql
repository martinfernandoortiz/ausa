
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
