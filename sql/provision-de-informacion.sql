-- Estimar que Empresas no estan entregando tanta informacion como se espera de ellas
USE sepa;

-- Creo una vista con la cantidad de Partes creados diariamente por cada Empresa
DROP VIEW IF EXISTS partes_diarios_por_empresa;
CREATE VIEW partes_diarios_por_empresa AS
SELECT empresas.id AS 'id_empresa',
	partes_de_precio.fecha_vigencia,
	COUNT(partes_de_precio.id) AS 'cantidad'
FROM empresas
JOIN puntos_de_venta
	ON empresas.id=puntos_de_venta.id_empresa
JOIN partes_de_precio
	ON puntos_de_venta.id=partes_de_precio.id_punto_de_venta
GROUP BY empresas.id, fecha_vigencia;

-- Tomo como valor de referencia para la "cantidad esperada de partes" por Empresa su media historica.

-- Seteo la cantidad de dias a considerar para la media reciente, y el umbral por debajo del cual considero a la razon media reciente / media historica como sospechosa. 
-- Ambos parametros se deben ajustar a partir de los resultados para optimizar precision y exhaustividad. Un umbral muy bajo no distinguira nada, y uno demasiado alto sera muy sensible al cierre de sucursales de grandes cadenas, o a las fluctuaciones de stock de las mas pequenias.

SET @nDias = 7;
SET @umbralSospecha = 0.7;

SELECT
	id_empresa,
	CURDATE() AS 'fecha_corriente',
	AVG(cantidad) AS 'media_historica',
	SUM(IF(DATEDIFF(NOW(), fecha_vigencia) < @nDias, cantidad, 0))/ @nDias AS 'media_reciente'
FROM partes_diarios_por_empresa
GROUP BY id_empresa
HAVING media_reciente/media_historica < @umbralSospecha;
