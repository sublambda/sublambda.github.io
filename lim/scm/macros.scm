
(declare
  (extended-bindings)
  (standard-bindings)
  (mostly-fixnum)
;  (not inline)
  (block))

;(_define-library/define-library-expand#debug-expansion?-set! #t)

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



#|

(define-syntax while-
  (lambda (src)
    (syntax-case src ()
      ((_ expr body ...)
       #'(let loop () (if expr (begin body ... (loop))))))))



(define-macro (%hexpr e)
  `(##inline-host-expression
    ,(string-append "@host2scm@(" e ")")))


(define (--send obj key . args)
  (println "--send " obj " " key " " args)
  (begin \ (`obj)[`key].apply(`obj,`args)))
    

(define-macro (-send obj key . args)
  (let ((key (if (string? key)
                 key
               (object->string key))))
    `(--send ,obj ,key . ,args)))
    
|#
