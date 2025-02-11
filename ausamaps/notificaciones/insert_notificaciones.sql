-- FUNCTION: usuarios.insert_notification_with_users(text)

-- DROP FUNCTION IF EXISTS usuarios.insert_notification_with_users(text);

CREATE OR REPLACE FUNCTION usuarios.insertar_notificaciones(
	notificacion_text text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	user text;
	nueva_notificacion_id INT;
BEGIN
	 -- Insertar la nueva notificación con el texto proporcionado
	INSERT INTO usuarios.notificaciones (notificacion) VALUES (notificacion_text::text);

-- Obtener todos los IDs de usuario existentes y activos

FOR user IN SELECT usuario FROM usuarios.usuarios_all WHERE activo = TRUE
LOOP

-- ASOCIAR la nueva notificación con cada usuario
INSERT INTO usuarios.usuarios_notificaciones (usuario, notificacion_id)
VALUES (user, (SELECT MAX (id) from usuarios.notificaciones));

END LOOP;
END;
$BODY$;

ALTER FUNCTION usuarios.insertar_notificaciones(text)
    OWNER TO postgres;


select usuarios.insertar_notificaciones('Prueba');

select * from usuarios.notificaciones;
select * from usuarios.usuarios_notificaciones;
