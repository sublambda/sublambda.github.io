
(declare
  (extended-bindings)
  (standard-bindings)
  (not inline)
  (block))

;(_define-library/define-library-expand#debug-expansion?-set! #t)


(define (eval-string string)
  (eval (call-with-input-string string read)))

(define (pps string)
  (with-output-to-string
    (lambda ()
      (pretty-print string))))

(define (timing thunk . args)
  (let* ((t0 (cpu-time))
         (val (apply thunk args)))
    (println (- (cpu-time) t0))
    val))


(define-syntax while-
  (lambda (src)
    (syntax-case src ()
      ((_ expr body ...)
       #'(let loop () (if expr (begin body ... (loop))))))))


;; hack to run thread scheduler, i guess
;; breaks stuff
(define (##start-callback-loop-thread)
  (let* ((tgroup
          (##make-tgroup 'callback-loop #f))
         (callback-loop-thread
          (##make-root-thread
           ##callback-loop
           'callback-loop
           tgroup)))
    (##thread-start! callback-loop-thread)))

(define (doshit)
  (console-log "doshit" (##system-version-string))
  (##start-callback-loop-thread)
  (##callback-loop))


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
(define (doop)
  (dotimes (i 10) (println i)))

(define-syntax fnew
  (syntax-rules ()
    ((new x)
     \_fnew(x))))


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
