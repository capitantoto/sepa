# Indicadores Posibles

Qué objetivos se persiguen al crear el SEPA? Sin ánimo de ser exhaustivos, podemos imaginar:

1. Recopilar información detallada de la evolución de precios en artículos de consumo masivo,
2. Promover la transparencia y responsabilidad en la decisión de precios de los mayores actores del sector,
3. Empoderar al ciudadano con herramientas de comparación de precios entre puntos de venta, y
4. Destacar a aquellas Empresas que mantengan sus aumentos de precios por debajo de la media.

Del universo de indicadores posibles para estos objetivos, a continuación presentaremos uno por cada uno. 

Pese a que los indicadores que involucran precios se describen utilizando los precios de lista, todos se pueden aplicar a los precios promocionales con mínimos cambios.

## 1. Efectiva provisión de la información

Una necesidad fundamental para el buen funcionamiento del sistema es la **recepción permanente de información** actualizada. Cómo podemos asegurarnos de que las Empresas estén proveyendo _toda_ la información que deben? Es imposible automatizar completamente esta tarea, pero si tenemos una "cantidad esperada de Partes" de referencia, podemos crear indicadores de incumplimiento, cuando un Punto de Venta/Empresa esté registrando menos Partes por día de lo esperado. Sean

> - `promRec(empresa, nDias)`: La cantidad media de Partes de Precio registrados por cierta `empresa` en los ultimos `nDias` dias.
> - `promHist(empresa)`: La cantidad media historica de Partes de Precio registrados por la Empresa `empresa`

Luego, cuando la razón `promRec / promHist` caiga por debajo de cierto `umbralSospecha`, se marcará la empresa en cuestión para análisis manual de la evidencia. En seudocódigo,

```ruby
sospechaInfoFaltante(empresa, nDias = 7, umbralSospecha = 0.7)
  razonObservada = promRec(empresa, nDias) / promHist(empresa)
  if razonObservada < umbralSospecha
    return True
  else
    return False
  end
end
```

Vale aclarar que tanto para este indicador como para los siguientes, el valor por default dado a los parámetros fijos (`nDias` y `umbralSospecha`) deben ser ajustados a la data, aquí solo se ofrecen estimaciones razonables _a priori_.

Para agilizar la consulta considerablemente a cambio de cierta perdida de flexibilidad, se puede comparar el resultado de `promRec()` contra una cantidad tabulada de antemano del numero de Partes que se espera que cada Empresa reporte a diario, eliminando la necesidad de calcular `promHist()`.

Una tercera alternatica, consiste en comparar `promRec()` a la fecha contra la distribucion ordenada de valores historicos de `promRec()` para saber en qué percentil se encuentra, y considerar sospechoso el valor actual en caso de que se encuentre por debajo de un `umbralPercentil` establecido, como 1 ó 5.

## 2. Veracidad de la información prevista

No solo es necesario que las Empresas sujetas por la Resolucion _proporcionen informacion_ al SEPA, sino que ademas esta debe ser **confiable y veraz**: de nada sirve que se reporten precios diferentes a los que efectivamente enfrenta el consumidor.

El recuento de Partes de Precio producido (en los ultimos `nDias` dias) por particulares para cada Empresa y/o Punto de Venta nos permite generar un simple ranking de potenciales infractores: mientras mas alto el numero de discrepancias, menos probable es que estas sean accidentales.

Para evitar dobles conteos, debemos considerar no el numero total de Partes particulares, sino el numero de Productos _unicos_ sobre los que se han provisto Partes particulares en el periodo relevante. Ademas, considerando que de estar proveyendo deliberadamente informacion incorrecta es la Empresa quien enfrentara acciones legales y no el Punto de Venta, el nivel de agregacion ideal para esta metrica es la Empresa. Bajo estas condiciones, podemos definir la cantidad de Precios Mal Informados por Empresa como:

> `preciosEquivocados(empresa, nDias = 7)`: Cantidad de Productos _Unicos_ mencionados en los Partes de Precios registrados por "particulares" en cualquiera de los Puntos de Venta que pertenecen a `empresa` en los ultimos `nDias` dias.

Ordenando a las Empresas por el numero de `preciosEquivocados()` de mayor a menor, obtenemos un orden de prioridad razonable para detectar posible dolo en la inputacion de precios.

_**NOTA**: Este indicador supone que
- (a) efectivamente contamos con una tabla muy similar a Partes de Precio para recopilar informacion ciudadana, y
- (b) si un ciudadano registra un Parte de Precio, es unicamente porque el precio que observa no coincide con el registrado en el Sistema.
De poder registrar Partes por otras razones, debemos agregar la condicion de los Partes de particulares a considerar sean solo aquellos donde el precio que menciona la Empresa difiera del que constata el Particular. Otras sofisticaciones posibles incluyen la ponderacion de cada inconsistencia en funcion de la razon entre precio registrado y precio observado._

