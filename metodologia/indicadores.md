# Indicadores Posibles

Qué objetivos se persiguen al crear el SEPA? Sin ánimo de ser exhaustivos, podemos imaginar:

1. Recopilar información detallada de la evolución de precios en artículos de consumo masivo,
2. Promover la transparencia y responsabilidad en la decisión de precios de los mayores actores del sector,
3. Empoderar al ciudadano con herramientas de comparación de precios entre puntos de venta, y
4. Destacar a aquellas Empresas que mantengan sus aumentos de precios por debajo de la media.

Del universo de indicadores posibles para estos objetivos, a continuación presentaremos uno por cada uno. 

Pese a que los indicadores que involucran precios se describen utilizando los precios de lista, todos se pueden aplicar a los precios promocionales con mínimos cambios.

## 1. Efectiva provisión de la información

[**Consulta SQL**](../sql/provision-de-informacion.sql)

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

No sólo es necesario que las Empresas sujetas por la Resolución _proporcionen información_ al SEPA, sino que además ésta debe ser **confiable y veraz**: de nada sirve que se reporten precios diferentes a los que efectivamente enfrenta el consumidor.

Sin acceso a Partes ciudadanos, esto resulta imposible. Por otra parte, si imaginamos una tabla de Partes de Precios ciudadanos como la que se menciona en el Análisis de la Resolución, el recuento de Partes de Precio producido (en los últimos `nDias` días) por particulares para cada Empresa nos permite generar un simple ranking de potenciales infractores: mientras más alto el número de discrepancias, menos probable es que éstas sean accidentales.

Para evitar dobles conteos, debemos considerar el número de Productos _únicos_ sobre los que se han provisto Partes particulares en el período relevante. Bajo estas condiciones, podemos definir la cantidad de Precios Mal Informados por Empresa como:

> `preciosEquivocados(empresa, nDias = 7)`: Cantidad de Productos _únicos_ mencionados en los Partes de Precios registrados por "particulares" en cualquiera de los Puntos de Venta que pertenecen a la Empresa `empresa` en los ultimos `nDias` días.

Ordenando los resultados de `preciosEquivocados()` de mayor a menor, obtenemos un orden de prioridad razonable para detectar posible dolo en la inputación de precios al sistema.

**NOTA**: Este indicador supone que si un ciudadano registra un Parte de Precio, es únicamente porque el precio que observa no coincide con el registrado en el Sistema.
De poder registrar Partes por otras razones, debemos agregar la condición de que los Partes de particulares a considerar sean sólo aquellos donde el precio que menciona la Empresa difiera del que constata el Particular. Otras sofisticaciones posibles incluyen la ponderación de cada inconsistencia en función de la razón entre precio registrado y precio observado.

## 3. Comparación entre Puntos de Venta

[**Consulta SQL**](../sql/comparacion-canastas-entre-ppdv.sql)

A pesar de la a veces masiva oferta de Puntos de Venta, los consumidores rara vez saben con certeza _dónde_ les conviene realizar sus compras: los lácteos son más baratos en un lugar, los artículos de limpieza en un segundo, y la comida para gatos en un tercero. Sin embargo, realizar una ruta óptima en todos los precios probablemente sea subóptimo al considerar el tiempo involucrado.

En general, lo que un consumidor buscará es aquél negocio que, _en promedio_, tenga los mejores precios para un conjunto de artículos, y acudirá únicamente a el. El objetivo ahora es proveer una medida de **competitividad en los precios** de cada Punto de Venta. 

Para empezar, podemos contar qué proporción de los Productos ofrecidos en cada Punto de Venta tienen el precio mínimo registrado para dicho Producto y Fecha entre todos los Puntos de Venta (de la zona/región).

Si imaginamos un comercio donde _todos_ los productos se venden _solamente_ un centavo por encima del precio mínimo, veremos que este primer indicador falla: la proporción de precios mínimos sera cero, cuando es harto probable que un comercio así sea altamente competitivo.

