-- Consulta formularios de kobo a geom
SELECT 
    gid,
    ST_SetSRID(
        ST_MakePoint(
            split_part(kb_lonlat, ',', 2)::float8,  -- longitud
            split_part(kb_lonlat, ',', 1)::float8   -- latitud
        ), 4326) AS geom
FROM 
    formularios.mant_obra_civil
WHERE 
    tarea = 'defensas' 
    AND fecha > '2024-07-01'
	AND kb_lonlat IS NOT NULL
    AND kb_lonlat <> '';

