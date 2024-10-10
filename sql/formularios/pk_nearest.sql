-- FUNCION Y TRIGGER PARA FORMULARIOS DE KOBO

CREATE OR REPLACE FUNCTION formularios.create_geom_lonlat(kb_lonlat TEXT)
RETURNS geometry AS $$
DECLARE
    geom geometry;
BEGIN
    -- Genera el punto geométrico a partir de la cadena lonlat
    geom := CASE
                WHEN length(kb_lonlat) > 1 THEN 
                    st_setsrid(
                        st_makepoint(
                            split_part(kb_lonlat, ','::text, 2)::numeric::double precision,
                            split_part(kb_lonlat, ','::text, 1)::numeric::double precision
                        ), 4326
                    )::geometry(Point,4326)
                ELSE 
                    NULL::geometry(Point,4326)
            END;

    RETURN geom;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION formularios.nearest_pk_from_geom(geom_input geometry)
RETURNS VARCHAR AS $$
DECLARE
    pk_auto VARCHAR;
BEGIN
    -- Selecciona la progresiva más cercana según la geometría de entrada
    SELECT pro_dump.pk as pk_auto
    INTO pk_auto
    FROM (
        SELECT (ST_Dump(pro.geom)).geom AS geom, pro.pk::varchar 
        FROM gisdata.v_progresivas pro
    ) AS pro_dump
    ORDER BY geom_input <-> pro_dump.geom -- Calcula la distancia geométrica
    LIMIT 1;

    -- Devuelve la progresiva más cercana
    RETURN pk_auto;
END;
$$ LANGUAGE plpgsql;


/* PRUEBA DE LA QUERY
SELECT formularios.nearest_pk_from_geom(
           formularios.create_geom_lonlat(mant_obra_civil.kb_lonlat)
       ) AS pk_mas_cercano
FROM formularios.mant_obra_civil where extract (year from fecha::DATE) > 2023;

*/

CREATE OR REPLACE FUNCTION formularios.actualizar_pk_auto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si pk_auto es NULL o si ha cambiado kb_lonlat
    IF (NEW.kb_lonlat IS DISTINCT FROM OLD.kb_lonlat OR NEW.pk_auto IS NULL) THEN
        NEW.pk_auto := formularios.nearest_pk_from_geom(
                           formularios.create_geom_lonlat(NEW.kb_lonlat)
                       );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para la tabla
CREATE TRIGGER trg_set_nearest_pk_auto
BEFORE INSERT OR UPDATE ON formularios.mant_obra_civil
FOR EACH ROW
EXECUTE FUNCTION formularios.actualizar_pk_auto();


/*
update formularios.mant_obra_civil
set num_integrantes = num_integrantes
where pk_auto is null;
*/