## 3. Comparacion entre Puntos de Venta

A pesar de la a veces masiva oferta de Puntos de Venta, los consumidores rara vez saben con certeza _donde_ les conviene realizar sus compras: tal vez los lacteos son mas baratos en un lugar, los articulos de limpieza en un segundo, y la comida para gatos en un tercero. Sin embargo, realizar una ruta optima en todos los precios probablemente sea suboptimo al considerar el tiempo involucrado. En general, lo que un consumidor buscara es aquel negocio que, _en promedio_, tenga los mejores precios para un conjunto de articulos, y acudira unicamente a el. El objetivo ahora es proveer una medida de **competitividad en los precios** de cada Punto de Venta. 

Para empezar, podemos contar que proporcion de los Productos ofrecidos cierta fecha en un Punto de Venta tienen el precio minimo registrado para dicho Producto y Fecha entre todos los Puntos de Venta (de la zona/region). Si imaginamos un comercio donde _todos_ los productos se venden _solamente_ un centavo por encima del precio minimo, veremos que este primer indicador falla: la proporcion de precios minimos sera exactamente cero, cuando es harto probable que un comercio asi sea altamente competitivo en precios.

Una forma de "emparchar" este indicador, seria calculando la razon entre la suma de todos los precios informados por Punto de Venta (o PdV), contra la suma de los precios minimos registrados para esos mismos Productos a la fecha en cuestion. Esta version es mas robusta a pequenas diferencias entre el precio ofrecido por un PdV y el minimo a la fecha.

Aun asi, sigue siendo un tanto arbitrario: por que deberian entrar en el recuento *todos* los productos ofrecidos, independientemente de su frecuencia de ventas? Si deseamos ofrecer un indicador verdaderamente util de competitividad en precios, debemos inevitablemente introducir el concepto de **Canastas** representativas.

Dada una canasta en particular, con ciertos productos y cantidad de unidades de cada uno, perdemos generalidad (ya no se considera _toda_ la oferta de un PdV), pero ganamos considerablemente en utilidad al Consumidor Final.

El consumidor altamente motivado puede estar dispuesto a detallar su propia canasta de compras, y utilizar el SEPA para comparar su valor entre varios PdV. Sin embargo, es de esperar que la mayoria de los usuarios particulares del SEPA prefieran, mas sencillamente, ser informados sobre que Puntos de Venta tienen el mejor precio para ciertas Canastas Representativas y acudan a ellos: pierden en minimizacion de costes, pero ganan en tiempo destinado a ello.

Es imposible construir una unica Canasta Representativa: la composicion del nucleo familiar, sus habitos alimenticios y hasta la propension a cocinar en casa determinan Canastas bastante disimiles. Lo ideal, en su lugar, seria confeccionar "puertas adentro" una **serie de Canastas Representativas** breve ("Pareja joven, sin hijos, vegetarianos", "Adulto con un hijo a cargo", "Asado para 10 personas"), y que cada una de ellas sea su propio indicador de competitividad, entre los cuales el Consumidor elegira de acuerdo a sus propositos.

### Diagrama ER de Canastas

La entidad Canasta definitivamente no es parte del modelo ER esencial para _almacenar_ la informacion del SEPA. Si es, por otra parte, una abstraccion clave para _representar_ la informacion recopilada. Si consideramos que una Canasta es simplemente un conjunto de pares (producto, cantidad), obtenemos:

![Fig. 6: DER para Canastas y su union con Productos a traves de Componentes Canastas](../img/der-canastas.png)

### Clasificador de Puntos de Venta

Con el modelo sugerido, podemos calcular el precio de cualquier canasta en tantos locales como se desee. En caso de que este servicio se le ofrezca al Consumidor, los PdV habran de restringirse a un numero manejable tanto para la consulta como para la visualizacion. Para generar el indicador de competitividad en precios que mencionamos antes, habremos de calcular el valor a la fecha de determinada Canasta de referencia en _todos_ los locales.

Que Canasta sera adecuada para dicha tarea? Ninguna sera perfecta, pero podemos aprovechar el trabajo de los que mas saben, y utilizar a tal fin la composicion de la division "Alimentos y Bebidas, Alimentos para consumir en el Hogar" del Indice de Precios al Consumidor que publica el INDEC: los productos que el SEPA rastrea coinciden fuertemente con dicho componente del IPC. Tristemente, en la ultima Metodologia publicada, el Anexo titulado "Canasta Basica Alimentaria" tiene un texto de relleno estilo Lorem Ipsum. 

