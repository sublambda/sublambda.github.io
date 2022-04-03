(import (_six js))
(import (srfi 1))                       ;lists/iota
(import (srfi 69))                      ;hashtables


(include "~~lib/_gambit#.scm")
;(include "~~lib/_thread#.scm")
;(include "~~lib/_six/js#.scm")
;(include "~~lib/_syntax.scm")

'(declare
  (extended-bindings)
  (standard-bindings)
  (mostly-fixnum)
  (not inline)
  (block))

(declare
  (extended-bindings)
  (standard-bindings)
  (mostly-fixnum)
  ;;(not inline)
  (block)
  )




(define (nerk . args)
  \console.log.apply(null, `(cons ";; [lim]" args)))

(define lim \lim)

(define (new-repl id)
  (let ((div (create-element "div")))
    (set-attr div "id" id)
    (set-attr div "class" "repldiv")
    (append-child (select "body") div)
    div))

(define (native-limina-constructor div cell)
  (begin \_new(exports.LIMINA.Lim, `div, `cell)))

(define (new-limina id #!optional (cell "l0"))
  (let ((div (create-element "div")))
    (set-attr div "id" id)
    (set-attr div "class" "panel")
    (append-child (select "body") div)
    (let ((lim (native-limina-constructor div cell)))
      (hacky-thread (lambda ()
                      (thread-sleep! 1)
                      (nerk "home")
                      (call lim home:)))
      (nerk "lim" lim)
      lim)))


(define (div id)
  (let ((div (create-element "div")))
    (set-attr div "id" id)
    div))

(define (limina-div id)
  (let ((div (create-element "div")))
    (set-attr div "id" id)
    (set-attr div "class" "panel")
    (append-child (select "body") div)
    div))


(define (slot obj key)
  (begin \`obj[`key]))

(define (slot! obj key val)
  (begin \ (`obj)[`key]=`val))

(define (set-slot! obj key val)
  (begin \ (`obj)[`key]=`val))

(define (call obj key . args)
  (begin \ (`obj)[`key].apply(`obj,`args)))

(define (send obj key . args)           ;hmm
  (begin \ (`obj)[`key].apply(`obj,`args)))

(define-syntax -call
  (syntax-rules ()
    ((_ obj key . args)
     \ (`obj)[`key].apply(`obj,`args))))




;;; dom

(define (get-style div key)
  (begin \ (`div)["style"][`key]))

(define (set-style! div key value)
  (begin \ (`div)["style"][`key]=`value))

(define (select selector)
  \document.querySelector(`selector))

(define (create-element type)
  \document.createElement(`type))

(define (set-attr elem attr val)
  \ (`elem).setAttribute(`attr, `val))

(define (append-child elem child)
  \ (`elem).appendChild(`child))

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

