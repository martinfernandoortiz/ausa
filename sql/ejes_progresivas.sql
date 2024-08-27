
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


