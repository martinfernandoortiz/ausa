
CREATE OR REPLACE VIEW geodatos.v_ejes_progresivas
 AS
CREATE TABLE geodatos.ejes_progresivas
AS
SELECT
    'original' AS tipo_linea,
    ST_MakeLine(geom ORDER BY pk_numerica) AS linea,
    id_tramo
FROM
    gisdata.v_progresivas
GROUP BY
    id_tramo

UNION ALL

SELECT
    'offset_positivo' AS tipo_linea,
    ST_Transform(
        ST_OffsetCurve(
            ST_MakeLine(ST_Transform(geom, 3857) ORDER BY pk_numerica),
            5  -- Offset positivo en metros
        ),
        4326  -- Transformación de vuelta a WGS84
    ) AS linea,
    id_tramo
FROM
    gisdata.v_progresivas
GROUP BY
    id_tramo

UNION ALL

SELECT
    'offset_negativo' AS tipo_linea,
    ST_Transform(
        ST_OffsetCurve(
            ST_MakeLine(ST_Transform(geom, 3857) ORDER BY pk_numerica),
            -5  -- Offset positivo en metros
        ),
        4326  -- Transformación de vuelta a WGS84
    ) AS linea,
    id_tramo
FROM
    gisdata.v_progresivas
GROUP BY
    id_tramo;


select s.km, pro.pk as pk1 from formularios.v_mant_electrico_powerbi s 
	JOIN LATERAL (
        SELECT pro_dump.pk FROM 
    		(SELECT (ST_Dump(pro.geom)).geom AS geom, pro.pk 
				FROM gisdata.v_progresivas pro) AS pro_dump
ORDER BY 
    s.geom <-> pro_dump.geom -- Calcula la distancia geométrica entre los puntos de A y B
LIMIT 1
    ) pro ON true
--where s.kb_id=316524142


