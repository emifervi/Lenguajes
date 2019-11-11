#lang racket

;1 GCD Euclidian algorithm
(define (gcd-euclid a b)
  (if (= b 0)
      a
      (gcd-euclid b (modulo a b))))

;2 coprime
(define (coprime? a b)
  (if (= (gcd-euclid a b) 1) #t #f))

;5 cuenta atomos
(define (cuenta-atomos li)
  (cond [(null? li) 0]
        [(list? (car li)) (+ (cuenta-atomos (car li)) (cuenta-atomos (cdr li)))]
        [(+ 1 (cuenta-atomos (cdr li)))]))

;3 media mediana moda

;sum
(define (sumalista li)
  (if (null? li) 0
      ( + (car li) (sumalista (cdr li)))))

;media
(define (media li)
  (/ (sumalista li) (cuenta-atomos li)))

;mediana
(define (mediana li)
  (cond [(null? li) #f]
        [(= 0 (modulo (cuenta-atomos li) 2))
         (/ ( + (list-ref (sort li <) (exact-floor (/ (cuenta-atomos li) 2)))
                (list-ref (sort li <) (exact-floor (/ (- (cuenta-atomos li) 1) 2))))2)]
        [else (list-ref (sort li <) (floor (/ (cuenta-atomos li) 2)))]))
          
;moda
(define (moda li)
  (define vals (make-hash))
  (for ([elem li])
    (hash-update! vals elem (lambda (app) (+ 1 app)) 0))
  (car (argmax cdr (hash->list vals))))

; stats
(define (m-m-m li)
  (cons (media li) (cons (mediana li) (cons (moda li) null))))

;4 rango
(define (rango min max)
  (if (= min max)
      (cons min null)
      (cons min (rango (+ min 1) max))))

;6 toma
(define (toma-h li n c)
  (if (= c n)
      null
      (cons (car li) (toma-h (cdr li) n (+ c 1)))))

(define (toma li n)
  (cond [(null? li) (error "lista vacia")]
       [(< (cuenta-atomos li) n) (error "n mayor a la cantidad de elementos en li")]
       [(toma-h li n 0)]))

;7 deja
(define (deja-h li n c)
  (if (= c n)
      li
      (deja-h (cdr li) n (+ c 1))))

(define (deja li n)
  (cond [(null? li) (error "lista vacia")]
        [(< (cuenta-atomos li) n) (error "n mayor a la cantidad de elementos en li")]
        [(deja-h li n 0)]))

;poplast
(define (pop_last li)
  (if (null? (cdr li))
      null
      (cons (car li) (pop_last (cdr li)))))

;8 split
(define (my-split li pivot)
  (cond [(null? li) '()]
        [(> pivot (cuenta-atomos li)) (error "pivote mayor a lista")]
        [(cons (pop_last (toma li pivot)) (cons (deja li pivot) '()))]))