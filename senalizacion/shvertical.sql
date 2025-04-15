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
    forma TEXT, -- cuadrado, rectangular, circular
    dimensiones TEXT, -- esta no iria, sino en la de gis
    soporte TEXT, -- esta no iria, sino que va en la de gis
    contenido TEXT, -- cuando hay muchos casos va a la tabla de senal modificadores
    imagen TEXT, -- tiene que ser generica
    observaciones TEXT
);

CREATE TABLE senializacion.senal_modificadores (
    id SERIAL PRIMARY KEY,
    senal_id INTEGER REFERENCES senializacion.senales(id),
	contenido TEXT,
	tipo_vehiculo TEXT,         -- ejemplo: "texto adicional", "tipo vehículo", "horario", etc.
	leyenda_extra TEXT, -- ejemplo: valor de velocidad 60, 40 ,etc
    valor TEXT,         -- ejemplo: "solo camiones", "excepto emergencia", "de 22 a 6 hs"
	imagen TEXT
);




CREATE TABLE senializacion.senializacionvertical (
    id SERIAL PRIMARY KEY,
    
    -- Relaciones clave
    id_tramo BIGINT REFERENCES gisdata.tramos(id),
    id_banda BIGINT REFERENCES gisdata.bandas(id),
    id_senal INTEGER NOT NULL REFERENCES senializacion.senales(id),
	id_modificador INTEGER NOT NULL REFERENCES senializacion.senal_modificadores(id),

    
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


-- Reglamentarias
INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Prohibición', 1, 'Señales que prohíben determinadas acciones'),
('Restricción', 1, 'Señales que limitan movimientos o características'),
('Prioridad', 1, 'Señales que indican prioridades de paso'),
('Fin de prescripción', 1, 'Señales que indican el fin de una orden previa');



INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Advetencias de máximo peligro', 2, 'Señales que advierten sobre cruces de ferrocarril y giros peligrosos'),
('Advertencia sobre características de la vía', 2, 'Señales que indican curvas, pendientes, estrechamientos, etc'),
('Posibilidad de riesgo eventual', 2, 'Animales sueltos, vehículos extraños. No suele haber en AUSA'),
('Anticipo de otros dispositivos de control de tránsito', 2, 'Señales que advierten indicaciones a realizar a futuro'),
('Fin de la prevención', 2, 'Señales que indican fin de la prevención.');


-- Informativas
INSERT INTO senializacion.subelementos (nombre, elemento_id, descripcion)
VALUES
('Nomenclatura vial y urbana', 3, 'Señales que indican nombres de sitios, distancias, etc'),
('Características de la vía', 3, 'Esquemas de la vía, desvios, etc'),
('Información turística y de servicios', 3, 'Señales que indican la ubicación de servicios e información turísticas'),
('Educativas y anuncios especiales', 3, 'Señales educativas y anuncios especiales'),
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
('R10', 'Prohibición de cambio de carril', 'Prohíbe cambiar de carril', 1,'Circular', '');

-- Reglamentarias - Restricción
INSERT INTO senializacion.senales (codigo, nombre, descripcion, subelemento_id, forma, contenido)
VALUES

('R11(a)', 'Limitación de peso','Prohíbe el paso a vehículos cuyo peso exceda el valor indicado.', 2,'Circular','' ),
('R11(b)', 'Limitación de peso por eje', 'Prohíbe el paso a vehículos cuyo peso exceda el valor indicado.', 2,'Circular', ''),
('R12', 'Limitación de altura', 'Prohíbe el paso a vehículos que sobrepasen la altura indicada.', 2,'Circular', 'Altura en m'),
('R13', 'Limitación de ancho', 'Prohíbe el paso a vehículos que sobrepasen el ancho indicado.', 2,'Circular', 'Ancho en m'),
('R14', 'Limitación de largo','Prohíbe el paso a vehículos que excedan el largo indicado.', 2,'Circular', 'Largo en m'),
('R15', 'Límite de velocidad máxima', 'Prohíbe circular a velocidades superiores a la indicada.',2, 'Circular', 'Velocidad (km/h)'),
('R16', 'Límite de velocidad mínima', 'Prohíbe circular a velocidades inferiores a la indicada.',2, 'Circular', 'Velocidad (km/h)'),
('R17', 'Estacionamiento exclusivo', 'Permite estacionar sobre la vía',2, 'Circular', 'Velocidad (km/h)'),
('R18', 'Circulación exclusiva', 'Indica que el carril indicado es de uso exclusivo según la imagen',2, 'Circular', 'Velocidad (km/h)'),
('R18(a)', 'Circulación exclusiva (transp. público)', 'Indica que el carril indicado es de uso exclusivo de transporte público',2, 'Circular', ''),
('R18(b)','Circulación exclusiva (motos)', 'Indica que el carril indicado es de uso exclusivo de motos',2, 'Circular', ''),
('R18(c)','Circulación exclusiva (bicicletas)', 'Indica que el carril indicado es de uso exclusivo de bicicletas',2, 'Circular', ''),
('R18(d)','Circulación exclusiva (jinetes)', 'Indica que el carril indicado es de uso exclusivo de jinetes',2, 'Circular', ''),
('R18(e)','Circulación exclusiva (peatones)', 'Indica que el carril indicado es de uso exclusivo de peatones',2, 'Circular', ''),

('R19', 'Uso de cadenas para nieve', 'Uso obligatorio en la zona por presencia de nieve',2, 'Circular', ''),
('R20(a)', 'Giro obligatorio (derecha)', 'Se debe seguir el sentido de la flecha',2, 'Circular', ''),
('R20(b)', 'Giro obligatorio (izquierda)', 'Se debe seguir el sentido de la flecha',2, 'Circular', ''),
('R21(a)', 'Sentido de circulación (derecha)', 'Establece la obligación de circular en el sentido de la flecha',2, 'Circular', ''),
('R21(b)', 'Sentido de circulación (izquierda)', 'Establece la obligación de circular en el sentido de la flecha',2, 'Circular', ''),
('R21(c)', 'Sentido de circulación (comienzo sentido único)', 'Establece la obligación de circular en el sentido de la flecha',2, 'Circular', ''),
('R21(d)', 'Sentido de circulación (alternativa)', 'Establece la obligación de circular en el sentido de la flecha',2, 'Circular', ''),

('R22(a)', 'Paso obligatorio (derecha)', 'Para indicar derroteros y obstaculos fijos',2, 'Circular', ''),
('R22(b)', 'Paso obligatorio (izquierda)', 'Para indicar derroteros y obstaculos fijos',2, 'Circular', ''),
('R23', 'Tránsito pesado a la derecha', 'Los vehículos de transporte pesado deben circular por la derecha',2, 'Circular', ''),
('R24', 'Peatón por la izquierda', '',2, 'Circular', ''),
('R25', 'Puesto de control', '',2, 'Circular', ''),
('R26', 'Comienzo de doble mano', '',2, 'Circular', '');





-- Reglamentarias - 'prioridad'
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('R27', 'Pare', 'Obligación de detener la marcha totalmente', 'Circular', 3),
('R28', 'Ceda el paso', 'Se pierde la prioridad de paso', 'Circular', 3),
('R29', 'Preferencia de avance', 'No tiene preferencia para avanzar el vehículo que tiene el cartel de frente', 'Circular', 3),
('R30', 'Barreras ferroviales', '', 'Circular', 3);

-- Reglamentarias - 'fin de la prescripcion'
INSERT INTO senializacion.senales (codigo, nombre, descripcion, forma, subelemento_id) VALUES
('R31', 'Fin de de la prescripción', '', 'Circular', 4),
('R32', 'Fin de de la prescripción', '', 'Circular', 4);



-- Señales Preventivas - Advertencia de máximo peligro(P1–P6)
INSERT INTO senializacion.senales (codigo, nombre, descripcion,subelemento_id, forma) VALUES
('P1', 'CRUCE FERROVIARIO', 'Advierte la proximidad de un cruce ferrovial a nivel, por lo que se debe disminuir la velocidad y prestar atención a la posible aproximación de trenes', 5, 'Triangular'), 

('P2 (a)', 'PANELES DE PREVENCION (aprox)', 'Advierte la aproximación del objeto señalado', 5, 'Rectangular'), 

('P2 (b)', 'PANELES DE PREVENCION (objeto rígido)', 'Advierte la presencia de un objeto rígido fuera de la calzada y banquina (donde no debe haberlo), que puede ocasionar daño en una eventual salida de la via (v. gr: alcantarilla)', 5, 'Rectangular'), 

('P2 (c)', 'PANELES DE PREVENCION (curva/chevron)', 'Advierte y delimita una curva peligrosa', 5, 'Cuadrangular'), 

('P3', 'CRUZ DE SAN ANDRES', 'Señala el limite de la zona del cruce ferrovial, dentro de la cual rige la prioridad de paso del ferrocarril. En caso de aproximarse fuera de dicha zona hasta que aquel deje el paso y en tanto no se aproxime otro.', 5, 'Cruz'), 

('P4', 'CURVA CERRADA', 'Proximidad de curva peligrosa hacia el mismo lado indicado por la flecha', 5, 'Triangular'), 

('P5', 'CRUCE DE PEATONES', 'Proximidad de un cruce peatonal', 5, 'Triangular'), 

('P6', 'ATENCIÓN', 'Alerta sobre un mensaje especial', 5, 'Triangular');



-- Señales Preventivas - Advertencia sobnre características de la via
INSERT INTO senializacion.senales (codigo, nombre, descripcion,subelemento_id, forma) VALUES

('P7(a)', 'CURVA (común y pronunciada)', 'Curva: indica la proximidad de una curva en la dirección de la flecha. Curva pronunciada: se utiliza para advertir a los conductores la proximidad de una curva pronunciada en la dirección de la flecha', 6, 'Romboidal'), 

('P7(b)', 'CURVA (contracurva)', 'Curva y contra curva: Advierte la posibilidad de un tramo con dos curvas en sentido contrario separadas por una tangente de longitud normal', 6, 'Romboidal'), 

('P7(c)', 'CURVA (en “s”)', 'Curva pronunciada en “s”: se utiliza para advertir la proximidad de un tramo con dos curvas de sentido contrario separadas por una tangente de longitud mínima', 6, 'Romboidal'), 

('P8', 'CAMINO SINUOSO', 'Se utiliza para advertir la proximidad de tres o más curvas sucesivas en el camino', 6, 'Romboidal'), 

('P9(a)', 'PENDIENTE (descendente)', 'Indica la existencia de una cuesta y el sentido de la inclinación', 6, 'Romboidal'), 

('P9(b)', 'PENDIENTE (ascendente)', 'Indica la existencia de una cuesta y el sentido de la inclinación', 6, 'Romboidal'), 

('P10(a)', 'ESTRECHAMIENTO (en las dos manos)', 'La vía se estrecha mas adelante, en forma simétrica o no, según lo indique la figura', 6, 'Romboidal'), 

('P10(b)', 'ESTRECHAMIENTO (en una sola mano)', 'La vía se estrecha más adelante, según lo indique la figura', 6, 'Romboidal'), 

('P11(a)', 'PERFIL IRREGULAR (irregular)', 'Que la superficie de la calzada tiene irregularidades que pueden provocar modificaciones en las condiciones normales de marcha', 6, 'Romboidal'), 

('P11(b)', 'PERFIL IRREGULAR (baden)', 'Que la superficie de la calzada tiene irregularidades que pueden provocar modificaciones en las condiciones normales de marcha', 6, 'Romboidal'), 

('P11(c)', 'PERFIL IRREGULAR (lomada)', 'Que la superficie de la calzada tiene irregularidades que pueden provocar modificaciones en las condiciones normales de marcha', 6, 'Romboidal'), 

('P12', 'CALZADA RESBALADIZA', 'Presencia de calzada que puede tornarse resbaladiza, por defectos de superficie de elementos extraños (agua, aceite, polvo, etc.) sobre ella', 6, 'Romboidal'), 

('P13', 'PROYECCION DE PIEDRAS', 'En la zona puede haber piedras sobre la calzada que pueden ser proyectadas por los vehículos que transitan', 6, 'Romboidal'), 

('P14', 'DERRUMBES', 'Que de la elevación próxima a la ruta, aunque no tenga la inclinación del dibujo, pueden desprenderse rocas o partes que caen o ruedan sobre la calzada', 6, 'Romboidal'), 

('P15', 'TUNEL', 'Proximidad de un túnel para circulación en el camino', 6, 'Romboidal'), 

('P16', 'PUENTE ANGOSTO', 'Presencia sobre la calzada de un puente de menor ancho que el resto de la vía', 6, 'Romboidal'), 

('P17', 'PUENTE MOVIL', 'aproximación a un puente levadizo, rotatorio o flotante que eventualmente puede estar en posición que interrumpa la vía', 6, 'Romboidal'), 

('P18', 'ALTURA LIMITADA', 'Se utilizará para advertir la proximidad de una estructura elevada y el límite de altura permitido para el vehículo', 6, 'Romboidal'), 

('P18', 'ALTURA LIMITADA', 'Se utilizará para advertir la proximidad de una estructura elevada y el límite de altura permitido para el vehículo', 6, 'Romboidal'), 

('P19', 'ANCHO LIMITADO', 'Se utilizará para advertir el límite del ancho permitido del vehículo para circular por el carril', 6, 'Romboidal'), 

('P20', 'PRINCIPIO Y FIN DE CALZADA DIVIDIDA', 'Principio de calzada dividida: Indica la división física conservando los sentidos de circulación indicados en la señal. Fin de calzada dividida: Indica la finalización del separador físico', 6, 'Romboidal'), 

('P21', 'ROTONDA', 'Proximidad de una rotonda (articulo 43 inciso e, de la ley de transito). Se circula por ella dejando la parte central (no necesariamente redonda) a la izquierda', 6, 'Romboidal'), 

('P22', 'INCORPORACION DE TRANSITO LATERAL', 'Advierte la proximidad de una confluencia de izquierda o de derecha por donde se incorpora una corriente de transito en el mismo sentido', 6, 'Romboidal'), 

('P23', 'INICIO DE DOBLE CIRCULACION', 'Indica circulación transitoria en ambos sentidos sobre la calzada, sin disminuir el ancho de la mano propia', 6, 'Romboidal'), 

('P24(a)', 'ENCRUCIJADA (cruce)', 'Indica cruces de vías de circulación', 6, 'Romboidal'), 

('P24(b)', 'ENCRUCIJADA (empalme)', 'Indica empalme de vías de circulación', 6, 'Romboidal'), 

('P24(c)', 'ENCRUCIJADA (bifurcación)', 'Indica que la vía se divide en los sentidos indicados', 6, 'Romboidal'), 

('P24(d)', 'ENCRUCIJADA (bifurcación)', 'Indica que la vía se divide en los sentidos indicados', 6, 'Romboidal');




-- Señales Preventivas - posibilidad de riesgo eventual
INSERT INTO senializacion.senales (codigo, nombre, descripcion,subelemento_id, forma) VALUES

('P25(a)', 'ESCOLARES', 'Indica que en la zona pueden aparecer imprevisiblemente escolares, por la existencia de escuelas, campos de deporte, etc.', 7, 'Romboidal'), 

('P25(b)', 'NIÑOS', 'Indica que en la zona pueden aparecer imprevisiblemente escolares, por la existencia de escuelas, campos de deporte, etc.', 7, 'Romboidal'), 

('P26(a)', 'CICLISTAS', 'Eventual presencia de personas circulando en bicicleta', 7, 'Romboidal'), 

('P26(b)', 'JINETES', 'Eventual presencia de personas circulando a caballo', 7, 'Romboidal'), 

('P27(a)', 'ANIMALES SUELTOS (vaca)', 'Eventual presencia individual o en manadas de animales de crianza o salvajes en la vía', 7, 'Romboidal'), 

('P27(a)', 'ANIMALES SUELTOS (ciervo)', 'Eventual presencia individual o en manadas de animales de crianza o salvajes en la vía', 7, 'Romboidal'), 

('P28', 'CORREDOR AEREO', 'Vuelo a baja altura de aviones por la proximidad de un aeródromo o aeropuerto', 7, 'Romboidal'), 

('P29', 'PRESENCIA DE VEHICULOS EXTRAÑOS', 'operación habitual en la zona de los vehículos indicados en la señal', 7, 'Romboidal'), 

('P29(a)', 'PRESENCIA DE VEHICULOS EXTRAÑOS (tranvía)', 'operación habitual en la zona de los vehículos indicados en la señal', 7, 'Romboidal'), 

('P29(b)', 'PRESENCIA DE VEHICULOS EXTRAÑOS (tractor)', 'operación habitual en la zona de los vehículos indicados en la señal', 7, 'Romboidal'), 

('P29(c)', 'PRESENCIA DE VEHICULOS EXTRAÑOS (ambu.)', 'operación habitual en la zona de los vehículos indicados en la señal', 7, 'Romboidal'), 

('P30', 'VIENTOS FUERTES LATERALES', 'Probabilidad de que soplen vientos fuertes laterales', 7, 'Romboidal');



-- Señales Preventivas - anticipo de otros dispositivos
INSERT INTO senializacion.senales (codigo, nombre, descripcion,subelemento_id, forma) VALUES

('P31', 'FLECHA DIRECCIONAL', 'Advierte la/s dirección/es en que continua la circulación', 8, 'Rectangular'), 

('P32', 'PROXIMIDAD DE SEMAFOROS', 'Advierte la proximidad de una intersección con semaforización', 8, 'Romboidal'), 

('P33', 'PROXIMIDAD DE SEÑAL RESTRICTIVA', 'Advierte la proximidad de señal prescriptiva indicada en la figura', 8, 'Romboidal'), 

('P33(a)', 'PROXIMIDAD DE SEÑAL RESTRICTIVA (pare)', 'Advierte la proximidad de señal prescriptiva indicada en la figura', 8, 'Romboidal'), 

('P33(b)', 'PROXIMIDAD DE SEÑAL RESTRICTIVA (paso)', 'Advierte la proximidad de señal prescriptiva indicada en la figura', 8, 'Romboidal'), 

('P33(c)', 'PROXIMIDAD DE SEÑAL RESTRICTIVA (otras)', 'Advierte la proximidad de señal prescriptiva indicada en la figura', 8, 'Romboidal');


-- Señales Preventivas - fin de la prevencion
INSERT INTO senializacion.senales (codigo, nombre, descripcion,subelemento_id, forma) VALUES
('P34', 'FIN CALZADA RESBALADIZA', 'Fin de la zona con el riesgo prevenido por la señal cuya figura contiene la presente', 9, 'Romboidal'), 

('P34', 'FIN ZONA DE DERRUMBE', 'Fin de la zona con el riesgo prevenido por la señal cuya figura contiene la presente', 9, 'Romboidal');

 





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





--Para insertar los modificadores
WITH r3 AS (
    SELECT id FROM senializacion.senales WHERE codigo = 'R3'
)

-- Insertar modificadores para R15
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehículo,leyenda_extra,imagen)
SELECT id, 20,'' , '','r15(20)' FROM r3
UNION ALL
SELECT id, 30,'' , 'MAXIMA','r15(30)1' FROM r3
UNION ALL
SELECT id, 40,'' , '','r15(40)' FROM r3
UNION ALL
SELECT id, 40,'' , 'MAXIMA','r15(40)1'FROM r3
UNION ALL
SELECT id, 40,'' , 'VELOCIDAD MAXIMA','r15(40)2'FROM r3
UNION ALL
SELECT id, 60,'' , '','r15(60)'FROM r3
UNION ALL
SELECT id, 60,'' , 'MAXIMA','r15(60)1'FROM r3
UNION ALL
SELECT id, 60,'' , 'VELOCIDAD MAXIMA','r15(60)2'FROM r3
UNION ALL
SELECT id, 60,'CAMIONES' , 'MAXIMA','r15(60)3'FROM r3
UNION ALL
SELECT id, 70,'' , '','r15(70)'FROM r3
UNION ALL
SELECT id, 80,'' , '','r15(80)'FROM r3
UNION ALL
SELECT id, 80,'' , 'MAXIMA','r15(80)1'FROM r3
UNION ALL
SELECT id, 80,'' , 'VELOCIDAD MAXIMA','r15(80)2'FROM r3
UNION ALL
SELECT id, 100,'' , '','r15(100)'FROM r3
UNION ALL
SELECT id, 100,'' , 'MAXIMA','r15(100)1'FROM r3
UNION ALL
SELECT id, 100,'' , 'VELOCIDAD MAXIMA','r15(100)2'FROM r3
UNION ALL
SELECT id, 60,'METROBUS' , '','r15(60)4'FROM r3




