## Pasar columnas a minuscula y sacarle el espacio
DO $$ 
DECLARE
    column_old_name TEXT;
    column_new_name TEXT;
    table_name TEXT := 'siniestros';
    schema_name TEXT := 'gisdata';
BEGIN
    FOR column_old_name IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = schema_name
          AND table_name = table_name
    LOOP
        -- Convertir a minúsculas y reemplazar espacios por guiones bajos
        column_new_name := lower(replace(column_old_name, ' ', '_'));
        
        -- Verificar si el nombre es diferente para evitar errores
        IF column_old_name <> column_new_name THEN
            EXECUTE format(
                'ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
                schema_name,
                table_name,
                column_old_name,
                column_new_name
            );
        END IF;
    END LOOP;
END $$;
