DROP DATABASE IF EXISTS sepa;

CREATE DATABASE sepa;

USE sepa;

CREATE TABLE empresas(
	id BIGINT NOT NULL AUTO_INCREMENT,
	cuit BIGINT NOT NULL,
	nombre VARCHAR(255),
	razon_social VARCHAR(255),
	PRIMARY KEY (id),
	UNIQUE KEY idx_cuit (cuit)
);

CREATE TABLE puntos_de_venta(
	id BIGINT NOT NULL AUTO_INCREMENT,
	nombre VARCHAR(255),
	direccion VARCHAR(255),
	latitud DOUBLE, -- lat y long idealmente se almacenarian usando un tipo de datos espaciales de GIS, como GEOMETRY
	longitud DOUBLE,
	id_empresa BIGINT NOT NULL,
	categoria VARCHAR(13), -- 'almacen', 'mercado', 'autoservicio', 'supermercado' o 'hipermercado'
	PRIMARY KEY (id),
	CONSTRAINT fk_id_empresa FOREIGN KEY (id_empresa) REFERENCES empresas(id)
);

CREATE TABLE productos(
	id BIGINT NOT NULL AUTO_INCREMENT,
	codigo_ean BIGINT NOT NULL,
	descripcion VARCHAR(255), -- "Desodorante en aerosol Axe 152ml"
	productor VARCHAR(255), -- "Unilever"
	marca VARCHAR(255), -- "Axe"
	presentacion VARCHAR(255), -- deberia ser human-readable y parseable a la vez: "152ml"
	categoria VARCHAR(255), -- "Perfumeria"
	subcategoria VARCHAR(255), -- "Desodorantes"
	nombre_generico VARCHAR(255), -- "Desodorante en aerosol"
	PRIMARY KEY (id),
	UNIQUE KEY idx_en_codigo_ean (codigo_ean)
);

CREATE TABLE promociones(
	id BIGINT NOT NULL AUTO_INCREMENT,
	descripcion TEXT,
	minimo_unidades INTEGER NOT NULL DEFAULT 1,
	fraccion_bonificada DECIMAL(2,2), -- el tipo de dato es restrictivo a proposito, para evitar precios promocionalesnegativos y otras inconsistencias
	PRIMARY KEY (id)
);
-- Se debe consignar la fraccion total bonificada: un 50% de desc. en la 2da unidad representa una fraccion_bonificada de .25 con un minimo_unidades de 2.
-- En un sistema de produccion, las Promociones deberian poder ser gerenciadas por la Empresa o sus representantes, con los campos adicionales que ello implica.

CREATE TABLE partes_de_precio(
	id BIGINT NOT NULL AUTO_INCREMENT,
	id_producto BIGINT NOT NULL,
	id_punto_de_venta BIGINT NOT NULL,
	creado_en DATETIME NOT NULL, -- si el pais tiene un solo huso horaro TIMESTAMP no es necesario
	actualizado_en DATETIME NOT NULL,
	fecha_vigencia DATE NOT NULL,
	precio_lista DECIMAL(11,2) NOT NULL,
	id_promocion_1 BIGINT DEFAULT NULL,
	precio_promocion_1 DECIMAL(11,2) DEFAULT NULL, -- idealmente esto se computa automaticamente en funcion de precio_lista y los datos de la promo con id=id_promocion_1
	id_promocion_2 BIGINT DEFAULT NULL,
	precio_promocion_2 DECIMAL(11,2) DEFAULT NULL,
	PRIMARY KEY(id),
	UNIQUE KEY idx_en_producto_pdv_y_fecha (id_producto, id_punto_de_venta, fecha_vigencia),
	CONSTRAINT fk_id_promo_1 FOREIGN KEY (id_promocion_1) REFERENCES promociones(id),
	CONSTRAINT fk_id_promo_2 FOREIGN KEY (id_promocion_2) REFERENCES promociones(id)
);

-- Las dos siguientes tablas no son parte del DER basico, pero se incluyen para calcular algunos indicadores.

CREATE TABLE canastas(
	id BIGINT NOT NULL AUTO_INCREMENT,
	descripcion VARCHAR(255), -- "Aproximacion division Alimentos y Bebidas consumidos en el hogar, Metodologia IPC Abril 2016", "Ingredientes para 12 pizzas de muzzarella"
	PRIMARY KEY (id)
);

CREATE TABLE componentes_canastas(
	id BIGINT NOT NULL AUTO_INCREMENT,
	id_canasta BIGINT NOT NULL,
	id_producto BIGINT NOT NULL,
	cantidad INTEGER,
	PRIMARY KEY(id),
	CONSTRAINT fk_id_producto FOREIGN KEY (id_producto) REFERENCES productos(id),
	CONSTRAINT fk_id_canasta FOREIGN KEY (id_canasta) REFERENCES canastas(id),
	UNIQUE KEY idx_en_canasta_y_producto (id_canasta, id_producto) -- Cada producto aparece una sola vez por canasta
);
