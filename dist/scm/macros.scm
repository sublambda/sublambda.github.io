
;;(import (_six js))
;;(import (srfi 1))                       ;lists/iota
;;(import (srfi 48))                      ;format
;;(import (srfi 69))                      ;hashtables


(declare
  (extended-bindings)
  (standard-bindings)
  (mostly-fixnum)
  (block)
  )

;;; weird workaround for new invocation (parsing?)
;;; defined in util.scm
;;; (##inline-host-declaration
;;;   "_new = (clas,...args) => new clas(...args)")

(define -new \_new)

(define-syntax %new
  (syntax-rules ()
    ((_ x)
     \_new(x))
    ((_ x a)
     \_new(x,`a))
    ((_ x a b)
     \_new(x,`a,`b))
    ((_ x a b c)
     \_new(x,`a,`b,`c))
    ((_ x a b c d)
     \_new(x,`a,`b,`c,`d))
    ((_ x a b c d e)
     \_new(x,`a,`b,`c,`d,`e))))

(define-syntax %%new
  (syntax-rules ()
    ((_ x cls ...)
     (six.infix
       (six.call
        (six.identifier _new)
        (six.identifier cls)
        ...)))))

(define-syntax %nuu
  (syntax-rules ()
    ((_ cls)
     (##inline-host-expression "_new(@1@)" cls))))

(define-syntax push!
  (syntax-rules ()
    ((_ v p)
     (begin
       (set! p (cons v p))
       v))))

(define-syntax pop!
  (syntax-rules ()
    ((_ l)
     (let ((v (car l)))
       (set! l (cdr l))
       v))))

(define-syntax incf!
  (syntax-rules ()
    ((_ v) (set! v (+ v 1)))
    ((_ v n) (set! v (+ v n)))))

(define-syntax decf!
  (syntax-rules ()
    ((_ v) (set! v (- v 1)))
    ((_ v n) (set! v (- v n)))))



(define-syntax dolist
  (syntax-rules ()
    ((dolist (var list) . body)
     (for-each (lambda (var) . body) list))))

(define-syntax dotimes
  (syntax-rules ()
    ((_ (var count) . body)
     (let* ((n count))
       (let iter ((var 0))
         (when (< var n)
           (begin . body)
           (iter (+ var 1))))))))

(define-syntax while
  (syntax-rules ()
    ((while cond . body)
     (let loop ()
       (when cond
         (begin . body)
         (loop))))))

(define-syntax repeat
  (syntax-rules ()
    ((repeat n . body)
     (dotimes (i n)
       (begin . body)))))


(define-syntax when
  (syntax-rules ()
    ((when cond . body)
     (if cond (begin . body)))))

(define-syntax unless
  (syntax-rules ()
    ((unless cond . body)
     (if (not cond) (begin . body)))))


(define-macro fluid-let
  (lambda (xexe . body)
    (let ((xx (map car xexe))
          (ee (map cadr xexe))
          (old-xx (map (lambda (ig) (gensym)) xexe))
          (result (gensym)))
      `(let ,(map (lambda (old-x x) `(,old-x ,x)) 
                  old-xx xx)
         ,@(map (lambda (x e)
                  `(set! ,x ,e)) 
                xx ee)
         (let ((,result (begin ,@body)))
           ,@(map (lambda (x old-x)
                    `(set! ,x ,old-x)) 
                  xx old-xx)
           ,result)))))


(define-macro defstruct
  (lambda (s . ff)
    (let ((s-s (symbol->string s)) (n (length ff)))
      (let* ((n+1 (+ n 1))
             (vv (make-vector n+1)))
        (let loop ((i 1) (ff ff))
          (if (<= i n)
              (let ((f (car ff)))
                (vector-set! vv i 
                             (if (pair? f) (cadr f) '(if #f #f)))
                (loop (+ i 1) (cdr ff)))))
        (let ((ff (map (lambda (f) (if (pair? f) (car f) f))
                       ff)))
          `(begin
             (define ,(string->symbol 
                       (string-append "make-" s-s))
               (lambda fvfv
                 (let ((st (make-vector ,n+1)) (ff ',ff))
                   (vector-set! st 0 ',s)
                   ,@(let loop ((i 1) (r '()))
                       (if (>= i n+1) r
                         (loop (+ i 1)
                               (cons `(vector-set! st ,i 
                                                   ,(vector-ref vv i))
                                     r))))
                   (let loop ((fvfv fvfv))
                     (if (not (null? fvfv))
                         (begin
                           (vector-set! st 
                                        (+ (list-position (car fvfv) ff)
                                           1)
                                        (cadr fvfv))
                           (loop (cddr fvfv)))))
                   st)))
             ,@(let loop ((i 1) (procs '()))
                 (if (>= i n+1) procs
                   (loop (+ i 1)
                         (let ((f (symbol->string
                                   (list-ref ff (- i 1)))))
                           (cons
                            `(define ,(string->symbol 
                                       (string-append
                                        s-s "." f))
                               (lambda (x) (vector-ref x ,i)))
                            (cons
                             `(define ,(string->symbol
                                        (string-append 
                                         "set!" s-s "." f))
                                (lambda (x v) 
                                  (vector-set! x ,i v)))
                             procs))))))
             (define ,(string->symbol (string-append s-s "?"))
               (lambda (x)
                 (and (vector? x)
                      (eqv? (vector-ref x 0) ',s))))))))))


'(define-syntax foo
  (syntax-rules ()
    ((foo name . rest)
     (let ((q (quote (quote rest))))
       (list 'foo (quote name) (quote rest) (list q q q))))))



