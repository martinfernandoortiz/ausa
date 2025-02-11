INSERT INTO usuarios.usuarios_map (usuario, mapa_id, mapa_url)
SELECT 
    usuario AS usuario, 
    CASE 
        WHEN uas IN ('MAPS_Admin', 'MAPS_MantTraza') THEN 3077 
        ELSE 3722 
    END AS mapa_id,
    CASE 
        WHEN uas IN ('MAPS_Admin', 'MAPS_MantTraza') THEN 'mapstore/#/context/AUSA/3077' 
        ELSE 'mapstore/#/context/AUSA/3722' 
    END AS mapa_url
FROM usuarios.usuarios_all;
