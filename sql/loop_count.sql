
DO $$ 
DECLARE
    rec RECORD;
    total_count INTEGER := 0;
BEGIN
    FOR rec IN 
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'formularios'
    LOOP
        EXECUTE 'SELECT COUNT(*) FROM formularios.' || rec.table_name INTO total_count;
        RAISE NOTICE 'Vista: %, Registros: %', rec.table_name, total_count;
    END LOOP;
END $$;
