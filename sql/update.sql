Podemos modificar la función para que sea genérica y funcione con cualquier tabla, obteniendo dinámicamente los nombres de los campos de la tabla y actualizándolos sin necesidad de especificarlos manualmente.

Esta versión genérica usará la tabla que especifiques en la llamada y recuperará la lista de columnas mediante una consulta al catálogo de PostgreSQL. Además, se basará en el campo kb_id como clave primaria para verificar la existencia y realizar la actualización o inserción.

Versión Genérica de la Función
Aquí te dejo una versión genérica de la función upsert en PostgreSQL que utiliza el catálogo de PostgreSQL para obtener dinámicamente los campos de la tabla:

sql
Copiar código
CREATE OR REPLACE FUNCTION formularios.generic_upsert(
    p_table_name TEXT,
    p_kb_id TEXT,
    p_values JSONB
) RETURNS VOID AS $$
DECLARE
    v_field_name TEXT;
    v_field_value TEXT;
    v_existing BOOLEAN;
    v_sql TEXT;
    v_column_list TEXT;
    v_value_list TEXT;
BEGIN
    -- Verificar si el kb_id ya existe en la tabla
    v_sql := format('SELECT EXISTS(SELECT 1 FROM %I WHERE kb_id = %L)', p_table_name, p_kb_id);
    EXECUTE v_sql INTO v_existing;

    -- Obtener la lista de columnas de la tabla
    SELECT string_agg(column_name, ', ') 
    INTO v_column_list
    FROM information_schema.columns
    WHERE table_name = p_table_name 
    AND column_name != 'kb_id';

    -- Si kb_id ya existe, hacer un UPDATE con todos los campos
    IF v_existing THEN
        v_sql := format('UPDATE %I SET ', p_table_name);
        FOR v_field_name, v_field_value IN
            SELECT key, value FROM jsonb_each_text(p_values)
        LOOP
            v_sql := v_sql || format('%I = %L, ', v_field_name, v_field_value);
        END LOOP;
        v_sql := rtrim(v_sql, ', ') || format(' WHERE kb_id = %L', p_kb_id);
        EXECUTE v_sql;

    -- Si kb_id no existe, hacer un INSERT
    ELSE
        v_sql := format('INSERT INTO %I (kb_id, %s) VALUES (%L, ', p_table_name, v_column_list, p_kb_id);
        FOR v_field_name, v_field_value IN
            SELECT key, value FROM jsonb_each_text(p_values)
        LOOP
            v_value_list := v_value_list || format('%L, ', v_field_value);
        END LOOP;
        v_sql := v_sql || rtrim(v_value_list, ', ') || ')';
        EXECUTE v_sql;
    END IF;
END;
$$ LANGUAGE plpgsql;
Explicación de la Función
Parámetros de la Función:

p_table_name: nombre de la tabla donde se realizará el upsert.
p_kb_id: valor del kb_id que se usará como clave para verificar si el registro ya existe.
p_values: valores a insertar o actualizar, en formato JSONB.
Verificar Existencia:

Se construye y ejecuta una consulta dinámica para verificar si el kb_id ya existe en la tabla especificada.
Obtener Lista de Columnas:

Recupera dinámicamente los nombres de todas las columnas de la tabla, excluyendo kb_id, para construir las partes de la consulta UPDATE o INSERT.
Construir Consulta de Update:

Si el registro existe, se construye un UPDATE dinámico concatenando cada columna y valor extraído del JSONB.
Construir Consulta de Insert:

Si el registro no existe, construye un INSERT dinámico con los valores del JSONB.
Ejemplo de Uso
Para probar la función, puedes ejecutarla con una tabla específica, formularios.mant_obra_civil, pasando el kb_id y un objeto JSONB con los valores que deseas insertar o actualizar:

sql
Copiar código
SELECT formularios.generic_upsert(
    'mant_obra_civil',
    '12345',
    '{"campo1": "valor1", "campo2": "valor2", "campo3": "valor3"}'::jsonb
);
Esto debería insertar o actualizar dinámicamente en mant_obra_civil, sin necesidad de especificar cada columna manualmente.

###################################################################################################

otra forma 
CREATE OR REPLACE FUNCTION insertar_y_limpiar_por_kb_id(
    p_kb_id VARCHAR,
    p_field_names TEXT[],
    p_field_values TEXT[]
) RETURNS VOID AS $$
DECLARE
    fecha_field TEXT := 'fecha';  -- Suponiendo que la columna de fecha se llama 'fecha'
    max_fecha TIMESTAMP;
BEGIN
    -- 1. Insertar el nuevo registro
    EXECUTE format('INSERT INTO table_name (%s) VALUES (%s)',
                   array_to_string(p_field_names, ', '),
                   array_to_string(quote_literal(array_to_string(p_field_values, ', ')), ', '));

    -- 2. Verificar si hay más de un registro con el mismo kb_id
    SELECT MAX(fecha) INTO max_fecha
    FROM table_name
    WHERE kb_id = p_kb_id;

    -- 3. Si existen duplicados, eliminar todos excepto el registro con la fecha más reciente
    DELETE FROM table_name
    WHERE kb_id = p_kb_id
      AND fecha < max_fecha;  -- Conserva solo el registro con la fecha máxima
END;
$$ LANGUAGE plpgsql;
#####################################################################################################


CREATE OR REPLACE FUNCTION actualizar_o_insertar(
    p_kb_id VARCHAR,
    p_field_names TEXT[],
    p_field_values TEXT[]
) RETURNS VOID AS $$
DECLARE
    existing_row RECORD;
    set_clause TEXT := '';
    field_name TEXT;
    needs_update BOOLEAN := FALSE;
BEGIN
    -- Verificar si kb_id ya existe
    SELECT * INTO existing_row
    FROM table_name
    WHERE kb_id = p_kb_id;

    IF FOUND THEN
        -- Si existe, verificar si los valores actuales son distintos
        FOR i IN 1..array_length(p_field_names, 1) LOOP
            IF existing_row[p_field_names[i]] IS DISTINCT FROM p_field_values[i] THEN
                needs_update := TRUE;
                EXIT;
            END IF;
        END LOOP;

        -- Solo ejecutar el UPDATE si se detectan cambios
        IF needs_update THEN
            FOR i IN 1..array_length(p_field_names, 1) LOOP
                field_name := p_field_names[i];
                set_clause := set_clause || field_name || ' = ' || quote_literal(p_field_values[i]) || ', ';
            END LOOP;

            -- Remover la última coma
            set_clause := left(set_clause, length(set_clause) - 2);

            -- Ejecutar el UPDATE
            EXECUTE format('UPDATE table_name SET %s WHERE kb_id = %L', set_clause, p_kb_id);
        END IF;
    ELSE
        -- Si no existe, ejecutar el INSERT
        EXECUTE format('INSERT INTO table_name (%s) VALUES (%s)',
                       array_to_string(p_field_names, ', '),
                       array_to_string(quote_literal(array_to_string(p_field_values, ', ')), ', '));
    END IF;
END;
$$ LANGUAGE plpgsql;

##############################################################################################################
PHP
