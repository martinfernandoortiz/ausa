CREATE OR REPLACE FUNCTION gisdata.nearest_pk(geom_input geometry)
RETURNS VARCHAR AS $$
DECLARE
    progresiva_mas_cercana VARCHAR;
BEGIN
    -- Selecciona la progresiva más cercana según la geometría de entrada
    SELECT pro_dump.pk 
    INTO progresiva_mas_cercana
    FROM (
        SELECT (ST_Dump(pro.geom)).geom AS geom, pro.pk::varchar 
        FROM gisdata.v_progresivas pro
    ) AS pro_dump
    ORDER BY geom_input <-> pro_dump.geom -- Calcula la distancia geométrica
    LIMIT 1;

    -- Devuelve la progresiva más cercana
    RETURN progresiva_mas_cercana;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION gisdata.actualizar_pk_auto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si hay una nueva geometría (en un INSERT) o un cambio en la geometría (en un UPDATE)
    IF (TG_OP = 'INSERT' OR NEW.geom IS DISTINCT FROM OLD.geom OR NEW.pk_auto IS NULL) THEN
        -- Actualizar el campo pk_auto con la progresiva más cercana
        NEW.pk_auto := gisdata.nearest_pk(NEW.geom);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_actualizar_pk_auto
BEFORE INSERT OR UPDATE ON gisdata.amortiguadores
FOR EACH ROW
EXECUTE FUNCTION gisdata.actualizar_pk_auto();
