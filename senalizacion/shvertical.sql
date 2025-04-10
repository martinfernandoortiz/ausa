-- Crear el esquema si no existe
CREATE SCHEMA IF NOT EXISTS senializacion;

-- Tabla de Categorías
CREATE TABLE senializacion.categorias (
    id_categoria SERIAL PRIMARY KEY,
    codigo character varying(2) COLLATE pg_catalog."default" NOT NULL,
    nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    obs character varying COLLATE pg_catalog."default"
);


-- Tabla de Elementos (Ej: Reglamentarias, Preventivas, Informativas)
CREATE TABLE senializacion.elementos (
    id SERIAL PRIMARY KEY,
	id_categoria INTEGER NOT NULL REFERENCES senializacion.categorias(id_categoria),
    nombre character varying COLLATE pg_catalog."default" NOT NULL,
    obs character varying COLLATE pg_catalog."default",
	iconografia character varying(100) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
    cod_elemento character varying(3) COLLATE pg_catalog."default",
    CONSTRAINT cod_elemento_unico UNIQUE (cod_elemento)
);




-- Tabla de Subelementos (Ej: Prohibición, Restricción, Fin de prescripción)
CREATE TABLE senializacion.subelementos (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    elemento_id INTEGER NOT NULL REFERENCES senializacion.elementos(id),
    descripcion TEXT
);

-- Tabla de Señales (Ej: R1 - Prohibido Avanzar)
CREATE TABLE senializacion.senales (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    subelemento_id INTEGER REFERENCES senializacion.subelementos(id),
    forma TEXT,
    dimensiones TEXT,
    soporte TEXT,
    contenido TEXT,
    imagen TEXT,
    observaciones TEXT
);

CREATE TABLE senializacion.senal_modificadores (
    id SERIAL PRIMARY KEY,
    senal_id INTEGER REFERENCES senializacion.senales(id),
    tipo TEXT,         -- ejemplo: "texto adicional", "tipo vehículo", "horario", etc.
    valor TEXT         -- ejemplo: "solo camiones", "excepto emergencia", "de 22 a 6 hs"
);

INSERT INTO senializacion.categorias (codigo,nombre, obs)
VALUES ('SV','Señalización Vertical', 'Señales viales verticales del Anexo L');

INSERT INTO senializacion.elementos (nombre, id_categoria, obs)
VALUES 
('Reglamentarias', 1, 'Señales que indican normas de circulación'),
('Preventivas', 1, 'Señales de advertencia de peligro'),
('Informativas', 1, 'Señales de información y servicios');



INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Prohibición', 1, 'Señales que prohíben determinadas acciones'),
('Restricción', 1, 'Señales que limitan movimientos o características'),
('Prioridad', 1, 'Señales que indican prioridades de paso'),
('Fin de prescripción', 1, 'Señales que indican el fin de una orden previa');



INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Curvas y giros', 2, 'Señales que advierten sobre curvas y giros peligrosos'),
('Ancho de calzada', 2, 'Señales que indican cambios en el ancho de la calzada'),
('Pendientes', 2, 'Señales que advierten sobre pendientes pronunciadas'),
('Calzada resbaladiza', 2, 'Señales que indican superficies resbaladizas'),
('Cruces', 2, 'Señales que advierten sobre cruces ferroviarios, peatonales, etc.'),
('Animales', 2, 'Señales que indican la posible presencia de animales en la vía'),
('Otros peligros', 2, 'Otras señales de advertencia de peligros diversos');

-- Informativas
INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Nomenclatura vial y urbana', 3, 'Señales que indican nombres de calles y rutas'),
('Destinos y distancias', 3, 'Señales que informan sobre destinos y distancias'),
('Servicios', 3, 'Señales que indican la ubicación de servicios'),
('Turismo', 3, 'Señales que brindan información turística'),
('Otros', 3, 'Otras señales informativas');




