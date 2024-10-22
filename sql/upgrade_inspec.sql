-- Es el insert into para las inspecciones de defensas. Agrega los datos de kobo a la tabla de inspecciones de mantenimiento de obra civil de defensas estandar


CREATE SEQUENCE IF NOT EXISTS formularios.inspec_moc_def_fid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE formularios.inspec_moc_def_fid_seq
    OWNED BY formularios.inspec_moc_def.fid;

ALTER SEQUENCE formularios.inspec_moc_def_fid_seq
    OWNER TO postgres;

GRANT ALL ON SEQUENCE formularios.inspec_moc_def_fid_seq TO mcastillo;

GRANT ALL ON SEQUENCE formularios.inspec_moc_def_fid_seq TO postgres;

/* esto porque se había desmadrado el secuenciador
--SELECT MAX(fid) FROM formularios.inspec_moc_def;
SELECT setval('formularios.inspec_moc_def_fid_seq', (SELECT MAX(fid) FROM formularios.inspec_moc_def)); */

	
INSERT INTO formularios.inspec_moc_def (item,banda, ubicacion,progresiva,hojas,postes,prioridad,observaciones,fecha,autopista2,kb_lonlat,tipo_inspeccion,select_activo,kb_id,geom)
SELECT         
		item, 
		banda,
		ubicacion_nro_columna,
		km,
	 	hojas,
		postes,
		prioridad,
		ubicacion_banda,
		fecha,
		autopista,
		kb_lonlat,
		tipo_inspeccion,
		selec_activo,
		kb_id,
		        CASE
            WHEN length(p.kb_lonlat::text) > 1 THEN st_setsrid(st_makepoint(split_part(p.kb_lonlat::text, ','::text, 2)::numeric::double precision, split_part(p.kb_lonlat::text, ','::text, 1)::numeric::double precision), 4326)::geometry(Point,4326)
            ELSE NULL::geometry(Point,4326)
        END AS geom
FROM formularios.inspec_mant_obra_civil p
	where p.selec_activo='defensas';
