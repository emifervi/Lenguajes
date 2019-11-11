#lang racket


#|
0. Formas especiales let, let*, letrec, define

Enlaces locales (local bindings)

Al tratarse de una forma especial, la pregunta clave es ¿cuál es su semántica?

Básicamente, crea una serie de asignación de variables que están disponibles (ligadas-bounded) para ser utilizadas
en el cuerpo de la definición de función, pero no globalmente, como ocurriría con los defines que hemos
estado utilizando. 

|#
(define (f x)
  (let ([x 5] [y 6] [z 8]) (+ z x y)))

#|
Sería similar a utilizar una lambda de la siguiente forma:

(lambda (my-func x y z ...) cuerpo-de-funcion)) val1 val2 val3 ...)

No obstante, como podemos crear nuestra propia sintaxis para propósitos de legibilidad, Racket ya nos proporciona
una serie de formas especiales para el mismo efecto: let, let* y letrec, cada una tiene diferencias semánticas sutiles,
pero aplicables en diferentes circunstancias.

---
1. let

Crea una serie de asignaciones, de derecha a izquierda, arriba abajo, donde las variables ligadas no se pueden referenciar
entre sí. Esto es, no puedo hacer una asignación let que use otra asignación let anterior o posterior.

Ejemplos de let

Válido

(define (ej1 xs) (let ([x 5] [y 6]) (+ x y)))

No Válido

(define (ej1 xs) (let ([x 5] [y (+ x 1)]) (+ x y)))

¿Cómo nos podría ayudar a mejorar nuestro diseño de funciones?

Evitando explosiones exponenciales


Antes de let
|#
(define (max-list li)
(cond [(null? li) (error "LoL")]
      [(null? (cdr li)) (car li)]
      [else (if (> (car li) (max-list (cdr li)))
                (car li)
                (max-list (cdr li)))]))
#|

Después de let
|#
(define (max-list-opt li)
  (cond [(null? li) (error "meh")]
        [(null? (cdr li)) (car li)]
        [else (let ([max-resto (max-list-opt (cdr li))]
                    [first-list (car li)])
                (if (> first-list max-resto)
                    first-list
                    max-resto))]))
#|
**Ejercicio**


---
2. let*

Sintaxis igual a let, pero en la evaluación de cada asignación, el resultado está disponbile
para la siguiente asignación a efectuarse. Esto es, podemos referencias variables previamente
referenciadas en asignaciones subsecuentes. 

Nota: No podemos referencias asignaciones posteriores.

**Ejercicio, cómo podríamos mejorar el quicksort que hicimos en la primera clase**

|#
(define (qs li)
  (if (empty? li)
      null
      (let* ([pivot (car li)]
             [lt (filter (lambda (x) (< pivot x)) (cdr li))]
             [gt (filter (lambda (x) (> pivot x)) (cdr li))])
        (append (qs lt) (list pivot) (qs gt)))))
#|

---
3. letrec y define

Sintaxis igual a las dos formas especiales anteriores, pero las asignaciones pueden referenciar
asignaciones previas y posteriores, además de que pueden existir referencias circualres en funciones
mutamente recursivas. Tienen sentido en el uso de lambdas, pues crean una cerradura con el valor
y no se ejecutan durante la interpretación de letrec. 

Estos casos deben ser evitados, pues son un patrón difícil de entender y mantener. 

Ejemplo

(define (every-other li)
  (letrec ([even (lambda (l) (if (empty? l) null (cons (car l) (odd (cdr l)))))]
           [odd (lambda (l) (if (empty? l) null (even (cdr l))))])
    (even li)))

|#


#|
1. Recursividad terminal y Tail-call optimization (TCO)

Se dice que una función contiene recursividad terminal cuando
su llamada recursiva no contiene operaciones adicionales

