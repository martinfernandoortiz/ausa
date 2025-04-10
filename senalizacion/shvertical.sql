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



CREATE SCHEMA IF NOT EXISTS geodatos;

CREATE TABLE senializacion.senializacionvertical (
    id SERIAL PRIMARY KEY,
    
    -- Relaciones clave
    id_tramo BIGINT REFERENCES gisdata.tramos(id),
    id_banda BIGINT REFERENCES gisdata.bandas(id),
    id_senal INTEGER NOT NULL REFERENCES senializacion.senales(id),
    
    -- Datos físicos del cartel
    forma VARCHAR(20),
    dimensiones VARCHAR(10),
    soporte VARCHAR(30),
    id_soporte INTEGER,
    
    -- Información operativa
    estado VARCHAR(24),
    pk VARCHAR(6),
    contenido VARCHAR(254),
    imagen VARCHAR(254),
    vinculo VARCHAR(254),
    obs VARCHAR(254),
    activo BOOLEAN DEFAULT TRUE,

    -- Fechas de gestión
    f_instalacion DATE,
    f_ult_interv DATE,
    fmodif DATE,
    create_timestamp TIMESTAMPTZ DEFAULT now(),
    edit_timestamp TIMESTAMPTZ,
    delete_timestamp TIMESTAMPTZ,

    -- Auditoría
    create_user VARCHAR,
    edit_user VARCHAR,
    delete_user VARCHAR,
    
    -- Historial
    padre INTEGER, -- ID del registro anterior, si corresponde

    -- Datos espaciales
    area DOUBLE PRECISION,
    geom geometry(Point, 4326)
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


select * from senializacion.subelementos;

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
('R3(6)', 'Prohibido de circular (peatones)', 'Restringe el paso de peatones en el área', 1, 'Circular', 'No peatones'),
('R3(7)', 'Prohibido de circular (carro tracción animal)', 'Prohíbe la circulación de vehículos de tracción animal', 1, 'Circular', ''),
('R3(8)', 'Prohibido de circular (arreos o manadas)', 'Prohíbe la circulación de vehículos de arreos', 1, 'Circular', ''),
('R3(9)', 'Prohibido de circular (carro mano)', 'Prohíbe la circulación de vehículos de carro mano', 1, 'Circular', ''),
('R3(10)', 'Prohibido de circular (tractor)', 'Prohíbe la circulación de vehículos de tractor', 1, 'Circular', ''),
('R4(a)', 'No girar a la izquierda', 'Prohibe el giro a la izquierda', 1, 'Circular', ''),
('R4(b)', 'No girar a la derecha', 'Prohibe el giro a la derecha', 1, 'Circular', ''),
('R5', 'No girar en "U" (no retomar)', 'Prohíbe realizar un giro en U', 1, 'Circular', ''),
('R6', 'Prohibido adelantar', 'Prohíbe adelantamiento de autos', 1, 'Circular', ''),
('R7', 'No ruidos molestos', 'Prohíbe el uso de bocina y emisiones sonoras',1, 'Circular', ''),
('R8', 'No estacionar', 'Prohíbe estacionar vehículos. Letra "E" tachada. Puede incluir horarios o flechas.',1, 'Circular', ''),
('R9', 'No estacionar ni detenerse', 'Prohíbe detener el vehículo en cualquier circunstancia. Letra "E" y "D" tachadas.', 1,'Circular', ''),
('R10', 'Prohibición de cambio de carril', 'Prohíbe cambiar de carril', 1,'Circular', ''),
('R11(a)', 'Limitación de peso','Prohíbe el paso a vehículos cuyo peso exceda el valor indicado.', 2,'Circular','' ),
('R11(b)', 'Limitación de peso por eje', 'Prohíbe el paso a vehículos cuyo peso exceda el valor indicado.', 2,'Circular', ''),
('R12', 'Limitación de altura', 'Prohíbe el paso a vehículos que sobrepasen la altura indicada.', 2,'Circular', 'Altura en m'),
('R13', 'Limitación de ancho', 'Prohíbe el paso a vehículos que sobrepasen el ancho indicado.', 2,'Circular', 'Ancho en m'),
('R14', 'Limitación de largo','Prohíbe el paso a vehículos que excedan el largo indicado.', 2,'Circular', 'Largo en m'),
('R15', 'Límite de velocidad máxima', 'Prohíbe circular a velocidades superiores a la indicada.',2, 'Circular', 'Velocidad (km/h)'),
('R16', 'Límite de velocidad mínima', 'Prohíbe circular a velocidades inferiores a la indicada.',2, 'Circular', 'Velocidad (km/h)')






-- Señales Preventivas - Advertencia (P1–P24)
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('P1', 'Curva a la derecha', 'Advierte una curva pronunciada hacia la derecha. Señal de forma romboidal con una flecha curva hacia la derecha.', 'Romboidal', 2),
('P2', 'Curva a la izquierda', 'Advierte una curva pronunciada hacia la izquierda. Señal de forma romboidal con una flecha curva hacia la izquierda.', 'Romboidal', 2),
('P3', 'Doble curva, primero a la derecha', 'Indica dos curvas consecutivas, iniciando hacia la derecha. Señal de forma romboidal con una doble flecha curva, primero a la derecha.', 'Romboidal', 2),
('P4', 'Doble curva, primero a la izquierda', 'Indica dos curvas consecutivas, iniciando hacia la izquierda. Señal de forma romboidal con una doble flecha curva, primero a la izquierda.', 'Romboidal', 2),
('P5', 'Camino sinuoso', 'Advierte una serie de curvas en el camino. Señal de forma romboidal con una línea serpenteante.', 'Romboidal', 2),
('P6', 'Encrucijada', 'Indica la proximidad de una intersección de caminos. Señal de forma romboidal con una cruz negra.', 'Romboidal', 2),
('P7', 'Empalme lateral por la derecha', 'Señala una incorporación de tráfico desde la derecha. Señal de forma romboidal con una línea principal y una línea secundaria que se une desde la derecha.', 'Romboidal', 2),
('P8', 'Empalme lateral por la izquierda', 'Señala una incorporación de tráfico desde la izquierda. Señal de forma romboidal con una línea principal y una línea secundaria que se une desde la izquierda.', 'Romboidal', 2),
('P9', 'Empalme oblicuo por la derecha', 'Indica una incorporación oblicua desde la derecha. Señal de forma romboidal con una línea principal y una línea oblicua que se une desde la derecha.', 'Romboidal', 2),
('P10', 'Empalme oblicuo por la izquierda', 'Indica una incorporación oblicua desde la izquierda. Señal de forma romboidal con una línea principal y una línea oblicua que se une desde la izquierda.', 'Romboidal', 2),
('P11', 'Bifurcación en "Y"', 'Advierte una bifurcación del camino en forma de "Y". Señal de forma romboidal con una figura en "Y".', 'Romboidal', 2),
('P12', 'Bifurcación en "T"', 'Indica una terminación del camino en una intersección en "T". Señal de forma romboidal con una figura en "T".', 'Romboidal', 2),
('P13', 'Rotonda', 'Señala la proximidad de una rotonda. Señal de forma romboidal con flechas circulares formando un círculo.', 'Romboidal', 2),
('P14', 'Puente angosto', 'Advierte que el puente próximo es angosto. Señal de forma romboidal con dos líneas convergentes.', 'Romboidal', 2),
('P15', 'Calzada angosta', 'Indica que la calzada se estrecha. Señal de forma romboidal con dos líneas convergentes desde los bordes hacia el centro.', 'Romboidal', 2),
('P16', 'Pendiente descendente', 'Advierte una pendiente pronunciada hacia abajo. Señal de forma romboidal con un vehículo descendiendo una pendiente.', 'Romboidal', 2),
('P17', 'Pendiente ascendente', 'Advierte una pendiente pronunciada hacia arriba. Señal de forma romboidal con un vehículo ascendiendo una pendiente.', 'Romboidal', 2),
('P18', 'Máquina agrícola', 'Señala la posible presencia de maquinaria agrícola en la vía. Señal de forma romboidal con la figura de un tractor.', 'Romboidal', 2),
('P19', 'Animales sueltos', 'Advierte la posible presencia de animales en la vía. Señal de forma romboidal con la figura de un animal.', 'Romboidal', 2),
('P20', 'Peatones', 'Indica la proximidad de una zona de cruce peatonal. Señal de forma romboidal con la figura de un peatón.', 'Romboidal', 2),
('P21', 'Escuela', 'Señala la proximidad de una zona escolar. Señal de forma romboidal con la figura de niños cruzando.', 'Romboidal', 2),
('P22', 'Ciclistas', 'Advierte la posible presencia de ciclistas en la vía. Señal de forma romboidal con la figura de un ciclista.', 'Romboidal', 2),
('P23', 'Superficie resbaladiza', 'Indica que la calzada puede estar resbaladiza. Señal de forma romboidal con un vehículo y líneas que representan deslizamiento.', 'Romboidal', 2),
('P24', 'Zona de derrumbes', 'Advierte la posibilidad de derrumbes en la vía. Señal de forma romboidal con piedras cayendo sobre un vehículo.', 'Romboidal', 2);











('R17', 'Distancia mínima entre vehículos', 'Obliga a mantener una distancia mínima entre vehículos.', 'Circular', 3),
('R18', 'Restricción por tipo de carga', 'Prohíbe circular con cargas peligrosas u otras categorías restringidas.', 'Circular', 3),
('R19', 'Restricción por uso exclusivo', 'Señal que restringe la circulación a ciertos vehículos (ej. "solo colectivos", "solo bicicletas").', 'Circular', 3);



-- Señales Reglamentarias - Fin de Prescripción
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('R26', 'Fin de limitación de velocidad', 'Indica que cesa la restricción de velocidad.', 'Circular', 5),
('R27', 'Fin de prohibición de adelantamiento', 'Señala que se permite nuevamente adelantar.', 'Circular', 5),
('R28', 'Fin de prohibición de bocina', 'Señala que finaliza la restricción sonora.', 'Circular', 5),
('R29', 'Fin de todas las restricciones', 'Señal que indica el fin de todas las restricciones anteriores.', 'Circular', 5),
('R30', 'Fin de estacionamiento medido o permitido', 'Informa que cesa la zona de estacionamiento regulado.', 'Circular', 5),
('R31', 'Fin de carril exclusivo', 'Informa que finaliza un tramo de circulación exclusiva.', 'Circular', 5);

-- Señales Informativas
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('I1', 'Hospital', 'Informa la proximidad de un hospital.', 'Cuadrada', 6),
('I2', 'Estación de servicio', 'Informa la presencia de una estación de combustible.', 'Cuadrada', 6),
('I3', 'Policía', 'Indica la ubicación o cercanía de un puesto policial.', 'Cuadrada', 6),
('I4', 'Teléfono', 'Indica la ubicación de un teléfono público.', 'Cuadrada', 6),
('I5', 'Camping', 'Señala un área habilitada para acampar.', 'Cuadrada', 6),
('I6', 'Hotel', 'Informa la presencia de alojamiento disponible.', 'Cuadrada', 6),
('I7', 'Restaurante', 'Señala un lugar habilitado para comer.', 'Cuadrada', 6),
('I8', 'Zona WiFi', 'Indica que hay cobertura de Internet inalámbrica.', 'Cuadrada', 6),
('I9', 'Centro de salud', 'Indica la presencia de un centro asistencial.', 'Cuadrada', 6),
('I10', 'Museo o sitio de interés cultural', 'Señala un lugar de interés turístico o histórico.', 'Cuadrada', 6),
('I11', 'Ruta nacional', 'Indica el número de la ruta nacional por la que se circula.', 'Cuadrada', 6),
('I12', 'Ruta provincial', 'Indica el número de la ruta provincial por la que se circula.', 'Cuadrada', 6),
('I13', 'Zona urbana', 'Indica el ingreso a un área urbana.', 'Cuadrada', 6),
('I14', 'Zona rural', 'Indica la salida del área urbana.', 'Cuadrada', 6),
('I15', 'Fin de autopista', 'Señala que finaliza un tramo de autopista.', 'Cuadrada', 6);


-- Señales Preventivas - Advertencia (P1–P24)
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('P1', 'Curva a la derecha', 'Advierte una curva pronunciada hacia la derecha. Señal de forma romboidal con una flecha curva hacia la derecha.', 'Romboidal', 2),
('P2', 'Curva a la izquierda', 'Advierte una curva pronunciada hacia la izquierda. Señal de forma romboidal con una flecha curva hacia la izquierda.', 'Romboidal', 2),
('P3', 'Doble curva, primero a la derecha', 'Indica dos curvas consecutivas, iniciando hacia la derecha. Señal de forma romboidal con una doble flecha curva, primero a la derecha.', 'Romboidal', 2),
('P4', 'Doble curva, primero a la izquierda', 'Indica dos curvas consecutivas, iniciando hacia la izquierda. Señal de forma romboidal con una doble flecha curva, primero a la izquierda.', 'Romboidal', 2),
('P5', 'Camino sinuoso', 'Advierte una serie de curvas en el camino. Señal de forma romboidal con una línea serpenteante.', 'Romboidal', 2),
('P6', 'Encrucijada', 'Indica la proximidad de una intersección de caminos. Señal de forma romboidal con una cruz negra.', 'Romboidal', 2),
('P7', 'Empalme lateral por la derecha', 'Señala una incorporación de tráfico desde la derecha. Señal de forma romboidal con una línea principal y una línea secundaria que se une desde la derecha.', 'Romboidal', 2),
('P8', 'Empalme lateral por la izquierda', 'Señala una incorporación de tráfico desde la izquierda. Señal de forma romboidal con una línea principal y una línea secundaria que se une desde la izquierda.', 'Romboidal', 2),
('P9', 'Empalme oblicuo por la derecha', 'Indica una incorporación oblicua desde la derecha. Señal de forma romboidal con una línea principal y una línea oblicua que se une desde la derecha.', 'Romboidal', 2),
('P10', 'Empalme oblicuo por la izquierda', 'Indica una incorporación oblicua desde la izquierda. Señal de forma romboidal con una línea principal y una línea oblicua que se une desde la izquierda.', 'Romboidal', 2),
('P11', 'Bifurcación en "Y"', 'Advierte una bifurcación del camino en forma de "Y". Señal de forma romboidal con una figura en "Y".', 'Romboidal', 2),
('P12', 'Bifurcación en "T"', 'Indica una terminación del camino en una intersección en "T". Señal de forma romboidal con una figura en "T".', 'Romboidal', 2),
('P13', 'Rotonda', 'Señala la proximidad de una rotonda. Señal de forma romboidal con flechas circulares formando un círculo.', 'Romboidal', 2),
('P14', 'Puente angosto', 'Advierte que el puente próximo es angosto. Señal de forma romboidal con dos líneas convergentes.', 'Romboidal', 2),
('P15', 'Calzada angosta', 'Indica que la calzada se estrecha. Señal de forma romboidal con dos líneas convergentes desde los bordes hacia el centro.', 'Romboidal', 2),
('P16', 'Pendiente descendente', 'Advierte una pendiente pronunciada hacia abajo. Señal de forma romboidal con un vehículo descendiendo una pendiente.', 'Romboidal', 2),
('P17', 'Pendiente ascendente', 'Advierte una pendiente pronunciada hacia arriba. Señal de forma romboidal con un vehículo ascendiendo una pendiente.', 'Romboidal', 2),
('P18', 'Máquina agrícola', 'Señala la posible presencia de maquinaria agrícola en la vía. Señal de forma romboidal con la figura de un tractor.', 'Romboidal', 2),
('P19', 'Animales sueltos', 'Advierte la posible presencia de animales en la vía. Señal de forma romboidal con la figura de un animal.', 'Romboidal', 2),
('P20', 'Peatones', 'Indica la proximidad de una zona de cruce peatonal. Señal de forma romboidal con la figura de un peatón.', 'Romboidal', 2),
('P21', 'Escuela', 'Señala la proximidad de una zona escolar. Señal de forma romboidal con la figura de niños cruzando.', 'Romboidal', 2),
('P22', 'Ciclistas', 'Advierte la posible presencia de ciclistas en la vía. Señal de forma romboidal con la figura de un ciclista.', 'Romboidal', 2),
('P23', 'Superficie resbaladiza', 'Indica que la calzada puede estar resbaladiza. Señal de forma romboidal con un vehículo y líneas que representan deslizamiento.', 'Romboidal', 2),
('P24', 'Zona de derrumbes', 'Advierte la posibilidad de derrumbes en la vía. Señal de forma romboidal con piedras cayendo sobre un vehículo.', 'Romboidal', 2);




INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('R20', 'Ceda el paso', 'Indica que el conductor debe ceder el paso a otros vehículos antes de ingresar o cruzar una intersección.', 'Triangular', 4),
('R21', 'PARE', 'Obliga al conductor a detenerse completamente antes de continuar. Tiene forma octogonal.', 'Octogonal', 4),
('R22', 'Intersección con prioridad', 'Informa que la vía transversal tiene prioridad de paso.', 'Triangular', 4),
('R23', 'Prioridad de paso en puente angosto', 'Señala que debe cederse el paso en tramos estrechos como puentes.', 'Circular', 4),
('R24', 'Fin de prioridad', 'Indica que cesa una prioridad anteriormente indicada.', 'Circular', 4),
('R25', 'Prioridad respecto a vehículos que circulan en sentido contrario', 'Señala que se tiene prioridad sobre vehículos en sentido contrario.', 'Circular', 4);






--Para insertar los modificadores
WITH r15 AS (
    SELECT id FROM geodatos.senales WHERE codigo = 'R15'
)

-- Insertar modificadores para R15
INSERT INTO geodatos.senal_modificadores (senal_id, tipo, valor)
SELECT id, 'tipo vehículo', 'solo camiones' FROM r15
UNION ALL
SELECT id, 'texto adicional', 'excepto vehículos de emergencia' FROM r15
UNION ALL
SELECT id, 'valor variable', '12 t' FROM r15
UNION ALL
SELECT id, 'horario', 'de 22 a 6 hs' FROM r15;

















CREATE OR REPLACE VIEW geodatos.vw_senializacionvertical_detalle AS
SELECT
    sv.id,
    sv.id_tramo,
    sv.id_banda,
    sv.id_senal,

    -- Datos desde catálogo
    s.codigo AS codigo_senal,
    s.nombre AS nombre_senal,
    s.descripcion,
    s.forma AS forma_catalogo,
    s.contenido AS contenido_catalogo,

    sub.nombre AS subelemento,
    e.nombre AS elemento,
    c.nombre AS categoria,

    -- Datos de instalación / gestión
    sv.forma,
    sv.dimensiones,
    sv.soporte,
    sv.id_soporte,
    sv.estado,
    sv.pk,
    sv.contenido,
    sv.imagen,
    sv.vinculo,
    sv.obs,
    sv.activo,
    sv.f_instalacion,
    sv.f_ult_interv,
    sv.fmodif,
    sv.create_timestamp,
    sv.edit_timestamp,
    sv.delete_timestamp,
    sv.create_user,
    sv.edit_user,
    sv.delete_user,
    sv.padre,
    sv.area,
    sv.geom

FROM
    geodatos.senializacionvertical sv
    JOIN senializacion.senales s ON sv.id_senal = s.id
    JOIN senializacion.subelementos sub ON s.subelemento_id = sub.id
    JOIN senializacion.elementos e ON sub.elemento_id = e.id
    JOIN senializacion.categorias c ON e.categoria_id = c.id;
