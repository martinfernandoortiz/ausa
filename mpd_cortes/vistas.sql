

CREATE OR REPLACE VIEW geodatos.v_mpd_cortes AS
SELECT
	id,
    nombre,
    fecha_ini,
    fecha_fin,
    descripcion,
    geom,  -- EPSG:4326
    CASE
        WHEN fecha_ini > fecha_fin THEN 'Fecha inválida'
        WHEN fecha_ini > CURRENT_DATE THEN 'Planificado'
        WHEN fecha_ini <= CURRENT_DATE 
             AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE) THEN 'En curso'
        WHEN fecha_fin < CURRENT_DATE THEN 'Finalizado'
        ELSE 'Desconocido'
    END AS estado_corte,
CASE
    WHEN fecha_fin IS NOT NULL 
         AND fecha_ini <= CURRENT_DATE THEN GREATEST((fecha_fin - CURRENT_DATE), 0)
    WHEN fecha_fin IS NOT NULL 
         AND fecha_ini > CURRENT_DATE THEN GREATEST((fecha_fin - CURRENT_DATE), 0)
    ELSE NULL
END AS dias_restantes
FROM geodatos.mpd_cortes;








CREATE OR REPLACE FUNCTION geodatos.trg_v_mpd_cortes_insert()
RETURNS trigger AS
$$
BEGIN
    INSERT INTO geodatos.mpd_cortes (
        nombre, fecha_ini, fecha_fin, descripcion, geom
    )
    VALUES (
        NEW.nombre, NEW.fecha_ini, NEW.fecha_fin, NEW.descripcion, NEW.geom
    )
    RETURNING id INTO NEW.id;  -- para que la vista devuelva el id creado

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION geodatos.trg_v_mpd_cortes_update()
RETURNS trigger AS
$$
BEGIN
    UPDATE geodatos.mpd_cortes
    SET nombre    = NEW.nombre,
        fecha_ini  = NEW.fecha_ini,
        fecha_fin  = NEW.fecha_fin,
        descripcion= NEW.descripcion,
        geom       = NEW.geom
    WHERE id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER ins_v_mpd_cortes
INSTEAD OF INSERT ON geodatos.v_mpd_cortes
FOR EACH ROW
EXECUTE FUNCTION geodatos.trg_v_mpd_cortes_insert();

CREATE TRIGGER upd_v_mpd_cortes
INSTEAD OF UPDATE ON geodatos.v_mpd_cortes
FOR EACH ROW
EXECUTE FUNCTION geodatos.trg_v_mpd_cortes_update();









CREATE OR REPLACE VIEW geodatos.v_ramales_afectados AS
SELECT
    row_number() OVER () AS pk_id,
    c.nombre,
    c.fecha_ini,
    c.fecha_fin,
    c.descripcion,
    c.estado_corte,
    c.dias_restantes,
    r.linea || '-' || r.recorrido ||'-' ||r.sentido as linea,
--    r.gid,
--    r.id,
--    r.linea,
--    r.recorrido,
--    r.sentido,
--    r.l_r,
--    r.l_r_s,
    r.modalidad,
--    r.cuit,
--    r.razon_soci,
--    r.jurisdicci,
--    r.long_kmp07,
--    r.long_caba,
--    r.porc_caba,
--    r.entidad_su,
--    r.linea_sube,
--    r.ramal_sube,
--    r.elr_sube,
--    r.camara,
--    r.desde,
--    r.hasta,
--    r.ultimo_per,
--    r.nacion_geo,
--    r.mod_caba,
--    r.modif_obs,
--    r.grupo_tari,

    -- Geometría final: solo el tramo afectado
    r.geom AS geom_afectacion

FROM geodatos.v_mpd_cortes c
JOIN externas.recorridos_colectivos r
    ON ST_Intersects(r.geom, c.geom);



CREATE OR REPLACE VIEW geodatos.v_ramales_afectados_en_curso AS
SELECT *
FROM geodatos.v_ramales_afectados
WHERE estado_corte = 'En curso';



CREATE OR REPLACE VIEW geodatos.v_ramales_afectados_planificados AS
SELECT *
FROM geodatos.v_ramales_afectados
WHERE estado_corte = 'Planificado';


CREATE OR REPLACE VIEW geodatos.v_ramales_afectados_finalizados AS
SELECT *
FROM geodatos.v_ramales_afectados
WHERE estado_corte = 'Finalizado';



CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_finalizados_calles AS
SELECT
    c.id,
    c.nombre,
    c.fecha_ini,
    c.fecha_fin,
    c.descripcion,
	r.nom_mapa,
	r.sentido,
    ST_Union(
        ST_Buffer(r.geom::geography,
            5
        )::geometry
    ) AS geom,
	c.estado_corte,
	c.dias_restantes


FROM geodatos.v_mpd_cortes_finalizado c
JOIN externas.calles r ON ST_Intersects(c.geom, r.geom)
GROUP BY
    c.id, c.nombre, c.fecha_ini, c.fecha_fin, c.descripcion,c.estado_corte,
	c.dias_restantes,	r.nom_mapa,	r.sentido;




CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_planificados AS
SELECT *
FROM geodatos.v_mpd_cortes
WHERE estado_corte = 'Planificado';

CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_planificados_calles AS
SELECT
    c.id,
    c.nombre,
    c.fecha_ini,
    c.fecha_fin,
    c.descripcion,
	r.nom_mapa,
	r.sentido,

    ST_Union(
        ST_Buffer(r.geom::geography,
            5
        )::geometry
    ) AS geom,
	c.estado_corte,
	c.dias_restantes

FROM geodatos.v_mpd_cortes_planificados c
JOIN externas.calles r
    ON ST_Intersects(c.geom, r.geom)
GROUP BY
    c.id, c.nombre, c.fecha_ini, c.fecha_fin, c.descripcion,c.estado_corte,
	c.dias_restantes,	r.nom_mapa,	r.sentido;


CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_planificados_paradas AS
SELECT   c.id, c.nombre, c.fecha_ini, c.fecha_fin, c.descripcion,
 ST_Buffer(r.geom::geography, 
        )::geometry


CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_curso AS
SELECT *
FROM geodatos.v_mpd_cortes
WHERE estado_corte = 'En curso';


CREATE OR REPLACE VIEW geodatos.v_mpd_cortes_curso_calles AS
SELECT c.id, c.nombre, c.fecha_ini, c.fecha_fin, c.descripcion,
	r.nom_mapa, r.sentido,
    ST_Union( ST_Buffer(r.geom::geography, 5)::geometry ) AS geom,
	c.estado_corte,
	c.dias_restantes
FROM geodatos.v_mpd_cortes_curso c
JOIN externas.calles r
    ON ST_Intersects(c.geom, r.geom)
GROUP BY
    c.id, c.nombre, c.fecha_ini, c.fecha_fin, c.descripcion,c.estado_corte,
	c.dias_restantes,	r.nom_mapa,	r.sentido;






