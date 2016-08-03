
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

![Fig. 5: DER completo. Los atributos por debajo de la linea son aquellos no exigidos por la Resolucion pero utiles para el analisis.](img/der-completo.png)

## Indicadores Calculables

Que objetivos se persiguen al crear el SEPA? Sin animo de ser exhaustivos, podemos mencionar:

1. Recopilar informacion detallada de la evolucion de precios en articulos de consumo masivo,
2. Promover la transparencia y responsabilidad en la decision de precios de los mayores actores del sector,
3. Empoderar al ciudadano con herramientas de comparacion de precios entre puntos de venta,
4. Resaltar a aquellas Empresas que mantengan sus aumentos de precios por debajo de la media, y

Del universo de indicadores posibles para estos objetivos, a continuacion presentaremos uno por cada uno. Pese a que los indicadores que involucran precios utilizan por default los precios de lista, todos se pueden aplicar a los precios promocionales con minimos cambios.

### Efectiva provision de la informacion

Una necesidad fundamental para el buen funcionamiento del sistema es la **recepcion permanente de la informacion** actualizada que mencionamos en el objetivo (1). Como podemos asegurarnos de que las Empresas esten proveyendo _toda_ la informacion que deben? Es imposible automatizar completamente esta tarea, pero podemos crear indicadores de posible incumplimiento, que indiquen cuando un Punto de Venta (o similarmente, una Empresa) esten registrando menos Partes por dia de lo esperado. Sean

> - `promRec(puntoDeVenta, nDias)`: La cantidad media de Partes de Precio registrados para cierto `puntoDeVenta` en los ultimos `nDias` dias por la Empresa que lo gerencia,
> - `promHist(puntoDeVenta)`: La cantidad media historica de Partes de Precio registrados por dia para `puntoDeVenta` por la Empresa que lo gerencia,

Luego, cuando la razon `promRec / promHist` caiga por debajo de cierto `umbralSospecha`, se marcara al Punto de Venta en cuestion para analisis manual de la evidencia. En seudocodigo,

```ruby
sospechaInfoFaltante(puntoDeVenta, nDias = 7, umbralSospecha = 0.7)
  razonObservada = promRec(puntoDeVenta, nDias) / promHist(puntoDeVenta)
  if razonObservada < umbralSospecha
    return True
  else
    return False
  end
end
```

Vale aclarar que tanto para este indicador como para los siguientes, el valor por default dado a los parametros fijos (`nDias` y `umbralSospecha`) deben ser ajustados a la data, aqui solo se ofrecen estimaciones razonables _a priori_.

Para agilizar la consulta considerablemente a cambio de cierta perdida de flexibilidad, se puede comparar el resultado de `promRec()` contra una cantidad tabulada de antemano del numero de Productos que se espera que cada Punto De Venta reporte a diario. Esto elimina la necesidad de calcular `promHist()`.

Una tercera alternatica, consiste en comparar `promRec()` a la fecha contra la distribucion ordenada de valores historicos de `promRec()`, y considerar sospechoso el valor actual en caso de que se encuentre por debajo del `umbralPercentil` establecido (= 1 o 5).

### Veracidad de la informacion prevista

No solo es necesario que las Empresas sujetas por la Resolucion _proporcionen informacion_ al SEPA, sino que ademas esta debe ser **confiable y veraz**: de nada sirve que se reporten precios diferentes a los que efectivamente enfrenta el consumidor.

El recuento de Partes de Precio producido (en los ultimos `nDias` dias) por particulares para cada Empresa y/o Punto de Venta nos permite generar un simple ranking de potenciales infractores: mientras mas alto el numero de discrepancias, menos probable es que estas sean accidentales.

Para evitar dobles conteos, debemos considerar no el numero total de Partes particulares, sino el numero de Productos _unicos_ sobre los que se han provisto Partes particulares en el periodo relevante. Ademas, considerando que de estar proveyendo deliberadamente informacion incorrecta es la Empresa quien enfrentara acciones legales y no el Punto de Venta, el nivel de agregacion ideal para esta metrica es la Empresa. Bajo estas condiciones, podemos definir la cantidad de Precios Mal Informados por Empresa como:

> `preciosEquivocados(empresa, nDias = 7)`: Cantidad de Productos _Unicos_ mencionados en los Partes de Precios registrados por "particulares" en cualquiera de los Puntos de Venta que pertenecen a `empresa` en los ultimos `nDias` dias.

Ordenando a las Empresas por el numero de `preciosEquivocados()` de mayor a menor, obtenemos un orden de prioridad razonable para detectar posible dolo en la inputacion de precios.

_NOTA: Este indicador supone que si un ciudadano registra un Parte de Precio, es unicamente porque el precio que observa no coincide con el registrado en el Sistema. De poder registrar Partes por otras razones, debemos agregar la condicion de los Partes de particulares a considerar sean solo aquellos donde el precio que menciona la Empresa difiera del que constata el Particular. Otras sofisticaciones posibles incluyen la ponderacion de cada inconsistencia en funcion de la razon entre precio registrado y precio observado._