-- Reglamentarias - Prohibición
INSERT INTO senializacion.senales (codigo, nombre, descripcion, subelemento_id, forma, contenido)
VALUES
('R1', 'No avanzar', 'Señal que indica que no se permite avanzar en la dirección señalada', 1, 'Circular', ''),
('R2', 'Contramano', 'Indica que la vía es de sentido contrario al del tránsito', 1, 'Circular', ''),
('R3', 'No circular determinado tipo de tránsito', 'Indica el tipo de vehículo que no puede circular', 1, 'Circular', ''),
('R3(1)', 'Prohibición de circular (autos)', 'Prohíbe la circulación de autos', 1, 'Circular', ''),
('R3(2)', 'Prohibido de circular (motos)', 'Prohíbe la circulación de motocicletas', 1, 'Circular', ''),
('R3(3)', 'Prohibido de circular (bicicletas)', 'Prohíbe la circulación de bicicletas', 1, 'Circular', ''),
('R3(4)', 'Prohibido de circular (camión)', 'Prohíbe la circulación de camiones', 1, 'Circular', ''),
('R3(5)', 'Prohibido de circular (acoplado)', 'Prohíbe la circulación de acoplados', 1, 'Circular', ''),
('R3(6)', 'Prohibido de circular (peatones'), 'Restringe el paso de peatones en el área', 1, 'Circular', 'No peatones'),
('R3(7)', 'Prohibido de circular (carro tracción animal)', 'Prohíbe la circulación de vehículos de tracción animal', 1, 'Circular', ''),
('R3(8)', 'Prohibido de circular (arreos o manadas)', 'Prohíbe la circulación de vehículos de arreos', 1, 'Circular', ''),
('R3(9)', 'Prohibido de circular (carro mano)', 'Prohíbe la circulación de vehículos de carro mano', 1, 'Circular', ''),
('R3(10)', 'Prohibido de circular (tractor)', 'Prohíbe la circulación de vehículos de tractor', 1, 'Circular', ''),
('R4(a)', 'No girar a la izquierda', 'Prohibe el giro a la izquierda', 1, 'Circular', ''),
('R4(b)', 'No girar a la derecha', 'Prohibe el giro a la derecha', 1, 'Circular', ''),
('R5', 'No girar en "U" (no retomar)', 'Prohíbe realizar un giro en U', 1, 'Circular', ''),
('R6', 'Prohibido adelantar', 'Prohíbe adelantamiento de autos', 1, 'Circular', ''),





('R4', 'Prohibido Girar en U', 'Prohíbe realizar un giro en U', 1, 'Circular', 'No girar en U'),
('R5', 'Prohibido Girar a la Derecha', 'Prohíbe el giro a la derecha en la intersección', 1, 'Circular', 'No girar a la derecha'),
('R6', 'Prohibido el Paso de Camiones', 'Restringe el paso de vehículos de carga', 1, 'Circular', 'No camiones'),
('R7', 'Prohibido Estacionar', 'Prohíbe estacionar vehículos en el área señalada', 1, 'Circular', 'No estacionar'),
('R8', 'Prohibido Estacionar y Detenerse', 'Prohíbe tanto estacionar como detenerse', 1, 'Circular', 'No estacionar ni detenerse'),
('R9', 'Prohibido el Paso de Peatones', 'Restringe el paso de peatones en el área', 1, 'Circular', 'No peatones'),
('R10', 'Prohibido el Paso de Bicicletas', 'Prohíbe la circulación de bicicletas', 1, 'Circular', 'No bicicletas'),
('R11', 'Prohibido el Paso de Motocicletas', 'Prohíbe la circulación de motocicletas', 1, 'Circular', 'No motocicletas'),
('R12', 'Prohibido el Paso de Vehículos de Tracción Animal', 'Prohíbe la circulación de vehículos de tracción animal', 1, 'Circular', 'No vehículos de tracción animal'),
('R13', 'Prohibido el Paso de Maquinaria Agrícola', 'Prohíbe la circulación de maquinaria agrícola', 1, 'Circular', 'No maquinaria agrícola'),
('R14', 'Prohibido el Paso de Vehículos que Transporten Mercancías Peligrosas', 'Restringe el paso de vehículos con mercancías peligrosas', 1, 'Circular', 'No mercancías peligrosas'),
('R15', 'Prohibido el Paso de Vehículos con Carga que Supere el Peso Indicado', 'Limita el peso de los vehículos que pueden transitar', 1, 'Circular', 'Peso máximo permitido'),
('R16', 'Prohibido el Paso de Vehículos que Superen el Ancho Indicado', 'Limita el ancho de
