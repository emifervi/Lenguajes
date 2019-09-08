#lang racket


#|
0. Introducción al paradigma funcional

* Nivel alto, muy alto
* Declarativo
* Basado en el cálculo lambda (Alonso Church 1941) solamente existen funciones y aplicaciones, no numeros ? 
* Alejado del modelo Von Neumann
* Aplicación de funciones vs mutación de estados
* Transparencia referencial
* Funciones de primer orden (high order functions)
* Dynamic binding, lazy evaluation
|#


;1. Una primera aproximación en contrastes con la programación imperativa 

;factorial
(define (factorial n)
  (if (= n 0) 1
      (* n (factorial (- n 1)))))

;fibonacci
(define (fib n)
  (cond [(= n 1) 1]
        [(= n 2) 1]
        [else (+ (fib (- n 2)) (fib (- n 1)))]))
;gdc

;sigma
(define (sig li)
  (if (null? li)
      0
      (+ (car li) (sig (cdr li)))))

;quicksort
(define (qsort li)
  (if (null? li)
      null
      (append
       (qsort (filter(lambda (x) (< x (car li))) li))
       (list (car li))
       (qsort (filter (lambda (x) (> x (car li))) li)))))

#|
2. ¿Por qué Racket?

"The greatest single programming language ever designed" - Alan Kay on Lisp

"Lisp is a programmable programming language" - John Foderaro

"Lisp is worth learning for the profound enlightenment experience you will have when you finally get it;
that experience will make you a better programmer for the rest of your days,
even if you never actually use Lisp itself a lot." - Eric Raymond

"The only way to learn a new programming language is by writing programs in it." - Kernighan and Ritchie

"Although my own previous enthusiasm has been for syntactically rich languages, like the Algol family,
I now see clearly and concretely the force of Minsky's 1970 Turing Lecture, in which he argued
that Lisp's uniformity of structure and power of self reference gave the programmer capabilities
whose content was well worth the sacrifice of visual form."
- Robert Floyd, Turing Award Lecture, 1979

"Lisp has all the visual appeal of oatmeal with fingernail clippings mixed in." - Larry Wall

Más frases sobre lisp:
http://www.paulgraham.com/quotes.html?viewfullsite=1

1930's Alonso Church
1950's John McCarthy (FORTRAN y ALGOL)
1970's Steele, Sussman (OOP Smalltalk y Simula)
1990's Racket (PLT Scheme)

The Racket Manifesto
https://www2.ccs.neu.edu/racket/pubs/manifesto.pdf

|#


#|
3. Expresiones de Racket

Atomos: símbolos, números, booleans, carácteres, cadenas, keywords
Listas: lista -> ( [atomo | lista]+ )

Una lista es evaluada como función, siendo el primer término su identificador, y el resto de los elementos los argumentos
Ejemplo: (+ 1 2)

EXCEPTO: cuando el primer término se trata de una forma especial. Cada forma especial tiene su semántica particular.
Ejemplo: if, cond, and, or, define, let, let*, letrec

FUNfact... fun? get it? Podemos definir nuestras propias formas especiales usando macros
|#


;4. Átomos

;Números
;-6
;2309482039482039482093482039482093482093482093842039482093843940582039458729348752983457293485
;1.5
;4/5

;Booleans
;#t
;#f

;Strings
;"asdfasdfasdf"

;Carácteres
;#\a
;#\λ

;Símbolos
;'soy-un-simbolo
;Una palabra que se construye con las mismas reglas que un identificador, pero que evalúa a sí mismo y
;es internalizado, a diferencia de un string inmutable

;cuando el interprete ve un simbolo, lo tiene guardado en una tabla de simbolos, busca la referencia en la tabla y la vuelve a utilizar
;a diferencia de otros lenguajes que hacen una copia cada que reciben el string, esto hace que sea una optimizacion para manejo de words
;en un lenguaje

;number?
;integer?
;negative?
;real?
;rational?
;odd?
;even?
; + - * / < > <= >=

;boolean?
;false?
;not

;symbol?
;symbol=?