(define-syntax future
  (lambda (stx)
    (syntax-case stx ()
      ((future expr)
       #'(thread (lambda () expr))))))

;; % in name operates on javascript value
;; %% is 1-1 with js function

(define %%object-keys \Object.keys)

(define (%object-keys obj)
  (vector->list \Object.keys(`obj)))

(define (%object-values obj)
  (vector->list \Object.values(`obj)))

(define (%object-entries obj)
  (map vector->list
       (vector->list \Object.entries(`obj))))

(define (%object? obj)
  \ (typeof (`obj) === 'object' && `obj != null))

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

;; % prefix operates on native object

;;function(){let x=`x && return new(x)}())))

(define-syntax -new
  (syntax-rules ()
    ((_ x)
     \_new(x))
    ((_ x a)
     \_new(x,`a))
    ((_ x a b)
     \_new(x,`a,`b))
    ((_ x a b c)
     \_new(x,`a,`b,`c))
    ((_ x a b c d)
     \_new(x,`a,`b,`c,`d))
    ((_ x a b c d e)
     \_new(x,`a,`b,`c,`d,`e))))

(define-syntax --new
  (syntax-rules ()
    ;; why isn't first arg backquoted?
    ((_ x)
     \ new x())
    ((_ x a)
     \ new x(`a))
    ((_ x a b)
     \ new x(`a,`b))
    ((_ x a b c)
     \ new x(`a,`b,`c))
    ((_ x a b c d)
     \ new x(`a,`b,`c,`d))
    ((_ x a b c d e)
     \ new x(`a,`b,`c,`d,`e))
    ((_ x a b c d e f)
     \ new x(`a,`b,`c,`d,`e,`f))
    ((_ x a b c d e f g)
     \ new x(`a,`b,`c,`d,`e,`f,`g))))


(define (box x y z)
  (let* ((b (-new THREE.BoxBufferGeometry x y z))
         (m (-new THREE.MeshPhysicalMaterial))
         (mesh (-new THREE.Mesh b m)))
    (send (slot m color:) setHex: #x334444)
    (slot! m opacity: 0.3)
    (slot! m transparent: #t)
    (send (slot mesh position:) set: 2 1 0)
    (call (slot mesh rotation:) set: 10 10 10 10)
    mesh))

(define (vec3 #!optional (x 0) (y 0) (z 0))
  (-new THREE.Vector3 x y z))

(##inline-host-declaration
 "class foo { constructor(x,y,z) { console.log('FO',x,y,z) } }")



;;; inline-host-expression with return type conversion
(define-macro (-hexpr e)
  `(##inline-host-expression
    ,(string-append "@host2scm@(" e ")")))

(define-macro (-newexpr . args)
  `(##inline-host-expression
    ,(string-append "@host2scm@(new" args ")")))


(define (kball)
  (let* ((geom (-new THREE.SphereBufferGeometry r 12 12))
         (mat (-new THREE.MeshPhysicalMaterial (-hexpr "{ color:0x404444 }")))
         (mesh (-new THREE.Mesh geom mat)))
    ;(slot! mat envMap: (slot lim envmap:))
    (slot! mat wireframe: #t)
    (slot! mesh receiveShadow: #t)
    (slot! mesh castShadow: #t)
    (slot! mesh tag: "kball")
    mesh))
(register-fn "kball" kball)

(define (kbox)
  (let ((b (pbox)))
    (slot! b tag: "kbox")
    b))

(register-fn "kbox" kbox)

(define (pbox)
  (let* ((b (-new THREE.BoxGeometry 1 1 1))
         (m (-new THREE.MeshPhysicalMaterial
                  (-hexpr "{color: 0x445555, opacity: 0.8,
                             transparent: true}")))
         (mesh (-new THREE.Mesh b m)))
    (slot! mesh receiveShadow: #t)
    (slot! mesh castShadow: #t)
    (slot! mesh tag: "pbox")
    mesh))

(register-fn "pbox" pbox)

(define sogltf \sogltf)
(define wireframe \wireframe)

(register-fn "lowalk" 
             (lambda ()
               (let ((mesh (sogltf "lowalk")))
                 (slot! mesh onload:
                        (lambda () (wireframe mesh #f)))
                 mesh)))

(define (qbox)
  (let* ((b (-new THREE.BoxGeometry 1 .05 .05))
         (m (-new THREE.MeshPhongMaterial
                  (-hexpr "{color: 0x00ff00, \
                            opacity: 0.5, \
                            transparent: true}")))
         (mesh (-new THREE.Mesh b m)))
    (slot! mesh tag: "qbox")
    mesh))
(register-fn "qbox" qbox)

(define (dipshit)
  (let* ((h (htmlbox))
         (seturl (lambda () ((slot h seturl:) "tmp/foo.html"))))
    ;; hmm, problems with synchronous updates
    (later seturl)
    h))

(register-fn "dipshit" dipshit)

(define (htmlbox)
  (let* ((canvas (create-element "canvas"))
         (ctx (send canvas getContext: "2d"))
         (tex (-new THREE.CanvasTexture canvas))
         (box (-new THREE.BoxBufferGeometry 1 1 .01))
         (mat (-new THREE.MeshBasicMaterial
                    (-hexpr "{transparent: true, opacity: 1}")))
         (mesh (-new THREE.Mesh box mat))
         (w 1024)
         (h 1024)
         (clearfn (lambda ()
                    (call ctx clearRect: 0 0 w h)))
         (upfn (lambda (rendered)
                 (slot! tex needsUpdate: #t)))
         (drawfn (lambda (rendered)
                    (clearfn)
                    (call ctx drawImage: (slot rendered image:) 0 0)
                    (upfn rendered))))
    (slot! mat map: tex)
    (slot! canvas width: w)
    (slot! canvas height: h)
    (slot! mesh canvas: canvas)
    (slot! mesh castShadow: #t)
    (slot! mesh sethtml:
           (lambda (html)
             \rasterizeHTML.drawHTML(`html,`canvas).then(`drawfn).then(`upfn)))
    (slot! mesh seturl:
           (lambda (url)
             ;;(nerk "seturl" url)
             (clearfn)
             \rasterizeHTML.drawURL(`url,`canvas).then(`upfn)))
    (slot! mesh tag: "htmlbox")
    mesh))

(define (points)
  (define (r)
    (* (- (random-real) .5) 10))
  (define (gen-positions)
    [])
  (define (gen-colors)
    [])
  (let ((geom (-new THREE.BufferGeometry))
        (positions (gen-positions))
        (colors (gen-colors)))
    (send geom setAttribute position:
          (-new THREE.Float32BufferAttribute positions 3))
    (send geom setAttribute color:
          (-new THREE.Float32BufferAttribute colors 3))
    (let ((tex (send (-new THREE.TextureLoader) load: "tmp/disc.png"))
          (mat (-new THREE.PointsMaterial 
                     (-hexpr "{size: .03,
                               depthWrite: false,
                               blending: THREE.AdditiveBlending,
                               vertexColors: true,
                               transparent: true
                               }")))
          (points (-new THREE.Points geom mat)))
      (slot! mat map: tex)
      (slot! points tag: "points")
      points)))

(define (raymarcher)
  (define (r)
    (* 2 (- (random-real) .5)))
  (define (gen-layer) 
    (-hexpr 
     "{
        color: new Color(g-.0,g,g),
        operation: operations.union,
        position: new Vector3(p(),p(),p()),
        rotation: (new Quaternion())
          .setFromAxisAngle(new Vector3(r(),r(),r(),r()))
        scale: new Vector3(...(s=.8,[s,s,s])),
        shape,
      }"))
  (let ((rm (-new Raymarcher
                  (-hexpr "{
                            conetracing: true,
                            resolution: .3,
                            blending: .2,
                            roughness: 1,
                            metalness: .8,
                            envMapIntensity: .7,
                           }"))))
    (slot! rm layers: (gen-layers))
    rm))


;; clunky ff registry
(define (register-fn name fn)
  (begin \foreign_fns[`name]=(`fn)))


(define (scm2host-expression e)
  (##inline-host-expression "@scm2host@(@1@)" e))

(define (host2scm-expression e)
  (##inline-host-expression "@host2scm@(@1@)" e))


(define (scene)
  (slot lim scene:))

(define (scene-add obj)
  (send (scene) add: obj))

(define (composer val)
  (slot! lim composer: (if val (send lim composer0:) 0)))


(define (obj x)
  \lim.cell.obj(`x))

(define (objs x)
  \lim.cell.objs(`x))


(define *limina-revision* "limina revision: 385")

(define (timo0 fn)
  \setTimeout(`fn, 0))

(define (timo fn)
  (declare 
    (interrupts-enabled) 
    (not extended-bindings)
    (not run-time-bindings))
  \setTimeout(`fn, 0))