### Comparacion entre Puntos de Venta

A pesar de la a veces masiva oferta de Puntos de Venta, los consumidores rara vez saben con certeza _donde_ les conviene realizar sus compras: tal vez los lacteos son mas baratos en un lugar, los articulos de limpieza en un segundo, y la comida para gatos en un tercero. Sin embargo, realizar una ruta optima en todos los precios probablemente sea suboptimo al considerar el tiempo involucrado. En general, lo que un consumidor buscara es aquel negocio que, _en promedio_, tenga los mejores precios para un conjunto de articulos, y acudira unicamente a el. El objetivo ahora es proveer una medida de **competitividad en los precios** de cada Punto de Venta. 

Para empezar, podemos contar que proporcion de los Productos ofrecidos cierta fecha en un Punto de Venta tienen el precio minimo registrado para dicho Producto y Fecha entre todos los Puntos de Venta (de la zona/region). Si imaginamos un comercio donde _todos_ los productos se venden _solamente_ un centavo por encima del precio minimo, veremos que este primer indicador falla: la proporcion de precios minimos sera exactamente cero, cuando es harto probable que un comercio asi sea altamente competitivo en precios.

Una forma de "emparchar" este indicador, seria calculando la razon entre la suma de todos los precios informados por Punto de Venta (o PdV), contra la suma de los precios minimos registrados para esos mismos Productos a la fecha en cuestion. Esta version es mas robusta a pequenas diferencias entre el precio ofrecido por un PdV y el minimo a la fecha.

Aun asi, sigue siendo un tanto arbitrario: por que deberian entrar en el recuento *todos* los productos ofrecidos, independientemente de su frecuencia de ventas? Si deseamos ofrecer un indicador verdaderamente util de competitividad en precios, debemos inevitablemente introducir el concepto de **Canastas** representativas.

Dada una canasta en particular, con ciertos productos y cantidad de unidades de cada uno, perdemos generalidad (ya no se considera _toda_ la oferta de un PdV), pero ganamos considerablemente en utilidad al Consumidor Final.

El consumidor altamente motivado puede estar dispuesto a detallar su propia canasta de compras, y utilizar el SEPA para comparar su valor entre varios PdV. Sin embargo, es de esperar que la mayoria de los usuarios particulares del SEPA prefieran, mas sencillamente, ser informados sobre que Puntos de Venta tienen el mejor precio para ciertas Canastas Representativas y acudan a ellos: pierden en minimizacion de costes, pero ganan en tiempo destinado a ello.

Es imposible construir una unica Canasta Representativa: la composicion del nucleo familiar, sus habitos alimenticios y hasta la propension a cocinar en casa determinan Canastas bastante disimiles. Lo ideal, en su lugar, seria confeccionar "puertas adentro" una **serie de Canastas Representativas** breve ("Pareja joven, sin hijos, vegetarianos", "Adulto con un hijo a cargo", "Asado para 10 personas"), y que cada una de ellas sea su propio indicador de competitividad, entre los cuales el Consumidor elegira de acuerdo a sus propositos.

#### Diagrama ER de Canastas

La entidad Canasta definitivamente no es parte del modelo ER esencial para _almacenar_ la informacion del SEPA. Si es, por otra parte, una abstraccion clave para _representar_ la informacion recopilada. Si consideramos que una Canasta es simplemente un conjunto de pares (producto, cantidad), obtenemos:

![Fig. 6: DER para Canastas y su union con Productos a traves de Componentes Canastas](img/der-canastas.png)

#### Clasificador de Puntos de Venta

Con el modelo sugerido, podemos calcular el precio de cualquier canasta en tantos locales como se desee. En caso de que este servicio se le ofrezca al Consumidor, los PdV habran de restringirse a un numero manejable tanto para la consulta como para la visualizacion. Para generar el indicador de competitividad en precios que mencionamos antes, habremos de calcular el valor a la fecha de determinada Canasta de referencia en _todos_ los locales.

Que Canasta sera adecuada para dicha tarea? Ninguna sera perfecta, pero podemos aprovechar el trabajo de los que mas saben, y utilizar a tal fin la composicion de la division "Alimentos y Bebidas, Alimentos para consumir en el Hogar" del Indice de Precios al Consumidor que publica el INDEC: los productos que el SEPA rastrea coinciden fuertemente con dicho componente del IPC. Tristemente, en la ultima Metodologia publicada, el Anexo titulado "Canasta Basica Alimentaria" tiene un texto de relleno estilo Lorem Ipsum. 

Asumiendo que tenemos tal canasta representativa, `canastaRep`, y una funcion `precioCanasta(canasta,fecha,puntoDeVenta)` que calcula la suma de los precios a cierta de los productos y cantidades incluidos en `canasta` en venta en `puntoDeVenta`, nuestra medida de competitividad es

> `precioCanastaRepresentativa(puntoDeVenta) = precioCanasta(canastaRep, "Hoy", puntoDeVenta)`