Asumiendo que tenemos tal canasta representativa, `canastaRep`, y una funcion `precioCanasta(canasta,fecha,puntoDeVenta)` que calcula la suma de los precios a cierta de los productos y cantidades incluidos en `canasta` en venta en `puntoDeVenta`, nuestra medida de competitividad es

> `precioCanastaRepresentativa(puntoDeVenta) = precioCanasta(canastaRep, "Hoy", puntoDeVenta)`

Es de esperar que algunos PdV no comercializen todos los Productos de la Canasta representativa: para evitar que los comercios con menor surtido dominen el ranking, debemos asegurarnos de asignarle un precio "por default" a todo producto que un PdV no distribuye.

Si se quiere transformar este precio en un indicador mas tradicional, se puede tomar como base el precio minimo obtenido para la Canasta representativa, asignarle un valor de 100 y ajustar a esta nueva escala el resto de los precios obtenidos.

## 4. Variaciones intertemporales de precios

En el apartado anterior comparamos los precios en distintos Puntos de Venta entre si, para un cierto instante. Otra forma esclarecedora de comparar precios de canastas, es intertemporalmente, en un mismo PdV o Empresa: esto nos dara una idea razonable del compromiso de una Empresa a mantener la suba de precios a un minimo. Como siempre, la eleccion de la canasta de productos a comparar es clave para evitar abusos del indicador (donde una Empresa sube todos sus precios salvo los incluidos en la Canasta utilizada), y que este sea una verdadera senial de confianza.

Hay muchas formas de medir variaciones intertemporales de indicadores de negocios, como del primero del mes/anio a al fecha (MTD/YTD), o 30/365 dias atras a la fecha. El INDEC utiliza un indicador mas robusto, donde la variacion de precios mensual se calcula comparando los promedios de precios de _todos los dias del mes_. Cualquiera de estas opciones puede ser valida. Tomemos para este indicador la variacion del primero del anio a la fecha, o _year-to-date_.

En este caso, en lugar de calcular la variacion por Punto de Venta, lo haremos a promediando a nivel Empresa las variaciones en cada uno de sus PdV. Buscamos un indicador de "buena fe" en la formacion de precios por parte de las Empresas, y no de sus locales particulares. Reutilizando la funcion `precioCanasta()` y la Canasta `canastaRep` anteriormente descrita, construimos

- `precioCanastaEmpresa(canasta, fecha, empresa)` = Promedio de precioCanasta(canasta, fecha, puntoDeVenta) para todos los Puntos de Venta de `empresa`

Finalmente, el indicador que buscamos se obtiene como

> `variacionAnioALaFecha(empresa, canastaRep) = ( precioCanastaEmpresa(canastaRep, "Hoy", empresa) / precioCanastaEmpresa(canastaRep, "Primero del Anio", empresa) - 1 ) * 100`


## 5. Otros indicadores posibles

### Deteccion de situaciones hiperinflacionarias

Una tipica anecdota de las epocas hiperinflacionarias en Argentina cuenta que no solo se solia pagar diariamente a los empleados, sino que hasta se llegaba a agregar un descanso en medio de la jornada explicitamente para ir de compras, antes de que los precios volviesen a subir. Es decir que una caracteristica tipica de la hiperinflacion es el aumento casi diario de precios. En la Resolucion 12/2016, se exige que las Empresas reporten cualquier durante el transcurso del dia al precio declarado la jornada anterior. Es de esperar que la correccion de errores accidentales, pero ni bien la tasa de Partes de Precio actualizada en el dia de vigencia sobre el total supera este "ruido de fondo", hemos de empezar a sospechar una acelerada inflacionaria.

Aunque muy sencillo de calcular y llamativo a primera vista, un problema obvio de este indicador es que de estar verdaderamente en una hiperinflacion, la adecuada provision de informacion al SEPA por parte de las Empresas seguro se deteriorara fuertemente. Cabe averiguar, tal vez, si tal metrica sera util como indicador _temprano_ de hiperinflacion, al estilo en que las consultas sobre gripe en Google tienen (un poquito de) poder predictivo sobre la cantidad posterior de enfermos registrados. 

### Evolucion de los valores promocionales

Por el efecto de _framing_, la forma de presentar informacion es determinante en su percepcion. Por ello, a veces puede ser preferible vender un producto de $70 a "$100 con **30%** de descuento!". Algunas Empresas tienen programas de fidelizacion o facilidades de pago que hacen uso pesado pero etico de los descuentos. En otros casos, podemos estar frente a ardides de mercadeo como el mencionado.

No es facil diferenciar entre ambos casos, pero si tomamos el promedio de los descuentos ofrecidos por Empresa en todos sus productos a una fecha determinada, tenemos una buena medida de la injerencia de las Promociones en las politicas de marketing de la firma. Luego, como siempre, sera necesario revisar manualmente los casos mas destacados para distnguir entre practicas leales y desleales.
