
Ejercicio SEPA
==============

Gonzalo Barrera Borla
1-3 Agosto 2016

## Descripcion

**Objetivo:** Identificar las tablas y campos que debería tener la base de datos de un sistema como el descrito en la resolución (ver link), así como las relaciones entre ellas. Identificar indicadores calculados relevantes que exploten las posibilidades de análisis de dicha base de datos. Escribir el código SQL necesario para calcular 2 (dos) de los indicadores propuestos.

**Entregable:** Esquema del DER en el formato de preferencia, documentación de los indicadores relevantes calculados identificados y consultas SQL utilizadas para calcular 2 (dos) de estos indicadores.

## Metodologia

Para confeccionar el diagrama entidad-relacion basico necesario, junto con algunos extras utiles para el analisis, se consulto la Resolucon 12/2016. El proceso se detalla [aqui](metodologia/analisis-resolucion.md).

Con el DER preparado, y luego de un periodo de evaluacion de las posibilidades que este presenta, se encaro la descripcion de posibles indicadores en [este](metodologia/indicadores.md) documento.

## Entregable

- Archivos SVG del [DER minimo](img/der-minimo.svg) y el [DER completo](img/der-completo.svg) estan disponibles en `img/`.
- La [documentacion](metodologia/indicadores.md) sobre posibles indicadores ya se menciono, y se encuentra en la carpeta `metodologia/`.
- Las consultas SQL para dos de estos indicadores, junto con una implementacion en MySQL del DER completo estan en `sql/`.

## Recursos Utiles
 
Relevantes al SEPA:
- [Secretaria de Comercio, Resolucion 12/2016, Sistema Electronico de Publicidad de Precios Argentinos](https://www.boletinoficial.gob.ar/pdf/linkQR/aUhvb3k0ZmlGKzVycmZ0RFhoUThyQT09)
- [Sitio Precios Claros](https://www.preciosclaros.gob.ar/)

Relevantes al IPC:
- [Que es el IPC?](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_que_es_06_16.pdf)
- [Metodologia IPC Abril 2016](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_metodologia_abril2016.pdf)