Es de esperar que algunos PdV no comercializen todos los Productos de la Canasta representativa: para evitar que los comercios con menor surtido dominen el ranking, debemos asegurarnos de asignarle un precio "por default" a todo producto que un PdV no distribuye.

Si se quiere transformar este precio en un indicador mas tradicional, se puede tomar como base el precio minimo obtenido para la Canasta representativa, asignarle un valor de 100 y ajustar a esta nueva escala el resto de los precios obtenidos.

### Variaciones intertemporales de precios

En el apartado anterior comparamos los precios en distintos Puntos de Venta entre si, para un cierto instante. Otra forma esclarecedora de comparar precios de canastas, es intertemporalmente, en un mismo PdV o Empresa: esto nos dara una idea razonable del compromiso de una Empresa a mantener la suba de precios a un minimo. Como siempre, la eleccion de la canasta de productos a comparar es clave para evitar abusos del indicador (donde una Empresa sube todos sus precios salvo los incluidos en la Canasta utilizada), y que este sea una verdadera senial de confianza.

Hay muchas formas de medir variaciones intertemporales de indicadores de negocios, como del primero del mes/anio a al fecha (MTD/YTD), o 30/365 dias atras a la fecha. El INDEC utiliza un indicador mas robusto, donde la variacion de precios mensual se calcula comparando los promedios de precios de _todos los dias del mes_. Cualquiera de estas opciones puede ser valida. Tomemos para este indicador la variacion del primero del anio a la fecha, o _year-to-date_.

En este caso, en lugar de calcular la variacion por Punto de Venta, lo haremos a promediando a nivel Empresa las variaciones en cada uno de sus PdV. Buscamos un indicador de "buena fe" en la formacion de precios por parte de las Empresas, y no de sus locales particulares. Reutilizando la funcion `precioCanasta()` y la Canasta `canastaRep` anteriormente descrita, construimos

- `precioCanastaEmpresa(canasta, fecha, empresa)` = Promedio de precioCanasta(canasta, fecha, puntoDeVenta) para todos los Puntos de Venta de `empresa`

Finalmente, el indicador que buscamos se obtiene como

> `variacionAnioALaFecha(empresa, canastaRep) = ( precioCanastaEmpresa(canastaRep, "Hoy", empresa) / precioCanastaEmpresa(canastaRep, "Primero del Anio", empresa) - 1 ) * 100`


### Otros indicadores posibles

#### Deteccion de situaciones hiperinflacionarias

Una tipica anecdota de las epocas hiperinflacionarias en Argentina cuenta que no solo se solia pagar diariamente a los empleados, sino que hasta se llegaba a agregar un descanso en medio de la jornada explicitamente para ir de compras, antes de que los precios volviesen a subir. Es decir que una caracteristica tipica de la hiperinflacion es el aumento casi diario de precios. En la Resolucion 12/2016, se exige que las Empresas reporten cualquier durante el transcurso del dia al precio declarado la jornada anterior. Es de esperar que la correccion de errores accidentales, pero ni bien la tasa de Partes de Precio actualizada en el dia de vigencia sobre el total supera este "ruido de fondo", hemos de empezar a sospechar una acelerada inflacionaria.

Aunque muy sencillo de calcular y llamativo a primera vista, un problema obvio de este indicador es que de estar verdaderamente en una hiperinflacion, la adecuada provision de informacion al SEPA por parte de las Empresas seguro se deteriorara fuertemente. Cabe averiguar, tal vez, si tal metrica sera util como indicador _temprano_ de hiperinflacion, al estilo en que las consultas sobre gripe en Google tienen (un poquito de) poder predictivo sobre la cantidad posterior de enfermos registrados. 

#### Evolucion de los valores promocionales

Por el efecto de _framing_, la forma de presentar informacion es determinante en su percepcion. Por ello, a veces puede ser preferible vender un producto de $70 a "$100 con **30%** de descuento!". Algunas Empresas tienen programas de fidelizacion o facilidades de pago que hacen uso pesado pero etico de los descuentos. En otros casos, podemos estar frente a ardides de mercadeo como el mencionado.

No es facil diferenciar entre ambos casos, pero si tomamos el promedio de los descuentos ofrecidos por Empresa en todos sus productos a una fecha determinada, tenemos una buena medida de la injerencia de las Promociones en las politicas de marketing de la firma. Luego, como siempre, sera necesario revisar manualmente los casos mas destacados para distnguir entre practicas leales y desleales.

### Recursos Consultados

[Secretaria de Comercio, Resolucion 12/2016, Sistema Electronico de Publicidad de Precios Argentinos](https://www.boletinoficial.gob.ar/pdf/linkQR/aUhvb3k0ZmlGKzVycmZ0RFhoUThyQT09)
[Que es el IPC?](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_que_es_06_16.pdf)
[Metodologia IPC Abril 2016](http://www.indec.gov.ar/ftp/cuadros/economia/ipc_metodologia_abril2016.pdf)