--Para insertar los modificadores
WITH r15 AS (
    SELECT id FROM senializacion.senales WHERE codigo = 'R15'
)

-- Insertar modificadores para R15
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehículo,leyenda_extra,imagen)
SELECT id, 20,'' , '','r15(20)' FROM r15
UNION ALL
SELECT id, 30,'' , 'MAXIMA','r15(30)1' FROM r15
UNION ALL
SELECT id, 40,'' , '','r15(40)' FROM r15
UNION ALL
SELECT id, 40,'' , 'MAXIMA','r15(40)1'FROM r15
UNION ALL
SELECT id, 40,'' , 'VELOCIDAD MAXIMA','r15(40)2'FROM r15
UNION ALL
SELECT id, 60,'' , '','r15(60)'FROM r15
UNION ALL
SELECT id, 60,'' , 'MAXIMA','r15(60)1'FROM r15
UNION ALL
SELECT id, 60,'' , 'VELOCIDAD MAXIMA','r15(60)2'FROM r15
UNION ALL
SELECT id, 60,'CAMIONES' , 'MAXIMA','r15(60)3'FROM r15
UNION ALL
SELECT id, 70,'' , '','r15(70)'FROM r15
UNION ALL
SELECT id, 80,'' , '','r15(80)'FROM r15
UNION ALL
SELECT id, 80,'' , 'MAXIMA','r15(80)1'FROM r15
UNION ALL
SELECT id, 80,'' , 'VELOCIDAD MAXIMA','r15(80)2'FROM r15
UNION ALL
SELECT id, 100,'' , '','r15(100)'FROM r15
UNION ALL
SELECT id, 100,'' , 'MAXIMA','r15(100)1'FROM r15
UNION ALL
SELECT id, 100,'' , 'VELOCIDAD MAXIMA','r15(100)2'FROM r15
UNION ALL
SELECT id, 60,'METROBUS' , '','r15(60)4'FROM r15


