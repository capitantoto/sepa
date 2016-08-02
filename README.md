
Ejercicio SEPA
==============

## Descripcion

**Objetivo:** Identificar las tablas y campos que debería tener la base de datos de un sistema como el descrito en la resolución (ver link), así como las relaciones entre ellas. Identificar indicadores calculados relevantes que exploten las posibilidades de análisis de dicha base de datos. Escribir el código SQL necesario para calcular 2 (dos) de los indicadores propuestos.

**Entregable:** Esquema del DER en el formato de preferencia, documentación de los indicadores relevantes calculados identificados y consultas SQL utilizadas para calcular 2 (dos) de estos indicadores.

## Anlisis de la Resolucion 12/2016

### Articulo Primero

> Artículo 1° — Créase en el ámbito de la SECRETARÍA DE COMERCIO del MINISTERIO DE
PRODUCCIÓN el “Sistema Electrónico de Publicidad de Precios Argentinos (SEPA)”, a través del cual
todos los comercios que realicen venta minorista de productos de consumo masivo, deberán informar en
forma diaria para su difusión los precios de venta al público vigentes en cada punto de venta, de los
productos que se determinen en la reglamentación

Aqui podemos identificar tres entidades basicas: el **Comercio**, el **Punto de Venta** y el **Producto**. Para evitar ambiguedades semanticas entre Comercio y Punto de Venta y apegarnos al vocabulario de la Resolucion, reemplazaremos Comercio por **Empresa**, que figura en el Art. 3 item (a).

Diariamente, la Empresa debera proveer un parte de precios, detallando la totalidad de los precios que estipula en cada Punto de Venta y Producto. Dado que los principales sujetos de esta Resolucion (Coto, Dia, Carrefour, et al) manejan cientos de tiendas y miles de productos, es evidente que la interfaz que utilicen debera permitir especificar muchos precios con una sola operacion (e.g.: mismo precio de cierto producto en todos los puntos de venta). Sin embargo, en la base de datos, la informacion provista debera almacenarse atomicamente, idealmente con un registro por Producto y Punto de Venta. Nuestra cuarta entidad sera el **Parte de Precio**, que refleja los precios (de lista y promocional) de un determinado producto, en cierto punto de venta, para determinada fecha.

Un primer y sencillo DER seria entonces:

![Fig. 1: DER basico](img/erd-sin-tablas.png)

### Articulo Tercero

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

Los items (a), (b) y (c) hacen referencia, respectivamente, a los atributos minimos que deberan tener las Empresas, los Puntos de Venta y los Productos, respectivamente. Los items (d) y (e) hacen referencia a la informacion que debe ser suministrada diariamente en el Parte de Precio. Si intentamos representar la informacion requerida en (d) y (e) como atributos de una unica entidad, Parte de Precio, obtenemos el siguiente modelo:

![Fig. 2: DER basico con atributos](img/erd-con-tablas-ingenuo-promo.png)

El `precio_promocional` es sin duda insuficiente para contener toda la gama de esquemas de incentivos que ofrecen los autoservicios y supermercados, se necesita al menos una `descripcion_promocion` para consignar las bases y condiciones del descuento. Esto nos lleva a pensar que tal vez sea util separar en su propia identidad a las _"promociones, descuentos y todo tipo de bonificaciones"_ (en adelante, **Promociones**). Ademas, que sucede si dos o mas Promociones aplican sobre un mismo Parte de Precio? 


Aqui hay aun dos posibles problemas con el tratamiento dado a las promociones:
1. Puede haber mas de una promocion vigente para cierto producto, punto de venta y fecha.
2. Una **Promocion** puede ser considerada una entidad en si misma, en lugar de informacion relativa a un Parte de Precio.

Considerar las Promociones como entidades separadas nos permite reutilizarlas en distintos partes, tanto a traves del tiempo como para diferentes productos. Por ello, tiene sentido escindirlas de los Partes. Por otra parte, tener una tabla separada registrando las relaciones entre Promociones y Partes de Precio sobre los que aplican pareciera ser demasiada complejidad. Una solucion de compromiso, estimando que los casos en que tres o mas Promociones aplican a un mismo Parte son negligibles, es agregar al Parte campos para informar, de ser necesario, sobre una segunda promocion.

Existen muchos tipos de promociones, pero la enorme mayoria tiene la forma "X% de descuento [en la enesima unidad]" o "lleve N pague M". Ambos tipos de promociones ofrecen un descuento proporcional al precio unitario, y requieren un minimo de unidades para ser efectivas.

![Fig. 3: DER con Promociones](img/erd-con-promociones.png)

Hasta aqui, hemos cubierto los atributos minimos para almacenar la informacion provista por las Empresas. Sin embargo, seria interesante incluir algunos atributos mas, particularmente sobre los Puntos de Venta y Productos, para ofrecer metricas e indicadores mejor segmentados. 

Con respecto a los Puntos de Venta, un primer atributo seria su "categoria", que se puede extraer del articulo cuarto, que menciona entre los afectados por la Resolucion a _"almacenes, mercados, autoservicios, supermercados e hipermercados"_. Otros atributos geograficos, como Provincia y Ciudad tambien serian interesantes, pero se puede, tecnicamente, derivarlos de campos ya incluidos.

Con respecto a los Productos, tambien seria util implementar una categorizacion jerarquica sencilla. Esta deberia figurar en la reglamentacion de la Resolucion 12/2016, donde se detallaran los productos implicados, pero no logro encontrar en Internet. En su lugar, supondremos un clasificacion simple, con una categoria mayor, una menor y finalmente un producto generico (e.g.: "Bebidas, Bebidas Gaseosas, Gaseosa Cola", "Fiambres, Jamon Crudo, Jamon Crudo", "Higiene Personal, Desodorantes, Desodorante en aerosol", et cetera)

Ademas de esta jerarquia vertical, se pueden incluir atributos como "Marca", para facilitar la busqueda de productos al consumidor, y "Presentacion", para especificar mas alla de la descripcion el peso/volumen/cantidad del producto y facilitar comparaciones entre distintas presentaciones.

![Fig. 4: DER con atributos extra para segmentacion](img/der-con-atributos-extra.png) 

**NOTA**: el articulo quinto menciona que _"se pondrá a disposición de los consumidores una plataforma informática [...] a través de la cual los consumidores podrán [...] comunicar las eventuales inconsistencias ..."_. Integrar dicho sistema a este modelo requeriria al menos una nueva entidad, el Reporte de Inconsistencia, que hace referencia a un cierto Parte de Precio, y provee informacion al respecto. Entiendo que se encuentra fuera del alcance de este ejercicio exponer dicha implementacion.

## Indicadores Calculables

Que objetivos persigue uno al crear el SEPA?

