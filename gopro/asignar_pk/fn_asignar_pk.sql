-- FUNCTION: gopro2geo.fn_asignar_pk()

-- DROP FUNCTION IF EXISTS gopro2geo.fn_asignar_pk();
CREATE OR REPLACE FUNCTION gopro2geo.fn_asignar_pk()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    nearest_pk text;
    banda_info RECORD;          -- Para almacenar los atributos de la banda intersectada o del punto
    interseccion_count INTEGER; -- Para contar cuántas bandas intersectan el punto
BEGIN
    ----------------------------------------------------------------------
    -- 1. Contar cuántas bandas intersectan el nuevo punto
    ----------------------------------------------------------------------
    SELECT COUNT(b.id_banda)
    INTO interseccion_count
    FROM gopro2geo.v_bandas_geo b
    WHERE ST_Intersects(b.geom, NEW.geom);

    ----------------------------------------------------------------------
    -- 2. Lógica de Asignación y Casos Especiales
    ----------------------------------------------------------------------

    IF interseccion_count = 1 THEN
        -- CASO 1A: Intersección con UNA SOLA banda
        SELECT
            b.cod_tramo,
            b.cod_banda,
            b.cod_via,
            LOWER(REPLACE(b.nombre, ' ', '')) AS normalized_nombre
        INTO banda_info
        FROM gopro2geo.v_bandas_geo b
        WHERE ST_Intersects(b.geom, NEW.geom)
        LIMIT 1;

        -- CASO ESPECIAL: cod_tramo = 'FDT'
        IF banda_info.cod_tramo = 'FDT' THEN
            NEW.pk := NULL;
            RETURN NEW;
        END IF;

    ELSIF interseccion_count >= 2 THEN
        -- CASO 2: Intersección con DOS o MÁS bandas (ambigüedad)
        banda_info.cod_tramo := NEW.cod_tramo;
        banda_info.cod_banda := NEW.cod_banda;
        banda_info.cod_via := NEW.cod_via;
        banda_info.normalized_nombre := LOWER(REPLACE(NEW.nombre, ' ', ''));

    ELSE
        -- CASO 3: CERO intersecciones
        NEW.pk := NULL;
        RETURN NEW;
    END IF;

    ----------------------------------------------------------------------
    -- 3. Búsqueda del pk más cercano en v_progresivas (si aplica)
    ----------------------------------------------------------------------

    IF banda_info.cod_tramo IS NOT NULL  THEN

        -- 🔹 Caso explícito: depende del valor de cod_via
        IF banda_info.cod_via = 'PPL' THEN
            -- Si es 'PPL', NO filtramos por cod_banda
            SELECT p.pk
            INTO nearest_pk
            FROM gopro2geo.v_progresivas p
            WHERE
                p.cod_tramo = banda_info.cod_tramo AND
                p.cod_via = banda_info.cod_via AND
                LOWER(REPLACE(p.nombre, ' ', '')) = banda_info.normalized_nombre
            ORDER BY p.geom <-> NEW.geom
            LIMIT 1;

        ELSE
            -- Si NO es 'PPL', SÍ filtramos por cod_banda
            SELECT p.pk
            INTO nearest_pk
            FROM gopro2geo.v_progresivas p
            WHERE
                p.cod_tramo = banda_info.cod_tramo AND
                p.cod_banda = banda_info.cod_banda AND
                p.cod_via = banda_info.cod_via AND
                LOWER(REPLACE(p.nombre, ' ', '')) = banda_info.normalized_nombre
            ORDER BY p.geom <-> NEW.geom
            LIMIT 1;
        END IF;

        -- Asignar el valor encontrado
        NEW.pk := nearest_pk;

    ELSE
        -- Si no hay atributos válidos para filtrar, no asignar pk
        NEW.pk := NULL;
    END IF;

    RETURN NEW;
END;
$BODY$;




