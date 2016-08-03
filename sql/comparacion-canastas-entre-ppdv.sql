-- Calcular y comparar valores de canastas representativas a fecha de hoy, entre Puntos de Venta
USE sepa;

-- Creo vista con los precios de lista promedios observados en todos los Partes de hoy:
DROP VIEW IF EXISTS precios_promedios_de_hoy;
CREATE VIEW precios_promedios_de_hoy AS
SELECT id_producto,
	COUNT(id) AS cantidad_partes,
	AVG(precio_lista) AS precio_lista_promedio
FROM partes_de_precio
GROUP BY id_producto;

-- Asociando los componentes de c/ canasta con los Partes de hoy para cada PDV, calculo el valor de lista de las canastas.
-- En caso de que no haya Parte para cierto producto, se utiliza el precio de lista promedio del dia en todos los locales.
-- 'esta_completa' es un valor booleano:
-- - '1' si el PDV tiene hoy Partes para todos los productos de la canasta, y
-- - '0' si falta al menos uno.

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
WHERE partes_de_precio.fecha_vigencia=CURDATE()
GROUP BY id_canasta, id_punto_de_venta;

-- Finalmente, se construye el indicador de competitividad procurando como base el precio de lista minimo entre las canastas completas y asignandole un valor de '100'. (mientras mas cercano a 100, mas competitivos los precios del PDV)

SET @idCanastaRep = 1;
SET @baseIndicador = (SELECT MIN(valor_lista_canasta)
			FROM valor_canastas_de_hoy_por_pdv
			WHERE id_canasta=@idCanastaRep AND esta_completa=1);

SELECT id_punto_de_venta,
	valor_lista_canasta / @baseIndicador * 100 AS 'indicador_competitividad',
	valor_lista_canasta,
	esta_completa

FROM valor_canastas_de_hoy_por_pdv
WHERE id_canasta=@idCanastaRep
;

-- Ejecutar esta consulta sobre _todos_ los PDV a la vez  puede ser prohibitivamente lento. Para evitar problemas, se pueden materializar las vistas (en especial, `valor_canastas_de_hoy_por_pdv`), y/o evitar recalcular constantemente estos indicadores, guardando los resultados diarios en tablas auxiliares.
