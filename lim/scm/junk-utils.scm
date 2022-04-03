
(include "~~lib/_gambit#.scm")
(include "~~lib/_thread#.scm")
(include "~~lib/_six/js#.scm")
(include "~~lib/_syntax.scm")

(import (_six js))

(##inline-host-declaration #<<end-of-host-code
  // Defer Scheme code execution until scheme_program_start is called.
  scheme_program_start = @all_modules_registered@;
  @all_modules_registered@ = function () { };
end-of-host-code
)

(declare
 (standard-bindings)
 (extended-bindings)
 (not safe)
 (mostly-fixnum)
 (block)
 )

(##inline-host-statement
 "if (typeof(window) == 'undefined') window = global;")

(define (console-log0 . args)
  (map (lambda (x) (print x " ")) (cons ";;" args))
  (newline))

(define (console-log . args)
  \console.log(";;", `args))


(define (body-html-set! html) \document.body.innerHTML=`html)

(define (fetch-json url)
  \fetch(`url).then(function (r) { return r.json(); }))

(define (later fn #!optional dt)
  (##thread-sleep! (or dt 2))
  (##thread fn)
  (##thread-yield!))

(##inline-host-statement "later = @1@" later)

;;;============================================================================

  
(define (scale-element el)
  (console-log "scale" el)
  (if (not el)
      (console-log "null element")
    (when (or (number? el) (string? el))
      (set! el (get-element el))
      (##inline-host-statement "(@1@).style.transform = 'scale(.1)'" el))))

(define (get-element id)
  (##inline-host-expression "(document.getElementById(@1@))" id))

(define (remove-element elt)
  (console-log "remove-element:" elt)
  (##inline-host-statement "@1@.remove()" elt))


(##inline-host-statement "get_element = @1@" get-element)
(##inline-host-statement "scale_element = @1@" scale-element)
(##inline-host-statement "remove_element = @1@" remove-element)


(define (rem id)
  (##inline-host-statement
   "let el=document.getElementById(@1@);
    if (el) {
      el.style.opacity = 0;
      setTimeout(()=>el.remove(), 1000);
    }" id))

(define (unmsg i)
  (println "unmsg " i)
  (rem i))

(define (transient-message text id) 
;;  (let ((i id))
;;    (##thread (lambda () (##thread-sleep! 10) (unmsg i)))
;;    (##thread-yield!))
  \document.getElementById("msgs").insertAdjacentHTML("beforeend", 
                                    "<div class=transient id=" + `id + ">" +
                                    `text + " " + `id + "<div>"))


;(define revision \App.version.revision)
;(define lastmod  \App.version.lastmod)

(console-log "version info:"  revision " " lastmod)

#|
(##thread 
 (lambda ()
   (let loop ((i 0))
     (##thread-sleep! 3)
     (transient-message ":" i)
     (##thread-yield!)
     (loop (+ i 1)))))
|#

(##inline-host-statement "transient_message = @1@" transient-message)
(##inline-host-statement "unmsg = @1@" unmsg)

(define (eval-string string)
  (eval (call-with-input-string string read)))

(define *history* (list))

(define *lastval* "initial")
(define *vals* '())

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


(define (eval-print-string string)
  (push! string *history*)
  (with-output-to-string
    (lambda ()
      (with-exception-handler
       (lambda (e)
         (pretty-print
          (cons 'repl-exception e)))
       (lambda ()
         (let ((val (eval-string string)))
           (console-log0 (list "val" val))
           (set! *lastval* val)
           (push! val *vals*)
           (pretty-print val)))))))

(define (pps string)
  (with-output-to-string
    (lambda ()
      (pretty-print string))))

(define (js-eval str)
  (##inline-host-statement "console.log('eval', _scm2host(@1@))" str)
  (##inline-host-statement "eval(_scm2host(@1@))" str))

(##inline-host-statement "eval_string = @1@;" eval-string)
(##inline-host-statement "eval_print_string = @1@;" eval-print-string)
(##inline-host-statement "host_eval = @1@;" ##host-eval)
(##inline-host-statement "js_eval = @1@;" js-eval)


(define (lookto x)
  (##inline-host-statement "lookto(obj(@1@))" x))
(##inline-host-statement "looky = @1@;" lookto)

(define (sobjs . args)
  (if (and args (pair? args))
      (##inline-host-statement "objs(@1@)" (car args))
    (##inline-host-statement "objs()")))

(define (sobjs0)
  (##inline-host-statement "window.xx = c.objects()"))

(define (sobj pat)
  (##inline-host-expression "obj(@1@)" pat))

(define (objtag obj)
  (##inline-host-expression "objtag(@1@)" obj))

(define (set-composer val)
  (##inline-host-expression "app.composer = @1@ ? app.composer0() : null" val))

(define (h2s obj)
  (##inline-host-expression "@host2scm@(@1@)" obj))

(define (s2h obj)
  (##inline-host-expression "@scm2host@(@1@)" obj))


(define (recell name)
  (##inline-host-expression "recell(@1@)" name))

(define (home)
  (##inline-host-expression "app.home()"))

(define (vec3 . args)
  (##inline-host-expression "vec3()"))

(define (frob obj slot)
  (##inline-host-expression "@1@[@2@]" obj slot))

(define (slot obj key)
  (##inline-host-expression "(window[@1@])[@2@]" obj key))

(define (set-slot! obj key val)
  (##inline-host-expression "(window[@1@])[@2@] = @3@" obj key val))

(define (call obj meth . args)
  (##inline-host-expression "(window[@1@])[@2@]()" obj meth))


(##inline-host-statement "sobjs = @1@;" sobjs)
(##inline-host-statement "sobjs0 = @1@;" sobjs0)
(##inline-host-statement "sobj = @1@;" sobj)
(##inline-host-statement "sobj0 = @1@;" sobj0)
(##inline-host-statement "s2h = @1@;" s2h)
(##inline-host-statement "h2s = @1@;" h2s)
(##inline-host-statement "println = @1@;" println)


(define (fib x)
  (if (< x 2)
    x
    (+ (fib (- x 1)) (fib (- x 2)))))

(define (ffib x)
  (if (fx< x 2)
    x
    (fx+ (ffib (fx- x 1)) (fib (fx- x 2)))))

(define (timing thunk . args)
  (let* ((t0 (cpu-time))
         (val (apply thunk args)))
    (println (- (cpu-time) t0))
    val))

(##inline-host-statement "fib = @1@;" fib)
(##inline-host-statement "ffib = @1@;" ffib)


(define (hack-later hack)
  (##thread-start!
   (##make-thread
    (lambda ()
      (##thread-sleep! 2)
      (console-log "hack:" (hack))))))

(##define-syntax define-syntax
  (lambda (src)
    (##include "~~lib/_syntax.scm")
    (syntax-case src ()
      ((_ id fn)
       #'(##define-syntax id
           (##lambda (##src)
             (##include "~~lib/_syntax.scm")
             (fn ##src)))))))

(define-syntax while
  (lambda (src)
    (syntax-case src ()
      ((_ expr body ...)
       #'(let while-loop () (if expr (begin body ... (while-loop))))))))

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
  (console-log "DOSHIT" (##system-version-string))
  (##start-callback-loop-thread)
  (##callback-loop))

(define bink
  (let ((n 0))
    (lambda ()
      (##inline-host-statement "console.log('fuckit',xx)")
      (console-log "bink" n)
      (console-log "bink" (##inline-host-statement "44"))
      (console-log "bink" (##inline-host-statement "[1,2,3]"))
      (console-log "bink" (##inline-host-statement "@host2scm@(44)"))
      (console-log "bonk" n)
      (set! n (+ n 1)))))

(##inline-host-statement "bink = @1@;" bink)
(##inline-host-statement "doshit = @1@;" doshit)



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

(define (doop)
  (dotimes (i 10) (println i)))

