SELECT ST_StraightSkeleton(geom) as cucu, ST_ApproximateMedialAxis(geom) as lala, * FROM gisdata.bandas_geo 
WHERE id = 1
ORDER BY id ASC LIMIT 100