Un segundo indicador, se obtiene calculando la razón entre la suma de todos los precios informados por Punto de Venta (**PdV** en adelante), contra la suma de los precios mínimos registrados para esos mismos Productos a la fecha en cuestión en cualquier PdV. Esta versión es más robusta a pequeñas diferencias entre el precio ofrecido por un PdV y el mínimo a la fecha.

Aún así, sigue siendo un tanto arbitrario: por qué deberían entrar en el recuento *todos* los productos ofrecidos, independientemente de su frecuencia de ventas? Si deseamos ofrecer un indicador verdaderamente útil de competitividad en precios, debemos inevitablemente introducir el concepto de **Canastas** y Canasta Representativa.

El consumidor altamente motivado puede estar dispuesto a detallar su propia canasta de compras, y utilizar el SEPA para comparar su valor entre varios PdV. Sin embargo, es de esperar que la mayoría de los usuarios particulares del SEPA prefieran, más sencillamente, ser informados sobre qué Puntos de Venta tienen el mejor precio para ciertas Canastas Representativas y acudan a ellos: pierden en minimización de costes, pero invierten menos tiempo.

Una única Canasta Representativa no representará muy bien a nadie: la composición del núcleo familiar y sus hábitos determinan Canastas bastante disímiles. Lo ideal será confeccionar "puertas adentro" una **serie de Canastas Representativas** de distinton consumos típicos ("Pareja joven, sin hijos, vegetarianos", "Adulto con un hijo a cargo", "Asado para 10 personas"), y que cada una de ellas sea su propio indicador de competitividad, entre los cuales el Consumidor elegirá de acuerdo a sus propósitos.

### Diagrama ER de Canastas

La entidad Canasta definitivamente no es parte del modelo ER esencial para _almacenar_ la información del SEPA. Sí es una abstracción clave para _representar_ la información recopilada. Si consideramos que una Canasta es simplemente un conjunto de pares (producto, cantidad), obtenemos:

![Fig. 6: DER para Canastas y su union con Productos a traves de Componentes Canastas](../img/der-canastas.png)

Uniendo estas entidades al DER propuesto al final del Análisis de la Res. 12/2016, obtenemos el "[DER Completo](../img/der-completo.png)".

### Clasificador de Puntos de Venta

Con el modelo sugerido, podemos calcular el precio de cualquier Canasta en tantos locales como se desee. En caso de que este servicio se le ofrezca al Consumidor, los PdV habrán de restringirse a un número manejable tanto para la consulta como para la visualizacion.

Para generar _un_ indicador de competitividad en precios independiente del Consumidor, habremos de calcular el valor a la fecha de determinada Canasta de Referencia en _todos_ los locales.

Qué Canasta será adecuada para dicha tarea? Ninguna será perfecta, pero podemos aprovechar el trabajo de los que más saben, y utilizar a tal fin la composición de la división "Alimentos y Bebidas, Alimentos para consumir en el Hogar" del Índice de Precios al Consumidor que publica el INDEC. Estimo que los productos que el SEPA rastrea coinciden fuertemente con dicho componente del IPC. Tristemente, no lo he podido comprobar, pues en la ultima Metodología del IPC publicada en Abril 2016 por el NDEC, el Anexo titulado "Canasta Básica Alimentaria" tiene un texto de relleno estilo Lorem Ipsum. 

Asumiendo que hemos podido "traducir" a nuestro formato tal canasta representativa, `canastaRep`, y una funcion `precioCanasta(canasta,fecha,puntoDeVenta)` que calcula la suma de los precios a cierta `fecha` de los productos y cantidades incluidos en `canasta` en venta en `puntoDeVenta`, nuestra medida de competitividad entre PdVs es:

> `precioCanastaRepresentativa(puntoDeVenta) = precioCanasta(canastaRep, "Hoy", puntoDeVenta)`

Es de esperar que algunos PdV no comercializen todos los Productos de la Canasta representativa: para evitar que los comercios con menor surtido dominen el ranking, debemos asegurarnos de asignarle un precio "por default" a todo producto que un PdV no distribuye.

Si se quiere transformar este precio en un indicador más tradicional, se puede tomar como base el precio mínimo obtenido para la Canasta representativa, asignarle un valor de 100 y ajustar a esta nueva escala el resto de los precios obtenidos.

