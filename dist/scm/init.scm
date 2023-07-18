(declare
 (extended-bindings)
 (standard-bindings))

(define uptime \uptime)
(uptime "init")

(define (nerk . args)
  \ (console.log.apply(null, `(cons "[INIT]" args))))

(##debug-modules?-set! #t)
;;(module-search-order-add! ".")

;; import preloads 
;; (load .o1 to prevent probing for newer versions)
;;(load "~~/scm/nlibs.o1")
(load "~~/scm/util.o1")
(load "~~/scm/objs.o1")

(define (load-nlibs)
  (load "~~/scm/nlibs.o1"))

(define (gambit-log-function . args)
  (println (cons ";;; " (map (lambda (x) (list x " ")) args)))
  (force-output)
  (repl-move-to-end))

;;; gambit-log-function will be called by console.log replacemnet

\ (window.gambit_log_function = `gambit-log-function)


(define *repl* \repl)

(define (repl-append s)
  (send *repl* append: s))

(define (repl-move-to-end)
  (repl-append ""))

(define (repl-focus)
  (send *repl* focus:))


(define lim #f)

(define (nlim)
  (if lim (send lim unload:))
  (let ((nl \nlim()))
    (set! lim nl)
    nl))

(define (unload lim)
  (send lim unload:))

;(addbutton "@" (lambda (e) (nlim)))

(define (include-macros)
  (eval '(include "~~/scm/macros.scm")))

(define (include-imports)
  (eval '(include "~~/scm/imports.scm")))

(define (include-stuff)
  (include-macros)
  (include-imports))

(extern "includestuff" include-stuff)

;;(slot! (slot lim floor:) visible: #f)


(uptime "init2")
(nlim)
(uptime "init3")

