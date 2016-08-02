
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

### Articulos Segundo y Tercero

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

Los items del Art. III (a), (b) y (c) hacen referencia, respectivamente, a los atributos minimos que deberan tener las Empresas, los Puntos de Venta y los Productos, respectivamente. Los items (d) y (e) hacen referencia a la informacion que debe ser suministrada diariamente en el Parte de Precio. 

El Articulo Segundo, menciona que 
> _"El suministro de la información [...] deberá realizarse [...] en forma previa y hasta las CERO HORAS (0:00 hs.) del día en que se pondrán en vigencia los precios de los productos [...]. Asimismo, deberá informarse por tal medio, en forma inmediata, cualquier alteración en el precio que se produzca en el transcurso del día."_

Es decir que un Parte provisto en este instante, puede consistir en una modificacion al precio de hoy declarado ayer, o una entrega a tiempo del precio de maniana. Esto amerita que el Parte de Precio guarde explicitamente fecha y hora de creacion y modificacion, ademas de la fecha de vigencia.

![Fig. 2: DER basico con atributos](img/erd-sin-promo.png)

El `precio_promocional` es sin duda insuficiente para contener toda la gama de esquemas de incentivos que ofrecen los autoservicios y supermercados, se necesita al menos una `descripcion_promocion` para consignar las bases y condiciones del descuento. Esto nos lleva a pensar que tal vez sea util separar en su propia identidad a las _"promociones, descuentos y todo tipo de bonificaciones"_ (en adelante, **Promociones**).

Existen muchos tipos de Promociones, pero la enorme mayoria tiene una de las dos formas:
- _"X% de descuento en [toda|la enesima] unidad"_,
- _"Lleve N, y pague solo M"_.

Ambos tipos de promociones ofrecen un descuento proporcional al precio unitario, y requieren un minimo de unidades para ser efectivas. Por lo tanto, una entidad Promocion basica se veria asi:

![Fig. 3: Modelo Promocion](img/promocion.svg)

Como se relacionan Promociones y Partes de Precio? A ojo de buen cubero, podemos estimar que un Producto en un Punto de Venta y Fecha al azar tendra:
- muy probablemente (~ 9:10), ninguna o una promocion vigente en el Parte correspondiente,
- poco probablemente (~ 1:20), dos promociones vigentes, y
- practicamente nunca (~ 1:500) se le apliquen tres o mas Promociones.

Esta estimacion se debe comprobar empiricamente, pero de ser correcta, nos hace pensar que normalizar la relacion entre Promociones y Partes en su propia tabla puede ser excesivo. Una solucion de compromiso, seria incluir en el Parte dos claves foraneas para hacer referencia a hasta dos Promociones. Conservaremos tambien en el Parte, a fines practicos, cada precio promocional.

![Fig. 3: DER con Promociones](img/erd-con-promo.png)

### Atributos de segmentacion

Hasta aqui, hemos cubierto los atributos minimos para almacenar la informacion provista por las Empresas. Algunos atributos pueden se han mantenido genericos para simplificar la provision de informacion, como `puntos_de_venta.direccion` o `productos.descripcion`. Sin embargo, a fines de comprender mejor el corpus de datos, seria util incluir algunos atributos que sean relevantes para segmentarlo. 

Con respecto a los **Puntos de Venta**, un primer atributo seria su "categoria", que se puede extraer del articulo cuarto, que menciona entre los afectados por la Resolucion a _"almacenes, mercados, autoservicios, supermercados e hipermercados"_. Esta es una distincion relevante entre Puntos de Venta de cadenas como Carrefour/Carrefour Express y Walmart/Changomas. Otros atributos geograficos, como Provincia, Localidad y Ciudad se pueden derivar de Direccion.

Con respecto a los **Productos**, resultara ilustrativo implementar una categorizacion jerarquica sencilla. Esta probablemente figure en la reglamentacion de la Resolucion 12/2016, donde se detallaran los productos implicados, pero no logro encontrarla en Internet. En su lugar, supondre un clasificacion simple, con una categoria mayor, una menor y finalmente un producto generico (e.g.: "Bebidas, Bebidas Gaseosas, Gaseosa Cola", "Fiambres, Jamon Crudo, Jamon Crudo", "Higiene Personal, Desodorantes, Desodorante en aerosol", et cetera).

El Articulo 3 inc. d habla de informar precios _"por unidad, peso o medida de producto"_. Esta informacion puede estar incluida ya en la descripcion del Producto, pero si suponemos que la intencion es proveer una forma de comparar entre distintas presentaciones, debemos agregar al menos un campo mas para consignar dicha informacion por separado.

Ademas de esta jerarquia vertical, otros dos atributos interesantes en tanto identifican actores fijadores de precios, serian "Productor" y "Marca".

![Fig. 4: DER con atributos extra para segmentacion](img/der-con-atributos-extra.png) 

### Articulo Quinto

Los primeros cuatro articulos lidian con _quienes_ deben proveer _que_ informacion sobre _cuales_ productos. Los articulos del sexto al decimo describen detalles de implementacion juridica. El articulo quinto es el unico que hace referencia a un uso concreto del SEPA, cuando menciona que 

> _"se pondrá a disposición de los consumidores una plataforma informática [...] a través de la cual los consumidores podrán acceder a la informacion brindada y **comunicar las eventuales inconsistencias** ..."_

Un sistema de consulta de la informacion se puede implementar completamente por separado de este. Sin embargo, si se lo pretende util, un sistema publico de comunicacion de inconsistencias debe estar integrado con este modelo de datos.

"En produccion", esta integracion probablemente requiera varias Entidades auxiliares para guardar informacion sobre los Consumidores y la denuncia efectuada (e.g.: correo electronico, evidencia fotografica). Creo que dicha integracion esta fuera del alcance de este ejercicio. Sin embargo, para producir indicadores de confianza sobre las empresas, contar entre los Partes de Precio de aquellos generados por los Consumidores seria sumamente interesante.

Para unir en una sola tabla los Partes generados tanto por Empresas como por Consumidores, debemos incluir un campo con el Tipo de Autor, sea este "empresa" o "particular".

### Diagrama Entidad Relacion final

Uniendo todas las observaciones de esta seccion, obtenemos nuestro ansiado DER:


## Indicadores Calculables

Que objetivos persigue uno al crear el SEPA?

