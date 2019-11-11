{-# LANGUAGE Rank2Types #-}

{-
Cálculo Lambda

----
0. Definición

Es un modelo de computación formal y universal propuesto por Alonzo Church en la década de los 30s 
en la Universidad de Princeton. Su origen es el estudio de la noción de una función desde una 
perspectiva computacional. 

La formalidad implica que tienen una sintaxis y reglas de semántica. La sintaxis está conformada 
por expresiones lambda y las reglas de semántica consisten en aplicar y abstraer los términos 
lambda entre sí, también llamadas conversiones.  

La universalidad implica que tiene el mismo poder de cómputo que una máquina de Turing. 
Una máquina de Turing describe la noción de cómputo con base en estados y transiciónes.
El cálculo lambda describe la noción de cómputo a través de funciones y sus conversiones. 
Ambas son equivalentes y esto es el fundamento de la tésis Church-Turing.

(Nota histórica: Alonzo Church fue supervisor de tésis doctoral de Alan Turing)


-----

1. Sintaxis 

Puro y no tipificado

exp -> x | exp exp | \x.exp | (exp)

x pertenece a un conjunto de identificadores de variable. 

Ejemplos de expresiones puras no tipificadas: 

1. x
2. x y
3. (\x.\y.f x y) (\x.x) w
4. (\x.(x x))(\x.(x x))
5. \f.(\x.f(x x)))(\x.f(x x))

Se le llama aplicación a una expresión de tipo: exp exp
Se le llama abstracción a una expresión de tipo: \x.exp

Ejemplos con la sintaxis de Haskell (usando constantes y operadores numéricos para simplificar el ejemplo)

(\x->x) 10

(\x -> (\y -> x + y)) 10 5

((\f -> (\x -> f x)) (\y -> y * y)) 10

-----

2. Codificaciones de Church

En el apartado anterior usamos constantes numéricas y aritméticas para trasladar las expresiones de ejemplo a Haskell. 

No obstante, siendo un sistema universal, el cálculo lambda puede codificar cualquier cómputo (Church-Turing thesis). 

¿Cómo podríamos codificar el lenguaje de las expresiones aritméticas en cálculo lambda puro y no tipificado?

* Numerales de Church

La representación de un número natural en la codificación de Church es una función de alto orden que es aplicada
a su argumento N veces, donde N es el número representado. 

Ejemplos: 

0 -> \f.\x.x
1 -> \f.\x.f x
2 -> \f.\x.f (f x)
3 -> \f.\x.f (f (f x))

y así sucesivamente. 

En Haskell: 

-}

cero = \f -> (\x -> x)
uno = \f -> (\x -> f x)
dos = \f -> (\x -> f (f x))
tres = \f -> (\x -> f (f (f x)))

{-

Para convertirlos a una literal de número natural en Haskell, podemos aplicar la función parcial
(+ 1) al 0. 

Ejemplos: 

(dos (+ 1) 0)

Hagamos una función auxiliar para convertirlos rápidamento

-}

cToN church = church (+ 1) 0


{-}

Pregunta de repaso: ¿por qué decimos que es una función de alto orden?

-----

* Operaciones básicas con los numerales de Church

El sucesor de un numeral de Church consiste en aplicarle una vez más la función f:

succ n = \n.\f.\x.f (n f x) 

En Haskell

-}

succ' = \n -> (\f -> (\x -> f (n f x)))

cuatro = succ' tres

{-

La suma de dos numerales m y n de Church es simplemente la composición de ambos numerales
en una función:

suma m n = \m.\n.\f.\x.m f ( n f x)


-}

suma = \m -> (\n -> (\f -> (\x -> m f (n f x))))

{-

La multiplicación entre m y n es la aplicación de m veces la aplicación parcial de n veces 
de la función f:

mult m n = \m.\n\f\x.m (n f) x

Ahora su versión en Haskell: 

-}

mult = \m -> (\n -> (\f -> (\x -> m (n f) x)))

{-

El predecesor, la resta y la división son operaciones complejas en la codificación de Church. 

La base de las operaciones anteriores es predecesor, que se define como:

pred = \n.\f.\x.n(\g.\h.h(g f))(\u.x)(\u.u)

La división sería: 

div = (\n.((\f.(\x.x x) (\x.f (x x))) (\c.\n.\m.\f.\x.(\d.(\n.n (\x.(\a.\b.b)) (\a.\b.a)) d ((\f.\x.x) f x) (f (c d m f x))) ((\m.\n.n (\n.\f.\x.n (\g.\h.h (g f)) (\u.x) (\u.u)) m) n m))) ((\n.\f.\x. f (n f x)) n))

La derivación de esta función está fuera del alcance del curso. Lo importante es 
demostrar que es posible codificarlas sin hacer uso de constantes naturales. Esto es, 
podemos tener un sistema de cómputo en cálculo lambda puro no tipificado. 

-----

* Booleanos de Church

Los booleanos de Church consisten en una decisión entre dos parámetros en una función: 

verdadero = \x.\y.x
falso = \x.\y.y

Esta codificación hace sencilla la construcción de predicados y operadores lógicos:

and = \p.\q.p q p
or = \p.\q.p p q
not = \p.p falso verdadero
if = \p.\a.b.p a b

Ahora veamos las definiciones en Haskell:

-}