--Para insertar los modificadores
WITH r15 AS (
    SELECT id FROM senializacion.senales WHERE codigo = 'R16'
)

-- Insertar modificadores para R16
INSERT INTO senializacion.senal_modificadores (senal_id, contenido, tipo_vehículo,leyenda_extra,imagen)
SELECT id, '50','' , '','r16(50)' FROM r15
UNION ALL
SELECT id, 50,'' , 'MINIMA','r16(50)1' FROM r15
UNION ALL
SELECT id, 50,'' , 'VELOCIDAD MINIMA','r16(50)2'FROM r15
UNION ALL
SELECT id, 00,'' , '','r16'FROM r15



-- Vamos a popular senializacion.senializacionvertical



INSERT INTO senializacion.senializacionvertical (     
    id_tramo,
    id_banda,
    id_senal,
	id_modificador,  
    -- Datos físicos del cartel
    forma,
    dimensiones,
    soporte,
    id_soporte,
    -- Información operativa
    estado,
    pk,
    contenido,

   -- activo,

    -- Fechas de gestión
    f_instalacion,
    f_ult_interv,
    geom
)

SELECT
    sv.id_tramo,
    sv.id_banda,
    sm.senal_id,
	sm.id ,
    -- Datos físicos del cartel
    sv.forma,
    sv.dimensiones,
    sv.soporte,
    sv.id_soporte,
    
    -- Información operativa
    sv.estado,
    sv.pk,
    sm.contenido,

    -- Fechas de gestión
    sv.f_instalacion,
    sv.f_ult_interv,

    sv.geom


