(declare
  (extended-bindings)
  (standard-bindings)
  (not inline)
  (block))

(import (_six js))

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



(define (include-macros)
  (eval '(include "~~/scm/macros.scm")))

(define (set-timeout fn dt)
  \setTimeout(`fn, `dt))

;;; thread wrapper to conclude with hacky callback thread hack
(define (hacky-thread fn)
  (thread 
   (lambda ()
     (fn)
     (callback-thread-hack))))

(define (later fn)
  \setTimeout(`fn, 0))