type ChurchBoolean = forall a. (a -> a -> a)

verdadero :: ChurchBoolean
verdadero = \x -> (\y -> x)

falso :: ChurchBoolean
falso = \x -> (\y -> y)

cToB church = church True False

and' :: ChurchBoolean -> ChurchBoolean -> ChurchBoolean
and' p q = p q p

or' :: ChurchBoolean -> ChurchBoolean -> ChurchBoolean
or' p q = p p q

--if' :: ChurchBoolean -> a -> a -> a
--if' p a b = p a b

not' :: ChurchBoolean -> ChurchBoolean
not' p = p falso verdadero

{-

Existen otras operaciones booleanas más complicadas de codificar, particularmente en Haskell, 
pues tendríamos que tipificar la flexibilidad del cálculo lambda no tipificado. 
No obstante, estos ejemplos pueden ser evidencia suficiente de que es posible trabajar
con el cálculo lambda puro para tener condicionales, operadores lógicos y tipos booleanos. 

-----

* Otras codificaciones en notación de Church

Es posible codificar pares, y con estos hacer listas inmutables, tal como las practicamos
en Racket y Haskell. 

Un lenguaje de programación sencillo va tomando forma empleando solamente expresiones lambda puras.

Aunque no sería útil para construir software, es una demostración teórica importante 
para ayudarnos a razonar sobre los límites de la computación y su relación con las funciones
y los fundamentos de las matemáticas. 

-----

3. Conversiones

Para simplificar la explicación de la semántica del cálculo lambda, hagamos una extensión al lenguaje 
para añadir constantes numéricas y algunos operadores esenciales. 

exp -> x | c | exp exp | \x.exp | (exp)

donde la C puede ser un número entero y la x puede ser un identificador de operador común ya ligado, 
tal como +, *, cons, etc. 

Ejemplos de expresión: 

x
4
+ x 2
(\x.\y.+ x y) (\z. z) 4
(\f.\l.f l) car m
\f.(\x.f (x x))(\x.f (x x)) Fac

Recordatorio: anteriormente hablamos de dos tipos de expresión:

Abstracciones como \y.\x.(+ x y) Aplicaciones como (\x.\y.+ x y) 1 2

Esta terminología es importante para continuar con la discusión. 

* Asociatividad

Usemos la siguiente expresión en cálcula lambda extendido: 

(\x.\y.+ x y) (\z.z) 3

La interpretación de la expresión puede ser: 

1. Los argumentos de (\x.\y.+ x y) son (\z.z) y 3
2. El argumento de (\z.z) es 3, y este se convierte en el primer argumento de (\x.\y.+ x y)

El primer caso corresponde a la asociatividad izquierda, el segundo a la derecha.
En este caso usaremos la asociatividad izquierda por default en la discusión de las 
conversiones. 

Trivia: ¿Qué asociatividad tiene Haskell?

* Tipos de conversiones (reducciones)

d-conversión (delta)
Evaluación de funciones predefinidas

b-conversión (beta)
Aplicación de una función a sus argumentos

a-conversión (alpha)
Renombrar variables

h-conversión (eta)
Eliminar variables

Cuando las reglas de conversión se aplican en un sentido se les llama
reducciones. 

Un redex es una expresión en lambda a la cual se le puede
aplicar una reducción. Existen alpha-redex, beta-redex, etc. 

Ejemplos: 

(\x.x) 3 es un beta-redex

(\a.\b.+ a b) ((\x.x) 3) 5 tienes dos beta-redex

Ejemplos de reducciones delta:

(= 0 0 ) -> True
(+ 27 32) -> 59
(if True e1 e2) -> e1
(car (cons e1 e2)) -> e1

Ejemplo sde reducciones beta: 

(\x.x) 3 -> 3
(\a.\b.+ a b) (\x.x) -> \b.+ (\x.x) b

*Formas normales y orden de reducción

Se dice que una expresión está en forma normal cuando
ya no tiene candidatos a reducción (redexes).

(\x.y.+ y x) está en forma normal, pero (\x.y.+ y x) 2, no lo está

La forma normal en el cálculo lambda es equivalente a un halt en 
una máquina de turing, esto es, la terminación de un programa. 

Análogamente, una expresión lambda que no puede llevarse a una forma
normal es equivalente a un programa que no termina (ciclado). Ejemplo:

(\x.x x)(\x.x x)

No obstante, el orden de reducción puede generar un programa
que termina o no. 

Ejemplo: 

(\x.\y.y)((\z.z z)(\z.z z))

Si comenzamos con el redex interno izquierda, entonces tendremos
un programa que se cicla. Si tenemos asociatividad izquieda con el 
redex externo izquierdo, entonces eliminamos la porción del programa 
que se cicla. 

Trivia: 

Reconocen las expresiones: 

1. \x.\y.x y  

2. (\x.x x) (\x.x x)

Orden aplicativo: 

Equivale a una sustitución tipo parámetros por valor
Es por lo general más eficiente
Es el que usa la mayoría de los lenguajes funcionales

Orden normal:
Equivale a una sustitución tipo parámetros por nombre
Asegura obtener la forma normal, si existe
Es utilizado por lenguajes de evaluación perezosa

"Trivia": ¿Cuál tiene Haskell?


4. Combinadores 

Hemos visto cómo codificar números naturales y operaciones aritméticas básicas. 
También hemos visto cómo codificar booleanos y tomar decisiones. 

Junto con los elementos básicos del cálculo lambda tenemos:

variables, funciones, literales, decisiones... 

¿Qué elemento fundamental del cómputo hace falta?

Algunos dirán iteración, pero un guerrero de la lambda dirá: recursión. 
Existe una expresión muy famosa en el cálculo lambda que nos ayuda con este
propósito: el combinador Y

Y = \f.(\x.f(x x))(\x.f(x x))

Trivia histórica: ¿A quién se le atribuye el descubrimiento del
combinador Y?

Un combinador es simplemente una función sin variables libres. Esto es
el cuerpo de la función tiene sólo variables enumeradas en los argumentos.

Para entender la idea de recursión (o ciclaje) en el cálculo lambda,
es importante entender el concepto de auto-aplicación. Ejemplo:

(\x.x x)(\x.x x)

Anteriormente vimos esta expresión como un ejemplo de forma
que no termina. No obstante, el valor radica en la noción de 
auto-aplicación como la esencia de un ciclo. 

Al aplicarse a sí misma, y generarse de nuevo, esta expresión
nos da una idea que podemos utilizar para llegar al combinador Y.
La diferencia es que el combinador tiene una función que nos 
permite controlar la recursión. 

Supongamos que tenemos la siguiente expresión:

Y g = (\f.(\x.f(x x))(\x.f(x x))) g

Apliquemos una serie de reducciones beta:

1. (\x.g(x x))(\x.g(x x))
2. g((\x.g(x x))(\x.g(x x)))

Por ende: g (Y g)

¿Cómo lo haríamos en Haskell?

No es factible hacer un combinador Y puro en Haskell por las restricciones
del sistema de tipos. Lo más cercano a la definición original es emular
la recursión con ligados de funciones con los parámetros actualizados en cada
"iteración", tal como sucedece con el caso de recursión terminal. 

-}

