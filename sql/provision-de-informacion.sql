USE sepa;

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

SET @nDias = 7;
SET @umbralSospecha = 0.7;

DROP VIEW IF EXISTS sospechas_partes_faltantes;
CREATE VIEW sospechas_partes_faltantes AS
SELECT
	id_empresa,
	CURDATE() AS 'fecha_corriente',
	AVG(cantidad) AS 'media_historica',
	SUM(IF(DATEDIFF(NOW(), fecha_vigencia) < @nDias, cantidad, 0))/ @nDias AS 'media_reciente'
FROM partes_diarios_por_empresa
GROUP BY id_empresa
HAVING media_reciente/media_historica < @umbralSospecha;
