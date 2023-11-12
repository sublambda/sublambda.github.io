
(declare
 (extended-bindings)
 (standard-bindings)
 (block) ;need this
 )

(import (_six js))
(import (srfi 28))                      ;format
(import (srfi 69))                      ;hashtables
;(import _match)

(include "~~lib/_gambit#.scm") ;; for macro-check-string, macro-absent-obj, etc
(include "macros.scm")

(define window \window)

;;; foreign imports 
(define (is-embedded?)
  (eq? (slot window _embedded:) #t))

(define objs \objs)
(define objname \objname)

(define lookto \lookto)
(define slide \slide)
(define roty \roty)
(define rot \rot)
(define grow \grow)
(define sogltf \sogltf)
(define wireframe \wireframe)
(define makeobj \makeobj)
(define killobj \killobj)
(define objsend \objsend)
(define viewpub \viewpub)
(define obj \obj)
(define getobj \getobj)
(define vobj \vobj)
(define vo vobj)

(define setdata \setdata)
(define setpos \setpos)
(define setpqs \setpqs)
(define setquat \setquat)
(define setscale \setscale)
(define model-setpos \model_setpos)
(define model-setpqs \model_setpqs)
(define model-setquat \model_setquat)
(define model-setscale \model_setscale)

(define restorescene \restorescene)
(define savescene \savescene)


(define (extern name obj)
  \ (window[`name] = `obj))

(define (nerk . args)
  \console.log.apply(null, `(cons "[nim]" args)))

(define (now)
  \Date.now())

(define (datestring)
  \new Date().toLocaleString())


(define (eval-string string)
  (eval (call-with-input-string string read)))
(extern "evalstring" eval-string)

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


(define (set-timeout fn dt)
  \setTimeout(`fn, `dt))

(define (set-interval fn dt)
  \setInterval(`fn, `dt))

(define (clear-interval id)
  \clearInterval(`id))

(define (clear-timeout id)
  \clearTimeout(`id))

(define (later fn)
  \setTimeout(`fn, 0))

(define (scm->js scm)
  (##inline-host-expression "@scm2host@(@1@);" scm))
(define (js->scm js)
  (##inline-host-expression "@host2scm@(@1@);" js))
(define (foreign->js scm)
  (##inline-host-expression "@foreign2host@(@1@);" scm))
(define (js->foreign js)
  (##inline-host-expression "@host2foreign@(@1@);" js))


;;; object/slot access

(define (slot obj key)
  (begin \`obj[`key]))

(define (set-slot obj key val)
  (begin \ (`obj)[`key]=`val))

(define slot! set-slot)

(define (send obj key . args)           ;hmm
  (begin \ (`obj)[`key].apply(`obj,`args)))

;; % in name operates on javascript value
;; %% is 1-1 with js function

(define (isobject? obj)
  ;; \ (`obj) instanceof Object)           ;no, fail(??)
  \ (typeof (`obj) === 'object' && (`obj) != null))


(define %%object-keys \Object.keys)

(define (%object-keys obj)
  (vector->list \Object.keys(`obj)))

(define (%object-values obj)
  (vector->list \Object.values(`obj)))

(define (%object-entries obj)
  (map vector->list
       (vector->list \Object.entries(`obj))))

(define (%object? obj)
  \ (typeof (`obj) === 'object' && (`obj) != null))

(define (%shallow-object->alist obj)
  (%object-entries obj))

(define (%deep-object->alist obj)
  (map (lambda (e)
         (let ((key (car e))
               (val (cadr e)))
           (list key
                 (if (and (%object? val)
                          (not (null? val)))
                     (%object->alist val)
                   val))))
       (%object-entries obj)))

(define %object->alist %deep-object->alist)

(define (%object->hash-table obj)
  (alist->hash-table 
   (%object->alist obj)))

(define (alist->object alist)
  (let ((obj (%new Object)))
    (for-each (lambda (x)
                (slot! obj (car x) (cadr x)))
              alist)
    obj))



;;; dom

(define (makediv id)
  (let ((div (create-element "div")))
    (set-attr div "id" id)
    div))

(define (style div key)
  (begin \ (`div)["style"][`key]))

(define (set-style div key value)
  (begin \ (`div)["style"][`key]=`value))

(define style! set-style)

(define (set-attr elem attr val)
  \ (`elem).setAttribute(`attr, `val))

(define attr! set-attr)


(define (selector sel)
  \document.querySelector(`sel))

(define (create-element type)
  \document.createElement(`type))

(define (append-child elem child)
  \ (`elem).appendChild(`child))

(define (div id)
  \document.createElement("div", `id))


;;;

(define (load-js url #!optional (async? #f))
  (let ((script (create-element "script")))
    (set-attr script "type" "text/javascript")
    (let ((mut (or async?
                   (let ((mut (make-mutex)))
                     (mutex-lock! mut)
                     mut))))
      (or async?
          \ (`script).onload=`(lambda args (mutex-unlock! mut)))
      (set-attr script "src" url)
      (append-child \document.head script)
      (or async?
          (begin
            (mutex-lock! mut)
            (mutex-unlock! mut))))))

'(define-syntax future
  (lambda (stx)
    (syntax-case stx ()
      ((future expr)
       #'(thread (lambda () expr))))))


(define (import-from mod prefix name)
  (let ((nm (string-append prefix name)))
    (begin \window[`nm]=`mod[`name])))

(define (intern-from-module mod prefix)
  (map (lambda (e)
         (let* ((k (car e))
                (v (cadr e))
                (tn (string-append prefix k)))
           (import-from mod prefix k)))
       (entries mod)))


;;; weird workaround for new invocation (parsing?)
(##inline-host-declaration
 "_new = (clas,...args) => new clas(...args)")

(##inline-host-declaration
 "_newx = (clas,...args) => (console.log('_newx',clas), new clas(...args))")


;;; inline-host-expression with return type conversion

(define-macro (-hexpr e)
  `(##inline-host-expression
    ,(string-append "@host2scm@(" e ")")))

(define-macro (-newexpr . args)
  `(##inline-host-expression
    ,(string-append "@host2scm@(new" args ")")))



(define (scm2host-expression e)
  (##inline-host-expression "@scm2host@(@1@)" e))

(define (host2scm-expression e)
  (##inline-host-expression "@host2scm@(@1@)" e))


(define (vec3 #!optional (x 0) (y 0) (z 0))
  (%new THREE.Vector3 x y z))

(define (clearcache)                    ;for wkwebkit
  (send lim clearcache:))

(define (scene)
  (slot lim scene:))

(define (scene-add obj)
  (send (scene) add: obj))

(define (composer val)
  (slot! lim composer: (if val (send lim composer0:) 0)))

(define (obj-name obj)
  (slot obj name:))


;;; ui junk

(define (addbutton name fn)
  (append-child (selector "#leftbuttons") (button name fn)))

(define (button name fn)
  (let ((b (create-element "div")))
    (set-attr b "id" name)
    (set-attr b "class" "bttn")
    (set-style b "transformOrigin" "top left")
    (set-style b "transition" "1s")
    (slot! b innerHTML: name)
    (send b addEventListener: "click"
          (lambda (e)
            (fn e)))
    b))

(define (nbutton name fn)
  (let ((b (create-element "div")))
    (attr!  b "id" name)
    (attr!  b "class" "bttn")
    (style! b "transformOrigin" "top left")
    (style! b "transform" "scale(5)")
    (style! b "transition" "1s")
    (slot! b innerHTML: name)
    (send b addEventListener: "click"
          (lambda (e) (fn e) (style! b "transform" "scale(1)")))
    b))

(define (button-text! button text)
  (slot! button innerHTML: text))
                
(define nfib
  (lambda (n)
	(if (< n 2)
		n
	  (+ (nfib (- n 1))
		 (nfib (- n 2))))))

(define *limina-revision* "limina revision: 880")

(define (getauth)
  \getAuth())

(define (getuser)
  (slot "currentUser" (getauth)))

(define (dbwrite key val)
  (set! *dbkv* (list key val))
  ;;(\_dbwrite key val)
  )

;;;

(define (apropos-to-string sym)
  (let ((s (open-output-string)))
    (##apropos sym s)
    (close-output-port s)
    (get-output-string s)))


(define (show str)
  (##inline-host-statement "console.log(@scm2host@(@1@));" str))

(define (date)
  (##inline-host-expression "@host2scm@(new Date())"))


;(##inline-host-statement "cls = class { bloop(){console.log('asdf');} }")
;(##inline-host-statement "xx = @1@ = class { bloop(){console.log('@1@');} }" "bum")


(##inline-host-statement
"function newclass(parent, methodname) {
  return class extends parent { [methodname]() {console.log('burp');} }
}")

(define (mkclass parent meth)
  (##inline-host-expression "(newclass(@1@, @2@))" parent meth))
   

(define (home)
  (send lim home:))


;;(##inline-host-statement
;; "(@1@().then(x => window.xx = x))" mumble)



(define (ls-getitem name)
  \localStorage.getItem(`name))
(extern "ls_getitem" ls-getitem)

(define (ls-setitem name val)
  \localStorage.setItem(`name, `val))
(extern "ls_setitem" ls-setitem)



;;; UI stuff

(define (toarray obj)
  (send obj toArray:))

(define nbonk 0)

(define (bonk . args)
  (let* ((b (box .1 .1 .1))
         (mat (slot b material:))
         (color (slot mat color:)))
    (send color setHex: #x111111)
    b))
(extern "bonk" bonk)

(addbutton "1"
           (lambda (e)
             (let* ((cam (slot lim camera:))
                    (cp (toarray (slot cam position:)))
                    (cq (toarray (slot cam quaternion:))))
               (pp (list cp cq))
               (set! nbonk (+ nbonk 10))
               (makeobj (format "bonk-~a" nbonk) "bonk"
                        (lambda (obj)
                          (setpos obj cp)
                          (setquat obj cq))))))
                            
(define (dtube #!optional model)
  (let ((dt (tube model)))
    (slot! dt radius: .1)
    dt))
(extern "dtube" dtube)

(addbutton "2"
           (lambda (e)
             (let* ((cam (slot lim camera:))
                    (pos (slot cam position:))
                    (cp (toarray pos))
                    (dtube (obj "dtube"))
                    (data (slot dtube data:))
                    (spine (slot data spine:)))
               (set! spine (if (vector? spine)
                               (cons cp (vector->list spine))
                             (list cp)))
               (slot! data spine: spine)
               (setdata dtube data))))

(addbutton "3"
           (lambda (e)
             (if (truthy? (slot lim composer:))
                 (composer #f)
               (composer #t))))

(addbutton "4" (lambda (e)
                 ;;(tar f1: .01)
                 (send lim toggleimage:)))

(define sball \sball)

(addbutton "5" (lambda (e)
                 (hey 5)
                 (let* ((cam (slot lim camera:))
                        (pos (slot cam position:))
                        (ob (obj "sf"))
                        (vob (send ob viewobj:))
                        (data (slot ob data:))
                        (points (slot data points:)))
                   (hey "sball" pos (vector? points) points)
	               (if (vector? points)
                       (set! points (vector-append
                                     points
                                     (vector (send pos toArray:))))
                     (set! points (vector (send pos toArray:))))
                   (setdata ob (alist->object `((points: ,points))))
                   (sball vob (slot pos x:) (slot pos y:) (slot pos z:) 2)
                   ob)))
                   
                            
(define (scene-children)
  \lim.scene.children)

(define (exportmap id)
  \lim.exportmap(`id))

(define (importmap id)
  \lim.importmap(`id))

(define (savemap id)
  \lim.savemap(`id))

(define (restoremap id)
  \lim.restoremap(`id))
