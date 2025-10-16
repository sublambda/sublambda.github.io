(declare
 (extended-bindings)
 (standard-bindings))

(define window \window)

;;(##debug-modules?-set! #t)
;;(module-search-order-add! ".")

;; (load .o1 to prevent probing for newer versions)
(load "~~/scm/util.o1")
(load "~~/scm/objs.o1")

(define *repl* \repl)

;;; gambit-log-function will be called by console.log replacemnet
(define (gambit-log-function . args)
  (println (cons ";;; " (map (lambda (x) (list x " ")) args)))
  (force-output)
  (send *repl* append: ""))
;;\ (window.gambit_log_function = `gambit-log-function)
(slot! window "gambit_log_function" gambit-log-function)


(define lim #f)
(define (nlim)
  (if lim (send lim unload:))
  (let ((nl \nlim()))
    (set! lim nl)
    nl))
(nlim)


;;; junk

(define (orbitcontrols)
  (send lim addorbitcontrols:))

(define (fpcontrols)
  (send lim addfpcontrols:))

(define (include-macros)
  (eval '(include "~~/scm/macros.scm")))

(define (include-imports)
  (eval '(include "~~/scm/imports.scm")))

(define (initmsg msg)
  \console.log(`msg))

(initmsg "init revision: 16")