## 4. Variaciones intertemporales de precios

En el apartado anterior comparamos los precios en distintos Puntos de Venta entre sí, para un cierto instante. Otra forma esclarecedora de comparar precios de canastas, es intertemporalmente, en un mismo PdV o Empresa: esto nos dará una idea razonable de cuán comprometidos están a mantener a raya la suba de precios.

Como siempre, la elección de la canasta de productos a comparar es clave para evitar abusos del indicador (donde una Empresa sube todos sus precios salvo los incluidos en la Canasta utilizada), y que éste sea una verdadera señal de confianza.

Hay muchas formas de medir variaciones intertemporales de indicadores de negocios, como del primero del mes/año a la fecha (MTD/YTD), o 30/365 días atrás a la fecha. El INDEC utiliza un indicador más robusto, donde la variación de precios mensual se calcula comparando los promedios de precios de _todos los dias del mes_. Cualquiera de estas opciones puede ser válida. Tomemos para este indicador la variación del primero del año a la fecha, o _year-to-date_.

En este caso, en lugar de calcular la variación por Punto de Venta, lo haremos a promediando a nivel Empresa las variaciones en cada uno de sus PdV. Buscamos un indicador de "buena fe" en la formación de precios por parte de las Empresas, y no de sus locales particulares.

Reutilizando la función `precioCanasta()` y la Canasta `canastaRep` anteriormente descrita, construimos

- `precioCanastaEmpresa(canasta, fecha, empresa)` = Promedio de precioCanasta(canasta, fecha, puntoDeVenta) para todos los Puntos de Venta pertenecientes a la Empresa `empresa` al dia `fecha`

Finalmente, el indicador que buscamos se obtiene como

> `variacionAñoALaFecha(empresa, canastaRep) = 100 * ( precioCanastaEmpresa(canastaRep, "Hoy", empresa) / precioCanastaEmpresa(canastaRep, "Primero del Año", empresa) - 1 )`

## 5. Otros indicadores posibles

Los siguientes son indicadores más especulativos: su utilidad es difícil de comprobar sin datos concretos. Los incluyo como prueba de las ricas posibilidades del dataset en cuestión.

### Detección de situaciones hiperinflacionarias

Mi padre siempre cuenta que en la última "Hiper", su empleador le otorgaba un corte en medio de la jornada laboral explícitamente para ir de compras, "antes de que los precios volviesen a subir".

Una caracteristica tipica de la hiperinflación es el aumento casi diario de precios. En nuestro modelo, exigimos un único Parte de Precio por Fecha, Punto de Venta y Producto, y cualquier modificacion posterior actualiza el registro existente. Es de esperar que la correción de errores lleve a una mínima "tasa base" de Partes actualizados después de su creación, pero si dicha tasa comienza a crecer por encima de su nivel básico, hemos de empezar a sospechar una acelerada inflacionaria.

Aunque muy sencillo de calcular y llamativo a primera vista, un problema obvio de este indicador es que de estar verdaderamente en una hiperinflación, la adecuada provisión de información al SEPA por parte de las Empresas  se irá por la borda. Cabe averiguar, tal vez, si tál metrica será útil como indicador _temprano_ de hiperinflacion, al estilo en que las consultas sobre gripe en Google tienen (un poquito de) poder predictivo sobre la cantidad posterior de enfermos registrados.

### Evolucion de los valores promocionales

Por el efecto de _framing_, la forma de presentar informacion es determinante en su percepcion. Por ello, a veces puede ser preferible vender un producto de $70 a "$100 con **30%** de descuento!". Algunas Empresas tienen programas de fidelizacion o facilidades de pago que hacen uso pesado pero etico de los descuentos. En otros casos, podemos estar frente a ardides de mercadeo como el mencionado.

No es facil diferenciar entre ambos casos, pero si tomamos el promedio de los descuentos ofrecidos por Empresa en todos sus productos a una fecha determinada, tenemos una buena medida de la injerencia de las Promociones en las politicas de marketing de la firma. Luego, como siempre, sera necesario revisar manualmente los casos mas destacados para distnguir entre practicas leales y desleales.
