(declare
 (extended-bindings)
 (standard-bindings))

(define window \window)
(define uptime \uptime)

(define (set-slot obj key val)
  (begin \ (`obj)[`key]=`val))

(define slot! set-slot)


(define (nerk . args)
  \ (console.log.apply(null, `(cons "[INIT]" args))))

;;(##debug-modules?-set! #t)
;;(module-search-order-add! ".")

(define *repl* \repl)

(define (gambit-log-function . args)
  (println (cons ";;; " (map (lambda (x) (list x " ")) args)))
  (force-output)
  (send *repl* append: ""))

;;; gambit-log-function will be called by console.log replacemnet
;;\ (window.gambit_log_function = `gambit-log-function)

(slot! window gambit_log_function: gambit-log-function)

(uptime "init1")

;; import preloads 
;; (load .o1 to prevent probing for newer versions)
(load "~~/scm/util.o1")
(load "~~/scm/objs.o1")

(define lim #f)

(define (nlim)
  (if lim (send lim unload:))
  (let ((nl \nlim()))
    (set! lim nl)
    nl))

(define (include-macros)
  (eval '(include "~~/scm/macros.scm")))

(define (include-imports)
  (eval '(include "~~/scm/imports.scm")))


(uptime "init2")
(nlim)
(uptime "init3")



(define (orbitcontrols)
  (send lim addorbitcontrols:))
(define (fpcontrols)
  (send lim addfpcontrols:))
