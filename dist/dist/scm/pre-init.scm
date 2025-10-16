(declare
 (extended-bindings)
 (standard-bindings)
 (block))

(define (nerk . args)
  \ (console.log.apply(null, `(cons "[INIT]" args))))

(##debug-modules?-set! #t)

;;(load "~~/scm/util.o1")
;;(load "~~/scm/objs.o1")

(define (gambit-log-function . args)
  (println (cons ";;; " (map (lambda (x) (list x " ")) args)))
  (force-output)
  (repl-move-to-end))

;;; gambit-log-function will be called by console.log replacemnet
\ (window.gambit_log_function = `gambit-log-function)

(define (include-macros)
  (eval '(include "~~/scm/macros.scm")))

(define (include-imports)
  (eval '(include "~~/scm/imports.scm")))

(define (include-stuff)
  (include-macros)
  (include-imports))
`
(nerk "pre-init" "done")
