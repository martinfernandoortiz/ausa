-- FUNCTION: usuarios.insert_notification_with_users(text)

CREATE OR REPLACE FUNCTION usuarios.insertar_notificaciones(
	notificacion_text text)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	user_record RECORD;
	nueva_notificacion_id INT;
BEGIN
	-- Insertar la nueva notificación y obtener su ID
	INSERT INTO usuarios.notificaciones (notificacion)
	VALUES (notificacion_text)
	RETURNING id INTO nueva_notificacion_id;

	-- Obtener todos los usuarios activos
	FOR user_record IN SELECT distinct usuario FROM usuarios.usuarios_all WHERE activo = TRUE
	LOOP
		-- Asociar la nueva notificación con cada usuario
		INSERT INTO usuarios.usuarios_notificaciones (usuario, notificacion_id)
		VALUES (user_record.usuario, nueva_notificacion_id);
	END LOOP;
END;
$BODY$;

ALTER FUNCTION usuarios.insertar_notificaciones(text)
OWNER TO postgres;


select usuarios.insertar_notificaciones('Prueba');