ycomb :: (a -> a) -> a
ycomb f = f (ycomb f)

fac =(ycomb (\f n i -> if i <= 0 then n else f (i * n) (i - 1))) 1

{-
Parace inútil en este caso, pues Haskell nos permite definir funciones recursivas,
incluso dentro de una lambda. No obstante, si este lenguaje no tuviera recursión
como parte de su plataforma de ejecución, el combinador se encarga de ir
manufacturando funciones hasta llegar al caso base. 

Estamos pasando como parámetro el combinador con la función "atrapada" y en 
cada llamada se vuelve a duplicar el combinador, siempre que se vaya a 
la cláusula else. 

Por eso la importancia de tener un caso base en recursión. Es la única manera
de deshacernos del combiandor y resolver la llamada original. 

-----

*Otros combinadores

Los combinadores NO son exclusivos del cálculo lambda, simplemente fueron
codificados en él. Ya existían previo a la notación de Alonzo Church, y son parte
del esfuerzo de inicios de siglo por construir los fundamentos lógicos de las 
matemáticas, hasta Godel, quien probó que tal esfuerzo es fútil. 

I (Identidad) Idiot
I x = x

S Starling
S x y z = (x z (y z))

T Trush
T x y = y x

B Bluebird
B a b c = a (bc)

K Kestrel
K a b = a

M Mockingbird
M a = a a

http://www.angelfire.com/tx4/cus/combinator/birds.html

-}