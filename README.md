
Ejercicio SEPA
==============

- Gonzalo Barrera Borla
- 1-3 Agosto 2016

## Descripción

**Objetivo:** Identificar las tablas y campos que debería tener la base de datos de un sistema como el descrito en la resolución (ver link), así como las relaciones entre ellas. Identificar indicadores calculados relevantes que exploten las posibilidades de análisis de dicha base de datos. Escribir el código SQL necesario para calcular 2 (dos) de los indicadores propuestos.

**Entregable:** Esquema del DER en el formato de preferencia, documentación de los indicadores relevantes calculados identificados y consultas SQL utilizadas para calcular 2 (dos) de estos indicadores.

## Metodología

Para confeccionar el diagrama entidad-relación básico necesario, junto con algunos extras útiles para el analisis, se consultó la Resolución 12/2016. El proceso se detalla [aquí](metodologia/analisis-resolucion.md).

Con el DER preparado, y luego de un período de evaluación de las posibilidades que éste presenta, se encaró la descripción de posibles indicadores en [este](metodologia/indicadores.md) documento.

## Entregable

- Archivos PNG del [DER minimo](img/der-minimo.png) y el [DER completo](img/der-completo.png) están disponibles en `img/`. Para confeccionarlos se utilizó [Draw.io](https://www.draw.io/), y los archivos XML "crudos" se encuentran en `xml/`.
- La [documentación](metodologia/indicadores.md) sobre posibles indicadores ya se mencionó, y se encuentra en la carpeta `metodologia/`.
- Las consultas SQL para dos de estos indicadores, junto con una implementación en MySQL del DER completo estan en `sql/`.

## Recursos Útiles
 
Relevantes al SEPA:
- [Secretaría de Comercio, Resolución 12/2016, Sistema Electrónico de Publicidad de Precios Argentinos](https://www.boletinoficial.gob.ar/pdf/linkQR/aUhvb3k0ZmlGKzVycmZ0RFhoUThyQT09)
- [Sitio Precios Claros](https://www.preciosclaros.gob.ar/)

Relevantes al IPC:
- [Qué es el IPC?](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_que_es_06_16.pdf)
- [Metodología IPC Abril 2016](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_metodologia_abril2016.pdf)
