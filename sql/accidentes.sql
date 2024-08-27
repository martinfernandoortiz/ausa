CREATE OR REPLACE VIEW geodatos.v_incidentes AS

WITH joined_data AS (
    SELECT
        i.*,
        n.tramo_cod
    FROM
        geodatos.incidentes i
    LEFT JOIN
        geodatos.nomenclador n
    ON
        i.autopista = n.autopista
)
SELECT
    
	 ROW_NUMBER() OVER () AS gid,  -- Genera un ID único para cada fila
	--vp.gid,
	vp.geom,
	vp.id_tramo,
	vp.cod_tramo,
	vp.nom_tramo,
	vp.pk as pk_pk,
	vp.pk_numerica,
    jd.*
FROM
    gisdata.v_progresivas vp
INNER JOIN
    joined_data jd
ON
    vp.cod_tramo = jd.tramo_cod
  --  AND vp.cod_banda = jd.eje_desc
    AND vp.pk = jd.pk_arreglada
