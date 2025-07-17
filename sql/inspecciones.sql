-- actualizar campos vacios de inspecciones

-- UPDATE id_tramo
UPDATE formularios.inspec_moc im
SET cod_tramo = bg.cod_tramo
FROM gisdata.v_bandas_geo bg
WHERE im.cod_tramo IS NULL
  AND ST_Intersects(
        st_buffer(ST_Transform(im.geom, 5348),.5),
        bg.geom
      );



-- UPDATE banda
UPDATE formularios.inspec_moc im
SET banda = bg.cod_banda
FROM gisdata.v_bandas_geo bg
WHERE im.banda IS NULL
  AND ST_Intersects(
        st_buffer(ST_Transform(im.geom, 5348),.5),
        bg.geom
      );


-- UPDATE id_tramo
UPDATE formularios.inspec_moc im
SET id_tramo = bg.id_tramo
FROM gisdata.v_bandas_geo bg
WHERE im.id_tramo IS NULL
  AND ST_Intersects(
        st_buffer(ST_Transform(im.geom, 5348),.5),
        bg.geom
      );


-- UPDATE via_cod 
UPDATE formularios.inspec_moc im
SET via_cod = bg.cod_via
FROM gisdata.v_bandas_geo bg
WHERE im.via_cod IS NULL
  AND ST_Intersects(
        st_buffer(ST_Transform(im.geom, 5348),.5),
        bg.geom
      );


-- UPDATE item 
UPDATE formularios.inspec_moc im
SET item = 0
WHERE im.item IS NULL and id_ejecucion is not null
  

-- UPDATE tipo_inspeccion 
UPDATE formularios.inspec_moc im
SET tipo_inspeccion = 'mensual'
WHERE im.item >0

-- UPDATE tipo_inspeccion 
UPDATE formularios.inspec_moc im
SET tipo_inspeccion = 'informal'
WHERE im.item =0


UPDATE formularios.inspec_moc 
SET lat = st_y(geom)
WHERE lat IS NULL;


UPDATE formularios.inspec_moc 
SET lon = st_x(geom)
WHERE lon IS NULL;

