'(declare
  (extended-bindings)
  (standard-bindings)
  (mostly-fixnum)
  (not inline)
  (block))

(define t0 \t0)

(define (now)
  \Date.now())

(define (nerk . args)
  \console.log.apply(null, `(cons ";; [init]" args)))

;;(nerk "vm start" (- (now) t0))

(load "~~/scm/util.o1")
(load "~~/scm/limina.o1")
(include "~~/scm/macros.scm")


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

(define *callback-thread* #f)
(define *dead-callback-threads* '())

;;; this is a hack to compensate for threa scheduler breakage
;;; threads should call this at end
(define (callback-thread-hack)
  ;; terminate previous (presumed crippled?) callback thread
  (if *callback-thread*
      (begin 
        (thread-terminate! *callback-thread*)
        (set! *dead-callback-thread*
          (cons *callback-thread*
                *dead-callback-threads*))))
  (set! *callback-thread* (##start-callback-loop-thread))
  *callback-thread*)

(begin \repl.after_init())


;;(trace thread)

(define (repl-move-to-end)
  \ repl.append(""))

(define (logfn . args)
  (apply print
         (apply append
                (map (lambda (x) (list x " ")) args)))
  (newline)
  (force-output)
  (repl-move-to-end))

;;; logfn will be called by console.log replacemnet

\window.logfn=`logfn


(define c \c)
(define getcell \getcell)
(define setcell \setcell)
(define recell \recell)

(define lookto \lookto)
(define slide \slide)
(define grow \grow)


(define junk \junk)

\ fn=`(lambda () (println ";foo"))

(define bg (host-eval "() => setTimeout(fn,0)"))
