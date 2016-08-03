-- Este 

USE sepa;

DROP VIEW IF EXISTS precios_promedios_de_hoy;
CREATE VIEW precios_promedios_de_hoy AS
SELECT id_producto,
	COUNT(id) AS cantidad_partes,
	AVG(precio_lista) AS precio_lista_promedio
FROM partes_de_precio
GROUP BY id_producto;

DROP VIEW IF EXISTS valor_canastas_de_hoy_por_pdv;
CREATE VIEW valor_canastas_de_hoy_por_pdv AS
SELECT id_canasta,
	id_punto_de_venta,
	SUM(componentes_canastas.cantidad * COALESCE(
		partes_de_precio.precio_lista, 
		precios_promedios_de_hoy.precio_lista_promedio))
	AS 'valor_lista_canasta',
	(COUNT(partes_de_precio.id_producto) = COUNT(componentes_canastas.id_producto)) AS 'esta_completa'
FROM canastas
JOIN componentes_canastas
	ON canastas.id=componentes_canastas.id_canasta
JOIN precios_promedios_de_hoy
	ON componentes_canastas.id_producto=precios_promedios_de_hoy.id_producto -- Es importante que 'precios_promedios_de_hoy' contenga datos para todo producto de las canastas a fin de no perder filas
LEFT JOIN partes_de_precio
	ON componentes_canastas.id_producto=partes_de_precio.id_producto
GROUP BY id_canasta, id_punto_de_venta;
