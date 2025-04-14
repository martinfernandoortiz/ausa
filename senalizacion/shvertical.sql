
SELECT
    v.id_tramo,
    v.id_banda,
    v.id_senal,
    v.id,
    cat.nombre AS categoria,
    ele.nombre AS elemento,
    ele.obs AS obs_elemento,
    sub.nombre AS subelemento,
    sen.codigo,
    sen.nombre AS senal,
    sen.descripcion,
    sm.contenido AS contenido,
    sm.tipo_vehiculo,
    sm.leyenda_extra,
    sm.imagen AS imagen_modificador,
    v.forma,
    v.dimensiones,
    v.soporte,
    v.id_soporte,
    v.estado,
    v.pk,
    v.contenido AS contenido_vertical,
    v.f_instalacion,
    v.f_ult_interv,
    v.geom
	
FROM
    senializacion.senializacionvertical v
JOIN senializacion.senal_modificadores sm 
    ON v.id_modificador = sm.id
JOIN senializacion.senales sen 
    ON sm.senal_id = sen.id
JOIN senializacion.subelementos sub 
    ON sen.subelemento_id = sub.id
JOIN senializacion.elementos ele 
    ON sub.elemento_id = ele.id
JOIN senializacion.categorias cat 
    ON ele.id_categoria = cat.id_categoria
WHERE
    sen.codigo IN ('R15','R16');  -- Corregido el cierre de comillas
