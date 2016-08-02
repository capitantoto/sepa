Ejercicio SEPA
==============

**Objetivo:** Identificar las tablas y campos que debería tener la base de datos de un sistema como el descrito en la resolución (ver link), así como las relaciones entre ellas. Identificar indicadores calculados relevantes que exploten las posibilidades de análisis de dicha base de datos. Escribir el código SQL necesario para calcular 2 (dos) de los indicadores propuestos.

**Entregable:** Esquema del DER en el formato de preferencia, documentación de los indicadores relevantes calculados identificados y consultas SQL utilizadas para calcular 2 (dos) de estos indicadores.

## Identificacion de entidades en base a la Resolución 12/2016

> Artículo 1° — Créase en el ámbito de la SECRETARÍA DE COMERCIO del MINISTERIO DE
PRODUCCIÓN el “Sistema Electrónico de Publicidad de Precios Argentinos (SEPA)”, a través del cual
todos los comercios que realicen venta minorista de productos de consumo masivo, deberán informar en
forma diaria para su difusión los precios de venta al público vigentes en cada punto de venta, de los
productos que se determinen en la reglamentación

Aqui podemos identificar tres entidades basicas: el **Comercio**, el **Punto de Venta** y el **Producto**. Para evitar ambiguedades semanticas entre Comercio y Punto de Venta y apegarnos al vocabulario de la Resolucion, reemplazaremos Comercio por **Empresa**, que figura en el Art. 3 item (a).

Diariamente, el Comercio debera proveer un parte de precios, detallando la totalidad de los precios que estipula en cada Punto de Venta y Producto. Dado que los principales sujetos de esta Resolucion (Coto, Dia, Carrefour, et al) manejan cientos de tiendas y miles de productos, es evidente que la interfaz que utilicen debera permitir especificar muchos precios con una sola operacion (e.g.: mismo precio de cierto producto en todos los puntos de venta). Sin embargo, en la base de datos, la informacion provista debera almacenarse atomicamente, idealmente con un registro por Producto y Punto de Venta. Nuestra cuarta entidad sera el **Parte de Precio**, que refleja los precios (de lista y promocional) de un determinado producto, en cierto punto de venta, para determinada fecha.

Un primer y sencillo ERD seria entonces:

[METER ACA ERD SIN TABLAS]

El articulo tercero de la resolucion menciona la informacion minima que el sistema debera recolectar:

> Art. 3° — La información suministrada será difundida y de público acceso para el consumidor y deberá
contener, para cada producto y por cada punto de venta, como mínimo los siguientes datos:
a) CUIT de la empresa, razón social y nombre o denominación comercial;
b) Ubicación de cada punto de venta, con domicilio completo y coordenadas para que permita su
geolocalización;
c) Código EAN o equivalente sectorial del producto;
d) Precio de lista de venta minorista final al público por unidad, peso o medida de producto, según la
forma de comercialización; y
e) Promociones, descuentos y todo tipo de bonificaciones.

Los items (a), (b) y (c) hacen referencia, respectivamente, a los atributos minimos que deberan tener las Empresas, los Puntos de Venta y los Productos, respectivamente. Los items (d) y (e) hacen referencia a la informacion que debe ser suministrada diariamente en el Parte de Precio.