;equal? igualdad de valor
;eq? igualdad de valor y referencia (representación física)


;5. Listas

;(list 'a 'b 'c 'd)
;(list #t #\A 'a 7.6 (list 3 2 1))
;null
;(list)
;(null? (list))

;'(a b c d)
;'()
;'(a b '(c d))

; todo programa de racket es a su vez una estructura valida de racket (permite interpretar otras estructuras on the go)

;(cons 'a (cons 'b (cons 'c (cons 'd null))))

;Las listas se almacenan dinámicamente utilizando como nodos
;a las celdas cons, la cual consta de 2 apuntadores, hacia átomos u otras celdas cons

; una lista propia en racket es aquella que atravez de constructores cons termina con una lista vacia (null)

;(list? '(a))
;(pair? '(a))
;(list? (cons 1 (cons 2 3)))
;(pair? (cons 1 (cons 2 3)))

;Una lista propia es aquella que termina en null-lista vacía
;Una lista impromia (o par) es aquella que NO termina en null-lista vacía

;empty?
;cons
;car ;first
;cdr ;rest
;append
;reverse
;list-ref

;caar
;caddr
;cddr

;6. Formas especiales

;(define a (+ 4 5))
;(quote (a c d))
;(if (equal? 'a (quote a)) (display "Es igual") (display "No es igual"))
;(and (= 2 3) (display "no llega"))
;Es el mismo caso con OR. No son operadores, son formas especiales. 
;Más adelante veremos cond, let y lambda


;7. Funciones

;Tres formas de definir funciones. Usaremos la versión 1 "azucarada sintácticamente" para la clase
;(define (fun1 x y) (/ x y))
;(define fun2 (lambda (x y) (/ x y)))
;(define fun3 (lambda (x) (lambda (y) (/ x y))))

;(lambda (x y z) (list x y z))
;(define (nombre arg arg arg) (logica lel))


;8. Recursividad plana y profunda

;Plana: soluciones que trabajan con listas que sólo contiene átomos
;Profunda: soluciones que trabajan con listas ímbricas, anidadas



;9. Ejercicios

;Numéricos

;divisible
(define (divisible? n i)
  (= 0 (modulo n i)))
;no-divisible
(define (not-divisible? n i)
  (not(divisible? n i)))
;no-divisible por todos menores a n
(define (not-divisible<=i n i)
  (if (= i 1)
      #t
      (and (not-divisible? n i) (not-divisible<=i n (- i 1)))))
;es-primo
(define (es-primo n)
  (not-divisible<=i n (- n 1)))
;todos-primos
;genera una lista con todos los primos de 1 a n, donde n es el único parámetro
(define (todos-primos n)
  (cond [(= n 1) null]
        [(es-primo n) (cons n (todos-primos (- n 1)))]
        [(not (es-primo n)) (todos-primos (- n 1))]))

;co-primos


;Listas planas

; min
(define (count li)
  (if (null? li)
      0
      (+ 1 (count (cdr li)))))
; max
(define (max li)
  (cond [(null? li) #f]
        [(= 1 (count li)) (car li)]
        [else (if (> (car li) (max (cdr li)))
                  (car li)
                  (max (cdr li)))]))

; min
;LOL (igual que el de arriba)

; reversa
(define (reversa li)
  (if (empty? li)
      '()
      (append (reversa (cdr li)) (list (car li)))))

; nth
(define (nth li n)
  (cond [(empty? li) (display "meh")]
        [(= n 0) (car li)]
        [else (nth (cdr li) (- n 1))]))
        
; take
(define (take n li)
  (cond [(empty? li) '()]
        [(= n 0) '()]
        [else (cons(car li)) (take (- n 1) (cdr li))]))

; drop
; TAREA

; repeat
(define (repeat x n)
  (cond [(<= n 0) '()]
        [#t (cons x (repeat x (- n 1)))]))

; range

; split

; palindrome


;Listas anidadas (ímbricas)

; count-atoms

; count-atom-occurrence

; flatten

; max/min

; sigma


;Primer orden

; map

; filter

; fold

