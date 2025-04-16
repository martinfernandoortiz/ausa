select * from senializacion.subelementos;
SELECT * FROM senializacion.senales WHERE codigo ='I.6'


select * from senializacion.elementos;


select * from senializacion.senales where subelemento_id  = 10 order by codigo ;


SELECT id FROM senializacion.senales WHERE codigo ='I6'

--Para insertar los modificadores p22
WITH p22 AS (
    SELECT id FROM senializacion.senales WHERE codigo ='P22'
)

-- Insertar modificadores para p22
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehiculo,leyenda_extra,imagen)
SELECT id, '','' , '','p22' FROM p22
UNION ALL
SELECT id, '','' , '','p22(2)' FROM p22





SELECT * FROM senializacion.senales WHERE codigo ilike 'r25%'

--Para insertar los modificadores r25
WITH r25 AS (
    SELECT id FROM senializacion.senales WHERE codigo ='R25'
)

-- Insertar modificadores para 25
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehiculo,leyenda_extra,imagen)
SELECT id, '','' , '','r25' FROM r25
UNION ALL
SELECT id, '','' , 'PEAJE','r25(2)' FROM r25















SELECT * FROM senializacion.senales WHERE codigo ='R11(b)'

--Para insertar los modificadores R11
WITH r11 AS (
    SELECT id FROM senializacion.senales WHERE codigo ='R11(a)'
)

-- Insertar modificadores para R11
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehiculo,leyenda_extra,imagen)
SELECT id, '4 TNS','' , '','r11a(4)' FROM r11
UNION ALL
SELECT id, '12 TNS','' , '','r11a(12)' FROM r11;

-- Popular R11(a)


INSERT INTO senializacion.senializacionvertical (     
    id_tramo,
    id_banda,
    id_senal,
	contenido,
	--id_modificador,  
    -- Datos físicos del cartel
    forma,
    dimensiones,
    soporte,
    id_soporte,
    -- Información operativa
    estado,
    pk,
	imagen,
   -- activo,

    -- Fechas de gestión
    f_instalacion,
    f_ult_interv,
    geom
)

SELECT
    sv.id_tramo,
    sv.id_banda,
    sm.id,
	--sm.id ,
	sv.contenido,
    -- Datos físicos del cartel
    sv.forma,
    sv.dimensiones,
    sv.soporte,
    sv.id_soporte,
    
    -- Información operativa
    sv.estado,
    sv.pk,
	sv.iconografia,
    -- Fechas de gestión
    sv.f_instalacion,
    sv.f_ult_interv,
	
    sv.geom


FROM
    gisdata.v_senializacionvertical sv
JOIN
    senializacion.senales sm
    ON upper (REPLACE(left(sv.nom_elem,2),'I','I.')) = UPPER(sm.codigo)
WHERE
    sv.nom_elem ILIKE 'I6%' ;


select upper (REPLACE(left(nom_elem,2),'I','I.')) as nom_elem 
from  gisdata.v_senializacionvertical 
where nom_elem ilike 'i6%';

select * from senializacion.senales
select * from  gisdata.v_senializacionvertical
