; "dynwind.scm", wind-unwind-protect for Scheme
; Copyright (c) 1992, 1993 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

;This facility is a generalization of Common Lisp `unwind-protect',
;designed to take into account the fact that continuations produced by
;CALL-WITH-CURRENT-CONTINUATION may be reentered.

;  (dynamic-wind <thunk1> <thunk2> <thunk3>)		procedure

;The arguments <thunk1>, <thunk2>, and <thunk3> must all be procedures
;of no arguments (thunks).

;DYNAMIC-WIND calls <thunk1>, <thunk2>, and then <thunk3>.  The value
;returned by <thunk2> is returned as the result of DYNAMIC-WIND.
;<thunk3> is also called just before control leaves the dynamic
;context of <thunk2> by calling a continuation created outside that
;context.  Furthermore, <thunk1> is called before reentering the
;dynamic context of <thunk2> by calling a continuation created inside
;that context.  (Control is inside the context of <thunk2> if <thunk2>
;is on the current return stack).

;;;WARNING: This code has no provision for dealing with errors or
;;;interrupts.  If an error or interrupt occurs while using
;;;dynamic-wind, the dynamic environment will be that in effect at the
;;;time of the error or interrupt.

(define dynamic:winds '())
;@
(define (dynamic-wind <thunk1> <thunk2> <thunk3>)
  (<thunk1>)
  (set! dynamic:winds (cons (cons <thunk1> <thunk3>) dynamic:winds))
  (let ((ans (<thunk2>)))
    (set! dynamic:winds (cdr dynamic:winds))
    (<thunk3>)
    ans))
;@
(define call-with-current-continuation-dw
  (let ((oldcc call-with-current-continuation))
    (lambda (proc)
      (let ((winds dynamic:winds))
	(oldcc
	 (lambda (cont)
	   (proc (lambda (c2)
		   (dynamic:do-winds winds (- (length dynamic:winds)
					      (length winds)))
		   (cont c2)))))))))

(define (dynamic:do-winds to delta)
  (cond ((eq? dynamic:winds to))
	((negative? delta)
	 (dynamic:do-winds (cdr to) (+ 1 delta))
	 ((caar to))
	 (set! dynamic:winds to))
	(else
	 (let ((from (cdar dynamic:winds)))
	   (set! dynamic:winds (cdr dynamic:winds))
	   (from)
	   (dynamic:do-winds to (+ -1 delta))))))

(define gentemp
  (let ((*gensym-counter* -1))
    (lambda ()
      (set! *gensym-counter* (+ *gensym-counter* 1))
      (string->symbol
       (string-append "slib:G" (number->string *gensym-counter*))))))

(define-macro (fluid-let-dw clauses . body)
  (let ((ids (map car clauses))
	    (new-tmps (map (lambda (x) (gentemp)) clauses))
	    (old-tmps (map (lambda (x) (gentemp)) clauses)))
    `(let (,@(map list new-tmps (map cadr clauses))
	       ,@(map list old-tmps (map (lambda (x) #f) clauses)))
       (dynamic-wind
           (lambda ()
	         ,@(map (lambda (ot id) `(set! ,ot ,id))
		            old-tmps ids)
	         ,@(map (lambda (id nt) `(set! ,id ,nt))
		            ids new-tmps))
	       (lambda () ,@body)
	       (lambda ()
	         ,@(map (lambda (nt id) `(set! ,nt ,id))
		            new-tmps ids)
	         ,@(map (lambda (id ot) `(set! ,id ,ot))
		            ids old-tmps))))))




(define *engine-escape* #f)
(define *engine-entrance* #f)

(define (clock-handler)
  (call/cc *engine-escape*))

(define make-engine
  (lambda (th)
    (lambda (ticks success failure)
      (let* ((ticks-left 0)
             (engine-succeeded? #f)
             (result
              (call/cc
               (lambda (k)
                 (set! *engine-escape* k)
                 (let ((result
                        (call/cc
                         (lambda (k)
                           (set! *engine-entrance* k)
                           ;;(clock 'set ticks)
                           (let ((v (th)))
                             (*engine-entrance* v))))))
                   ;;(set! ticks-left (clock 'set *infinity*))
                   (set! engine-succeeded? #t)
                   result)))))
        (if engine-succeeded?
            (success result ticks-left)
            (failure
             (make-engine
              (lambda ()
                (result 'resume)))))))))

(define (frob)
  (let ((engine (make-engine
                 (lambda (#!optional x)
                   (let loop ((i 10))
                     (println i)
                     (if (> i 0)
                         (loop (- i 1))))))))
    (engine 10
            (lambda (#!rest x) (println (cons done: x)))
            (lambda (#!rest x) (println (cons fail: x))))))

