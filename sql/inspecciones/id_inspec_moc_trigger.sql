CREATE OR REPLACE FUNCTION formularios.generar_id_inspec_moc()
RETURNS TRIGGER AS $$
DECLARE
    prefijo TEXT;
    contador INTEGER;
    mes_formateado TEXT;  -- Variable para mes con 2 dígitos
BEGIN
    -- Formatear mes a 2 dígitos
    mes_formateado := LPAD(NEW.mes::text, 2, '0');
    
    prefijo := CASE 
        WHEN NEW.select_activo = 'Defensa' THEN 'd_'
        WHEN NEW.select_activo = 'Pavimento' THEN 'p_'
        ELSE 'otro_'
    END;
    
    IF NEW.item = 0 THEN
        -- Ordenar por año y mes en el conteo
        SELECT COUNT(*) + 1 INTO contador
        FROM formularios.inspec_moc
        WHERE 
            cod_tramo = NEW.cod_tramo AND
            banda = NEW.banda AND
            anio = NEW.anio AND
            mes = NEW.mes AND
            item = 0
        ORDER BY anio, mes;  -- Orden cronológico
        
        NEW.id := prefijo || 
                  NEW.cod_tramo || '_' || 
                  NEW.banda || '_' || 
                  NEW.anio || '_' || 
                  mes_formateado || '_0_' || contador::TEXT;
    ELSE
        NEW.id := prefijo || 
                  NEW.cod_tramo || '_' || 
                  NEW.banda || '_' || 
                  NEW.anio || '_' || 
                  mes_formateado || '_' || 
                  NEW.item::TEXT;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


select * from gisdata.sondeos;
select * from gisdata.elementos where id = 239;