FROM
    gisdata.v_senializacionvertical sv
JOIN
    senializacion.senal_modificadores sm
    ON UPPER(REPLACE(sv.iconografia, '.png', '')) = UPPER(sm.imagen)
WHERE
    sv.iconografia ILIKE 'R15%' OR sv.iconografia ILIKE 'R16%';



drop view senializacion.v_senializacionvertical_velocidades;

CREATE OR REPLACE VIEW senializacion.v_senializacionvertical_velocidades AS

SELECT
	v.id,
    v.id_tramo,
    v.id_banda,
    v.id_senal,
    
    cat.nombre AS categoria,
    ele.nombre AS elemento,
    ele.obs AS obs_elemento,
    sub.nombre AS subelemento,
    sen.codigo,
    sen.nombre AS senal,
    sen.descripcion,
    sm.contenido AS contenido,
    sm.tipo_vehiculo,
    sm.leyenda_extra,
    sm.imagen AS imagen,
    v.forma,
    v.dimensiones,
    v.soporte,
    v.id_soporte,
    v.estado,
    v.pk,
    v.contenido AS contenido_vertical,
    v.f_instalacion,
    v.f_ult_interv,
    v.geom,
'https://maps.ausa.com.ar/pngicons/sv/'||sm.imagen||'.png' as iconografia,

'<img src=''https://maps.ausa.com.ar/pngicons/sv/'::text || sm.imagen::text||'.png''width=70' as iconografia_img
FROM
    senializacion.senializacionvertical v
JOIN senializacion.senal_modificadores sm 
    ON v.id_modificador = sm.id
JOIN senializacion.senales sen 
    ON sm.senal_id = sen.id
JOIN senializacion.subelementos sub 
    ON sen.subelemento_id = sub.id
JOIN senializacion.elementos ele 
    ON sub.elemento_id = ele.id
JOIN senializacion.categorias cat 
    ON ele.id_categoria = cat.id_categoria
WHERE
    sen.codigo IN ('R15','R16');  -- Corregido el cierre de comillas

select * from senializacion.v_senializacionvertical_velocidades;
