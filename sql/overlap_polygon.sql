# para corregir el overlap entre polígonos de una misma capa. Le asigna el overlap al que tenga mayor area (o en otras palabras le quita al que tenga menor area)


WITH inter AS (
    SELECT 
        a.id AS id_a, 
        b.id AS id_b, 
        ST_Area(a.geom) AS area_a, 
        ST_Area(b.geom) AS area_b,
        st_buffer(ST_Intersection(a.geom, b.geom),0) AS inter_geom,
        ST_Area(ST_Intersection(a.geom, b.geom)) AS inter_area
    FROM geodatos.bandas_geo a
    JOIN geodatos.bandas_geo b 
    ON ST_Intersects(a.geom, b.geom) AND a.id <> b.id
    WHERE ST_Area(ST_Intersection(a.geom, b.geom)) < 40
)
UPDATE gisdata.bandas_geo a
SET geom = ST_Multi(ST_Difference(a.geom, inter.inter_geom))  -- Garantiza MultiPolygon
FROM (
    SELECT 
        a.id AS id_a, 
        b.id AS id_b, 
        ST_Area(a.geom) AS area_a, 
        ST_Area(b.geom) AS area_b,
        ST_CollectionExtract(ST_Intersection(a.geom, b.geom), 3) AS inter_geom, -- Solo extrae polígonos
        ST_Area(ST_Intersection(a.geom, b.geom)) AS inter_area
    FROM gisdata.bandas_geo a
    JOIN gisdata.bandas_geo b 
    ON ST_Intersects(a.geom, b.geom) AND a.id <> b.id
    WHERE ST_Area(ST_Intersection(a.geom, b.geom)) < 40
) AS inter
WHERE a.id = (CASE 
                 WHEN inter.area_a < inter.area_b THEN inter.id_a  -- Modificar el más pequeño
                 ELSE inter.id_b
             END);