*Ejemplo:
|#
(define (exists? n li)
  (cond [(empty? li) #f]
        [(= ((car li) n)) #t]
        [else (exists? n (cdr li))]))
#|
La expresión que contiene la llamada recursiva a exists? no tiene
operaciones adicionales


*Ejemplo que NO tiene recursividad terminal 
|#
(define (factorial n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))
  
#|
La expresión que contiene la llamda recursiva a factorial viene acompañada
de una multiplicación por n. Por ende, esta función no cumple con las condiciones
de recursión termianl para ser optimizada

¿Por qué es importante?

Es trivial de optmizar al implementar de un intérprete. Se usa la eliminación de la recusión terminal evitando
que se genere un "frame" adicional en el "stack", modificando un único frame de la llamada recursiva con nuevos argumentos
en cada iteración. Esto es, el intérprete hace de la función el cuerpo de un ciclo y le va alimentando valores a los parámetros,
tal como lo haría un "for". Es casi tan eficiente en memoria y ejecución que un ciclo en un lenguaje imperativo.

¿Cómo puedo añadir recursión terminal a una función que no lo tiene por definición?

Se añade una versión auxiliar de la función con parámetros adicionales, representando contadores, acumuladores u
otros auxiliares para evitar operaciones adicionales al hacer la llamada recursiva.

Ejemplo:


(define (optimized-factorial n)
  (factorial-aux n 1))

(define (factorial-aux n r)
  (if (<= n 1) r
      (factorial-aux (- n 1) (* n r))))

|#

;Fibonacci Terminal
(define (fib n)
  (if (or (= n 0) (= n 1))
      1
      (+ (fib (- n 2)) (fib (- n 1)))))

(define (fib-t n)
  (fib-aux 1 1 n))

(define (fib-aux n2 n1 n)
  (if (<= n 2)
      n1
      (fib-aux n1 (+ n1 n2) (- n 1))))

#|
2. Listas anidadas (ímbricas)

Para procesar listas anidadas es necesario implementar recursividad profunda: ahora es necesario
verificar si cada elemento es a su vez una lista y hacer la llamada recursiva pertinente o procesar un átomo.

Recuerda que tenemos una función en la librería estándar para dicha labor:
list?
(not (list? 'atom))

Ejercicios

|#

;flatten
(define (planificar li)
  (cond [(empty? li) null]
        [else (if (list? (car li))
                   (append (planificar (car li)) (planificar (cdr li)))
                   (append (list (car li)) (planificar (cdr li))))]))

;nest

;max-nest

;count-atoms

;sum

;increment


#|
3. Funciones de primer orden (first-class)

¿Qué es un elemento de primer orden en un lenguaje de programación?

1. Aquellos que se pueden pasar como parámetro
2. Aquellos que se pueden generar como resultado de una función
3. Pueden formar parte de una estructura de datos

En Racket usamos la forma especial lambda para generar funciones, tal como
usamos list para construir listas o define para ligar variables a expresiones.

¿Qué beneficios tiene un lenguaje con funciones de primer orden?

Flexibilidad y expresividad

Funciones de orden superior (high-order)

Funciones que hacen al menos una de las siguiente cosas:

1. Reciben una o más funciones como entrada
2. Devuelven una función como salida

Ejercicios

|#

;filter

(define (filtro pred li)
  (if (null? li)
      null
      (if (pred (car li))
          (cons (car li) (filtro pred (cdr li)))
          (filtro pred (cdr li)))))
;map

(define (mapa ft li)
  (if (empty? li)
      null
      (cons (ft (car li)) (mapa ft (cdr li)))))

;reduce
;** Ejercicio tipo examen **

#|
4. Estructuras de datos en Racket

* Lineales
Arreglos
Registros (Records)
Tablas
Pilas
Filas


* Jerarquía
Árboles Binarios
Árboles de expresiones
Heaps


* Grafos
Dirigidos
No dirigidos
Ponderados


Todas las estructuras de datos anteriores pueden ser emuladas con listas en Racket.

Ejemplos:

|#

;Arreglo unidimensional

;getn

;setn
(define (set-n x i li)
  (cond [(empty? li) (error "WUT")]
        [(= i 0) (cons x (cdr li))]
        [else (cons (car li) (set-n x (- i 1) (cdr li)))]))

;insert-in-order
(define (iio x li)
  (if (empty? li)
      (list x)
      (if (<= x (car li))
          (cons x (cons (car li) (cdr li)))
          (cons (car li) (iio x (cdr li))))))

;insertion sort
(define (insort li)
  (cond [(empty? li) li]
        [else  (iio (car li) (insort (cdr li)))]))

;---
;Matrices

;'((1 2 3) (4 5 6) (7 8 9))

; sum-reng
(define (sum-reng r1 r2)
  (if (empty? r1)
      null
      (cons(+ (car r1) (car r2)) (sum-reng (cdr r1) (cdr r2)))))

;summ
(define (summ m1 m2)
  (if (empty? m1)
      null
      (cons (sum-reng (car m1) (car m2)) (summ (cdr m1) (cdr m2)))))

;---
;Registros

;Name | Last Name | Nationality | Weapon

;'(Natalya Simonova Russian CougarMagnum)
;'(James Bond British GoldenEye)

;'((Natalya Simonova) Russian "Cougar Magnum")

;'((name Natalya) (last-name Simonova) (nationality Russian) (weapon-of-choice Cougar-Magnum))


;get-field

;query-records


;---
;Stack

;push

;pop

;peek


;---
;Queue

;insert

;remove

;first


;---
;Binary Tree

;'(root (left-tree) (right-tree))

;add

;search


#|

5. Raket Híbrido

Mutaciones con set! y begin

(set! x e)

Reasigna el valor de x a la evaluación de e. Todas las referencias a x subsecuentes usarán
el nuevo valor establecido por set!.

Ejemplo

(set! x 4)

(display x)

(set! x 10)

(display x)


Otro ejemplo más interesante involucrando cerraduras léxicas

(define x 10)
(define fun (lambda (y) (+ y x)))
(set! 5)
(define z (fun 5))

¿El resultado es 10 o 15?

Decimos que "fun" fue asignada a la evaluación de la forma especial lambda, la cual
cerró sobre la variable libre x en el alcance global, la cual tenía el valor de 10.
No obstante, en Racket, llamadas subsecuentes a la función en donde se haga uso del
valor de x harán que la expresión ligada a x se vuelva a evaluar constantemente.

No cierra sobre el valor de x, sino sobre la expresión a la cual x está ligada.
Decimos que cerró (closure) sobre la variable por referencia. 

Otro ejemplo más interesante:

(define incre
  (let ((i 0))
    (lambda () (begin (set! i (+ i 1)) i))))

(incre)
...
...
(incre)


Cuando hay mutaciones y efectos secundarios, es conveniente tener una manera de encadenarlos,
como se evaluaría línea por línea en un lenguaje imperativo. Para este caso, Racket
tiene begin

(begin e1 e2 ... ef)

Donde el resultado de la expresión es el resultado de la última expresión en la secuencia "ef"
en este caso. 

Ejemplo

(begin (display "Bienvenido") (display "Este es el total de tu compra") 123.50)

|#


#|
6. Cerraduras léxicas y mutación para crear objetos

(define build-stack
  (let ([s '()])
    (lambda ()
      (lambda (method arg)
        (case method
          ((push) (set! s (cons arg s)))
          ((peek) (car s)))))))

(define st (build-stack))

**Ejercicio**
Completar el resto de los métodos de un stack

|#







      
