# Análisis de la Resolución 12/2016

## Artículo Primero

> Artículo 1° — Créase en el ámbito de la SECRETARÍA DE COMERCIO del MINISTERIO DE
PRODUCCIÓN el “Sistema Electrónico de Publicidad de Precios Argentinos (SEPA)”, a través del cual
todos los comercios que realicen venta minorista de productos de consumo masivo, deberán informar en
forma diaria para su difusión los precios de venta al público vigentes en cada punto de venta, de los
productos que se determinen en la reglamentación

Aquí podemos identificar tres entidades: el **Comercio**, el **Punto de Venta** y el **Producto**. Para evitar ambigüedades semánticas entre Comercio y Punto de Venta y apegarnos al vocabulario de la Resolución, reemplazaremos Comercio por **Empresa**, que figura en el Art. 3 ítem (a).

Diariamente, la Empresa debera proveer un parte de precios, detallando la totalidad de los precios que presenta en cada Punto de Venta y Producto. Dado que los principales sujetos de esta Resolución (Coto, Día, Carrefour, et al) manejan cientos de tiendas y miles de productos, es evidente que la interfaz que utilicen debera permitir especificar muchos precios con una sola operacion.

Sin embargo, en la base de datos, la información provista deberá almacenarse atómicamente, idealmente con un registro por Producto y Punto de Venta. Nuestra cuarta entidad será el **Parte de Precio**, que refleja los precios (de lista y promociónal) de un determinado Producto, en cierto Punto de Venta, para determinada fecha.

Con estas entidades creamos un primer DER. Las relaciones deben leerse comenzando por la entidad única en cada una (e.g.: Empresa _posee_ Puntos de Venta):

![Fig. 1: DER basico](../img/der-sin-tablas.png)

## Artículos Segundo y Tercero

> Art. 3° — La información suministrada será difundida y de público acceso para el consumidor y deberá
contener, para cada producto y por cada punto de venta, como mínimo los siguientes datos:
a) CUIT de la empresa, razón social y nombre o denominación comercial;
b) Ubicación de cada punto de venta, con domicilio completo y coordenadas para que permita su
geolocalización;
c) Código EAN o equivalente sectorial del producto;
d) Precio de lista de venta minorista final al público por unidad, peso o medida de producto, según la
forma de comercialización; y
e) Promociones, descuentos y todo tipo de bonificaciones.

Los ítems del Art. III (a), (b) y (c) hacen referencia, respectivamente, a los atributos mínimos que deberán tener las Empresas, los Puntos de Venta y los Productos, respectivamente. Los ítems (d) y (e) hacen referencia a la información que debe ser suministrada diariamente en el Parte de Precio.

El Artículo Segundo menciona que 
> _"El suministro de la información [...] deberá realizarse [...] en forma previa y hasta las CERO HORAS (0:00 hs.) del día en que se pondrán en vigencia los precios de los productos [...]. Asimismo, deberá informarse por tal medio, en forma inmediata, cualquier alteración en el precio que se produzca en el transcurso del día."_

Es decir que un Parte provisto en este instante, puede consistir en una modificación al precio de hoy declarado ayer, o una entrega a tiempo del precio de mañana. Esto amerita que el Parte de Precio guarde explícitamente fecha y hora de creación y modificación, además de su fecha de vigencia.

![Fig. 2: DER basico con atributos](../img/der-sin-promo.png)

El `precio_promociónal` es sin duda insuficiente para contener toda la gama de esquemas de incentivos que ofrecen los autoservicios y supermercados: se necesita al menos una `descripcion_promoción` para consignar bases y condiciones. Esto nos lleva a pensar que tal vez sea útil separar en su propia identidad a las _"promociones, descuentos y todo tipo de bonificaciones"_ (en adelante, **Promociones**).

Existen muchos tipos de Promociones, pero la enorme mayoría tiene una de las dos formas:
- "X% de descuento en [toda|la enésima] unidad",
- "Lleve N, y pague sólo M".

Ambos tipos de promociones ofrecen un descuento proporcional al precio unitario, y requieren un mínimo de unidades para ser efectivas. Por lo tanto, una entidad Promoción básica se vería así:

![Fig. 3: Modelo Promoción](../img/promoción.png)

Cómo se relacionan Promociones y Partes de Precio? A ojo de buen cubero, podemos estimar que un Producto en un Punto de Venta y Fecha al azar tendrá:
- muy probablemente (~ 9:10), ninguna o una promoción vigente en el Parte correspondiente,
- poco probablemente (~ 1:20), dos promociones vigentes, y
- prácticamente nunca (~ 1:500) se le apliquen tres o más Promociones.

Esta estimación se debe comprobar empíricamente, pero de ser correcta, nos hace pensar que normalizar la relación entre Promociones y Partes en su propia tabla puede ser excesivo. Una solucion de compromiso, sería incluir en el Parte dos claves foráneas para hacer referencia a hasta dos Promociones. Conservaremos también en el Parte, a fines prácticos, cada precio promociónal.

![Fig. 3: DER con Promociones](../img/der-con-promo.png)

## Otras Consideraciones

Hasta aquí, hemos cubierto las entidades y atributos mínimos para almacenar la información provista por las Empresas (o sus representantes). A esto le llamaremos "DER Mínimo". Las consideraciones siguientes lo ampliarán hasta un "DER Extendido", agregando algunos atributos útiles para el análisis. Más adelante, en la exploración de indicadores haremos algunas últimas observaciones para alcanzar el "DER Completo".

### Atributos de segmentacion

A fines de comprender mejor el corpus de datos, será útil incluir algunos atributos relevantes para segmentarlo: 

Con respecto a los **Puntos de Venta**, un primer atributo sería su `categoría`, que se puede extraer del Artículo Cuarto, que menciona entre los afectados por la Resolución a _"almacenes, mercados, autoservicios, supermercados e hipermercados"_. Otros atributos geográficos, como `provincia` y `localidad` y se pueden derivar de `direccion`.

Con respecto a los **Productos**, resultará ilustrativo implementar una categorización jerárquica sencilla. Ésta probablemente figure en la reglamentacion de la Resolucion 12/2016, donde se detallaran los productos implicados, pero no logro encontrarla en Internet. En su lugar, supondré un clasificación simple, con `categoria`, `subcategoria` y `nombre_generico` (e.g.: "Bebidas, Bebidas Gaseosas, Gaseosa Cola", "Fiambres, Jamón Crudo, Jamón Crudo", "Higiene Personal, Desodorantes, Desodorante en aerosol", et cetera).

El Artículo III (d) habla de informar precios _"por unidad, peso o medida de producto"_. Esta información puede estar incluida ya en la descripcion del Producto, pero si suponemos que la intención es proveer una forma de comparar entre distintas presentaciones, debemos agregar un campo `presentacion` para consignar dicha información por separado.

Otros dos atributos interesantes a desglosar de la descripción, en tanto identifican actores fijadores de precios, son `productor` y `marca`.

### Artículo Quinto

El Art. V es el único que hace referencia a un uso concreto del SEPA, cuando menciona que 

> _"se pondrá a disposición de los consumidores una plataforma informática [...] a través de la cual los consumidores podrán acceder a la información brindada y **comunicar las eventuales inconsistencias** ..."_

Un sistema de consulta de la información se puede implementar completamente por separado de este. Sin embargo, si se lo pretende útil para evaluar la veracidad de las declaraciones empresariales. debe estar integrado con este modelo de datos.

"En producción", esta integración requiere varias Entidades auxiliares para guardar información sobre los Consumidores y la denuncia efectuada (e.g.: correo electrónico, evidencia fotográfica). Creo que dicha integracion esta fuera del alcance de este ejercicio, y no la incluiremos en el DER.

Sin embargo, suponiendo que contamos con una tabla con los mismos campos de Partes de Precio, donde se registran los Partes generados por los Consumidores (que sí permita mas de un Parte por día y Punto de Venta), podemos ofrecer indicadores de veracidad de los datos.

Uniendo todas las observaciones de esta seccion, obtenemos este "DER Extendido":

![Fig. 5: DER completo. Los atributos por debajo de la linea son aquellos no exigidos por la Resolucion pero utiles para el analisis.](../img/der-con-atributos-extra.png)
