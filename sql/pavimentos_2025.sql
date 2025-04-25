

SELECT "FISURA_LINEAL_(M)"
FROM geodatos.estadopavimentos2025
WHERE "FISURA_LINEAL_(M)" !~ '^[0-9 ,.-]+$';  -- Ejemplo: "N/A", "Sin dato"

-- 2. Opción: Asignar NULL a valores inválidos
UPDATE geodatos.estadopavimentos2025
SET fisura = CASE 
    WHEN "FISURA_LINEAL_(M)" ~ '^[0-9 ,.-]+$' THEN 
        ROUND(REPLACE(TRIM("FISURA_LINEAL_(M)"), ',', '.')::NUMERIC, 1)
    ELSE 
        NULL 
END;


SELECT  "FISURACION_porcentaje"
FROM geodatos.estadopavimentos2025
WHERE "FISURA_LINEAL_(M)" !~ '^[0-9 ,.-]+$';  -- Ejemplo: "N/A", "Sin dato"

-- 2. Opción: Asignar NULL a valores inválidos
UPDATE geodatos.estadopavimentos2025
SET fisura = CASE 
    WHEN  "FISURACION_porcentaje" ~ '^[0-9 ,.-]+$' THEN 
        ROUND(REPLACE(TRIM( "FISURACION_porcentaje"), ',', '.')::NUMERIC, 1)
    ELSE 
        NULL 
END;


INSERT INTO gisdata.estadopavimentos2025 (
    geom, 
    carril, 
    latitude, 
    longitude,  
    desde_km, 
    hasta_km, 
    iri, 
    ahuellam, 
    d1, 
    d2, 
    d3, 
    fisur_m,  -- Columna tipo DOUBLE PRECISION
    bache_m2,  
    pelad_m2,  
    d4, 
    nota1, 
    nota2, 
    ie, 
    isp, 
    obs,
	    "CARRIL_S/RELEV" ,
    "BACHEO_m2" ,
    "ESTADO DE JUNTAS_BIEN" ,
    "ESTADO DE JUNTAS_REGULAR" ,
    "ESTADO DE JUNTAS_MAL" ,
    "TOTAL DETERIOROS_SUP" ,
    "TOTAL DE DETERIOROS_%" 
)
SELECT  
    st_transform(geom,5348),
    "CARRIL_AUSA",
    "LATITUD"::NUMERIC,
    "LONGITUD"::NUMERIC,
   "PK_INICIO",
  "PK_FIN",
 "RUG_(IRI_M/KM)"::NUMERIC AS iri,  -- Conversión explícita
 "AHU_(MM)"::NUMERIC AS ahuellam,
  "PARAMETROS_D1"::NUMERIC AS d1,
   "PARAMETROS_D2"::NUMERIC AS d2,
   "PARAMETROS_D3"::NUMERIC AS d3,
  fisura,
  "BACHES_m2"::NUMERIC AS bache_m2,
 "PEL_DESP_m2"::NUMERIC AS pelad_m2,
  "PARAMETROS_D4"::NUMERIC AS d4,
  "FISURACION_TIPO" AS nota1,
  ROUND(REPLACE(TRIM( "FISURACION_porcentaje"), ',', '.')::NUMERIC, 1),
  -- Asegurar tipo numérico
 "INDICE_DE_ESTADO"::NUMERIC AS ie,
 "INDICE_DE_SERVICIAB_PRESENTE"::NUMERIC AS isp,
  "OBSERVACIONES" AS obs,
  	    "CARRIL_S/RELEV" ,
    "BACHEO_m2" ,
    "ESTADO DE JUNTAS_BIEN" ,
    "ESTADO DE JUNTAS_REGULAR" ,
    "ESTADO DE JUNTAS_MAL" ,
    ROUND(REPLACE( "TOTAL DETERIOROS_SUP"::VARCHAR , ',', '.')::NUMERIC, 1),
    ROUND(REPLACE(TRIM("TOTAL DE DETERIOROS_%" ), ',', '.')::NUMERIC, 1)
FROM geodatos.estadopavimentos2025;
