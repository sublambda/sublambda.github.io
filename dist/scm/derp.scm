(define *derp* '(

(import (_six js))
(import (srfi 69))                      ;hashtable
(import (srfi 48))                      ;format

(declare
 (extended-bindings)
 (standard-bindings)
;; (mostly-fixnum)
 (block)
 )


(include "macros.scm")

(define (extern name obj)
  \ (window[`name] = `obj))

(define (intern name)
  \ (window[`name] || false))

(define (hey . args)
  ;;(println (format ";;; hey ~s" args))
  \console.warn.apply(null, `(cons "hey" args))
  )
(extern "hey" hey)



(define (ntext #!optional model)
  (let* ((tx (%new troika.Text))
         (set-text (lambda (text)
                     (slot! tx text: text)
                     (send tx sync:))))
    (slot! tx text: ":")
    (slot! tx castShadow: #t)
    ;;(slot! tx receiveShadow: #t)
    (slot! tx font: "./stuff/SpecialElite-Regular.ttf")
    (hey "ntextmat" (slot tx material:))
    (slot! (slot tx material:) transparent: #t)

    (slot! tx outlineColor: #x0)
    (slot! tx outlineOpacity: .8)
    (slot! tx outlineWidth: 0.08)

    (slot! tx fillOpacity: .2)

    (slot! tx strokeColor: #xffffff)
    (slot! tx strokeWidth: .007)
    (slot! tx strokeOpacity: .5)
    (slot! tx fontSize .2)

    (send tx sync:)

    (slot! tx ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (text (slot data text:)))
               (set-text (if (truthy? text)
                             text
                           (stringify data))))))

    (slot! tx ontransformchanged:
           (lambda (model)
             '(hey "nt:ontransform")))

    (slot! tx settext:
           (lambda (text)
             (set-text text)))

    ;; call this at end of view object constructor
    (view-notify-object-changed model)

    tx))
(extern "ntext" ntext)

(define (stringify string)
  \JSON.stringify(`string))

(define *undefined* \undefined)
(define *null* \null)

;; javascript truthiness
(define (truthy? obj)
  (and obj
       (not (eq? obj *undefined*))
       (not (eq? obj *null*))
       (not (eq? obj 0))))

(define *lastn* (make-hash-table))

(define (lastn)
  (hash-table->alist *lastn*))

(define (qobj-init-hook obj)
  '(hey (format "qobj-init-hook ~s" 
                (list (slot obj name:) 
                      (slot obj ctor:)
                      (slot obj id:)))))

(define (qobj-destroy-hook obj)
  (let* ((vo (send obj viewobj:))
         (hook (and (isobject? vo)
                    (slot vo destroy-hook:))))
    (when (procedure? hook)
      (hook))))

(extern "qobj_init_hook" qobj-init-hook)
(extern "qobj_destroy_hook" qobj-destroy-hook)


;; stupid hack
(define (view-init-hook view)
  (hey "view-init-hook")
  (set! *lastn* (make-hash-table)))

(define (view-detach-hook view)
  #f)

(extern "view_detach_hook" view-detach-hook)
(extern "view_init_hook" view-init-hook)


;; first arg to preserve order since we can't sync
(define (qobj-dispatch nd obj msg arg)
  (hey "qobj-dispatch deprecated" nd obj)
  (let* ((id (slot obj id:))
         (lastn (hash-table-ref/default *lastn* id 0)))
    (when (> nd lastn)
      (hash-table-set! *lastn* id nd)
      (if (eq? arg *undefined*) (set! arg #f))
      (let ((msg (string->keyword msg)))
        (case msg
          ((model:)
           (hey "model" (slot obj name:))
           #f)
          ((setd: setdata:)
           (slot! obj data: arg)
           (view-notify-object-changed obj))
          (else    
           (nerk "case wtf is" msg)
           #f))))))

(extern "qobj_dispatch" qobj-dispatch)



(define fuck "f̸̗̎ú̴̩c̷̖͌ḳ̵̀")
(extern "fuck" fuck)



(define (getview)
  \getview())



;; runtime esm module import
(define (dynamic-import stuff)
  (##inline-host-expression "import(@1@)" stuff))

(define (import-tone)
  (dynamic-import "https://unpkg.com/tone@14.7.77/build/Tone.js"))


(define (tone n)
  (let ((synth (%new Tone.Synth)))
    (set! synth (send synth toDestination:))
    (send synth triggerAttackRelease: "C4" "32n")))

(define (trigger-attack-release p #!optional (q .1))
  (send (synth) triggerAttackRelease: p q))

(define tar trigger-attack-release)

(define (synth)
  (send (%new Tone.Synth) toDestination:))




(define (makestuff)
  (makeobj "t0" "sotext")
  (makeobj "nt" "ntext")
  (makeobj "kball" "kball")
  (makeobj "f0" "avatar")
  (set-timeout movestuff 200))

(define (movestuff)
  (slide (vo "kball") 0 1 -2)
  (grow (vo "kball") .3)
  (slide (vo "t0") 2 1.2 -2)
  (grow (vo "nt") 3)
  (slide (vo "nt") 1 1.2 -1)
  (roty (vo"nt") .3)
  )

(extern "makestuff" makestuff)
(extern "movestuff" movestuff)

;; send that tolerates null obj
(define (send-soft obj . args)
  (when (isobject? obj)
    (apply send view args)))

(define (soft-view-notify-object-changed obj)
  (send-soft (getview) notify_object_changed: obj))

(define native-notify-object-changed \view_notify_object_changed)

(define (view-notify-object-changed obj)
  (hey "vnoc" (slot obj name:) (if (getview) "view" "noview"))
  (when (getview)
    (native-notify-object-changed obj)))


(define (latticecube model)
  (let* ((obj (sogltf "latticecube.glb" "latticecube"
                      (lambda (ignore)
                        (view-notify-object-changed model)))))
    (slot! obj ondatachanged:
           (lambda (model)
             (let ((data (slot model data:)))
               (if (isobject? data)
                 (wireframe obj (truthy? (slot data wireframe:)))))))
    obj))

(extern "latticecube" latticecube)



(define (box x y z)
  (let* ((bg (%new THREE.BoxGeometry x y z))
         (mat (%new THREE.MeshPhysicalMaterial))
         (mesh (%new THREE.Mesh bg mat)))
    (send (slot mat color:) setHex: #x334444)
    (slot! mat transparent: #t)
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    mesh))

(define (avatar #!optional model)
  (let* ((b (box .2 1 .2))
         (mat (slot b material:)))
    (send (slot mat color:) setHex: #xff4444)
    (slot! mat transparent: #t)
    (slot! mat opacity: .8)
    (slot! b castShadow: #t)
    (slot! b receiveShadow: #t)
    b))

(extern "avatar" avatar)


(define vidbox \vidbox)

"https://rx.0x.no:8401/stuff/enaudi-night.mp4"
"https://rx.0x.no:8401/stuff/kf-hex.mp4"
"https://rx.0x.no:8401/stuff/kf-skyline.mp4"

(define (vbox #!optional model)
  (let* ((vb (vidbox "https://rx.0x.no:8401/stuff/lodger-doorsteps.mp4"))
         (vid (slot vb vid:)))
    (slot! vb model: model)
    (set-timeout (lambda () (slot! vid currentTime: 30)) 1000)
    vb))
(extern "vbox" vbox)


;; hack, stolen
(define-macro (-hexpr0 e)
  `(##inline-host-expression
    ,(string-append "@host2scm@(" e ")")))

(define-macro (-hexpr e)
  `(##inline-host-expression "@host2scm@(@1@)" e))

(define (current-cell)
  \currentcell)

(define current-view \getview)


(define (1+ x)
  (+ x 1))
(define (1- x)
  (- x 1))

;; cellwork is a crucial workaround
;; just calls work method on currentcell
;; doing the method call from scheme code has toxic results
(define do-cellwork \cellwork)

(define (torus-0 model)
  (let* ((mesh (%new THREE.Mesh
                     (%new THREE.TorusGeometry)
                     (%new THREE.MeshPhysicalMaterial)))
         (id (slot model id:))
         (name (slot model name:))
         (mat (slot mesh material:)))
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    (slot! mat clearcoat: .8)
    
    (let ((fn (lambda ()
                (let loop ((i 0))
                  (thread-sleep! (+ 2 (* 5 (random-real))))
                  (send (slot mat color:) setHex: (random-integer #xffffff))
                  ;; problematic
                  '(do-cellwork 
                   (lambda ()
                     ;;(send (slot mat color:) setHex: (random-integer #xffffff))
                     ))
                  (loop (+ i 1))))))
      (thread fn))

    mesh))

(define (fuckoff obj)
  (let ((r (lambda () (* 2 (random-real)))))
    ;;(slot! obj $fuckoff: (cons (slot obj id:) r))
    (let ((vo (send obj viewobj:)))
      (send (slot (slot vo material:) color:)
            setHex: (random-integer #xffffff)))))

(define (torus-1 model)
  (let ((mesh (%new THREE.Mesh
                    (%new THREE.TorusGeometry)
                    (%new THREE.MeshStandardMaterial)))
        (id (slot model id:))
        (name (slot model name:)))
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    
    (let ((iid (set-interval (lambda () (fuckoff (getobj id))) 1000)))
      (slot! mesh destroy-hook: (lambda () (clear-interval iid))))
    
    mesh))

(extern "torus" torus-1)


(define lowalk
  (lambda (#!optional model) (sogltf "lowalk")))

(define bash
  (lambda (#!optional model) (sogltf "b44bash")))

(extern "lowalk" lowalk)
(extern "bash" bash)


(define (kball #!optional model)
  (let* ((geom (%new THREE.SphereGeometry 1 12 12))
         (mat (%new THREE.MeshStandardMaterial))
         (mesh (%new THREE.Mesh geom mat)))
    (send (slot mat color:) setHex: #x555555)
    (slot! mesh receiveShadow: #t)
    (slot! mesh castShadow: #t)
    ;; want to add this step automically
    '(when model
      (view-notify-object-changed model))
    mesh))
(extern "kball" kball)

(define (pbox #!optional model)
  (let* ((b (%new THREE.BoxGeometry 1 1 1))
         (m (%new THREE.MeshStandardMaterial
                  (alist->object '((color: #x997777)
                                   ;;(side: \THREE.DoubleSide)
                                   (transparent: #t)
                                   (opacity: 0.9)))))
         (mesh (%new THREE.Mesh b m)))
    (slot! mesh receiveShadow: #t)
    (slot! mesh castShadow: #t)
    mesh))

(extern "pbox" pbox)


(define (later fn)
  (set-timeout fn 1))

(define (dipshit)
  (let ((h (htmlbox)))
    (set-timeout
     (lambda ()
       ((slot h seturl:) "https://sublambda.github.io/"))
     20)
    h))

(extern "dipshit" dipshit)

(define (draw-url url canvas)
  \rasterizeHTML.drawURL(`url,`canvas))

(define (draw-html html canvas)
  \rasterizeHTML.drawHTML(`html,`canvas).then(console.warn))

(define reparentobj \reparentobj)

(define (default-object-data-changed ob)
  (let ((data (slot ob data:)))
    (when (isobject? data)
      (let ((parentid (slot data parentid:)))
        (when (truthy? parentid)
          (hey "reparent" (slot ob name:))
          (reparentobj ob (getobj parentid)))))))


(extern "default_object_data_changed" default-object-data-changed)

(define (htmlbox #!optional model)
  (let* ((canvas (create-element "canvas"))
         (ctx (send canvas getContext: "2d"))
         (tex (%new THREE.CanvasTexture canvas))
         (box (%new THREE.BoxGeometry 1 1 .01))
         (mat (%new THREE.MeshStandardMaterial))
         (mesh (%new THREE.Mesh box mat))
         (w 1024)
         (h 1024)
         (update-texture (lambda ()
                           (slot! tex needsUpdate: #t)))
         (clearfn (lambda ()
                    (send ctx clearRect: 0 0 w h)))
         (drawfn (lambda (rendered)
                   (hey "rendered" rendered)
                   (send ctx drawImage: (slot rendered image:) 0 0)
                   (update-texture))))

    ;;(slot! tex encoding: 3001)
    (slot! tex colorSpace: "srgb")
    (slot! mat map: tex)
    (slot! mat transparent: #t)
    (slot! canvas width: w)
    (slot! canvas height: h)
    (slot! mesh canvas: canvas)
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)

    (slot! mesh ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (html (slot data html:))
                    (url (slot data url:)))
               (cond ((truthy? html)
                      (send mesh sethtml: html))
                     ((truthy? url)
                      (send mesh seturl: url))))))

    (slot! mesh seturl:
           (lambda (url)
             (dotimes (i (if (or is-safari is-ioswebkit) 3 1)) ;thrice for webkit
               (clearfn)
               (draw-url url canvas)
               (update-texture))))
    
    (slot! mesh sethtml: (lambda (html)
                           (clearfn)
                           (draw-html html canvas)
                           (update-texture)))

    (send mesh seturl: "foo2.html")

    mesh))

(define is-safari \is_safari)
(define is-webkit \is_webkit)
(define is-ioswebkit \is_ioswebkit)
(define is-chrome \is_chrome)
(define is-firefox \is_firefox)

(extern "htmlbox" htmlbox)


(define (points)
  (define (r)
    (* (- (random-real) .5) 10))
  (define (gen-positions)
    [])
  (define (gen-colors)
    [])
  (let ((geom (%new THREE.BufferGeometry))
        (positions (gen-positions))
        (colors (gen-colors)))
    (send geom setAttribute position:
          (%new THREE.Float32BufferAttribute positions 3))
    (send geom setAttribute color:
          (%new THREE.Float32BufferAttribute colors 3))
    (let ((tex (send (%new THREE.TextureLoader) load: "tmp/disc.png"))
          (mat (%new THREE.PointsMaterial 
                     (-hexpr "{size: .03,
                               depthWrite: false,
                               blending: THREE.AdditiveBlending,
                               vertexColors: true,
                               transparent: true
                               }")))
          (points (%new THREE.Points geom mat)))
      (slot! mat map: tex)
      (slot! points tag: "points")
      points)))

(extern "pts" points)

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
  (let ((rm (%new Raymarcher
                  (-hexpr "{
                            conetracing: true,
                            resolution: .3,
                            blending: .2,
                            roughness: 1,
                            metalness: .8,
                            envMapIntensity: .7,
                           }"))))
    (slot! rm layers: (gen-layers))
    (slot! rm tag: "raymarcher")
    rm))
(extern "raymarcher" raymarcher)



(define (tube #!optional model)
  (let* ((geom (%new THREE.TubeGeometry undefined 10 2 ))
         (mat (%new THREE.MeshStandardMaterial))
         ;;(mat (%new THREE.MeshPhysicalMaterial))
         ;;(mcap (send (%new THREE.TextureLoader) load: "matcap-porcelain-white.jpg"))
         ;;(mat (%new THREE.MeshMatcapMaterial (alist->object `((matcap: ,mcap)))))
         (mesh (%new THREE.Mesh geom mat))
         (pts (vector)))
    ;;(slot! mcap textureEncoding: \THREE.sRGBEncoding)
    (send (slot mat color:) setHex: #xffffff)
    (slot! mat envMapIntensity: .7)
    (slot! mat side: \THREE.DoubleSide)
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    ;; should hang this stuff on userData
    (slot! mesh pts: pts)
    (slot! mesh lseg: 100)
    (slot! mesh rseg: 16)
    (slot! mesh radius: .15)

    (slot! mesh ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (pts (slot data spine:)))
               (when (vector? pts)
                 (send mesh setpts: pts)))))

    (slot! mesh addpt:
           (lambda (x y z)
             (set! pts (vector-append pts (vector (vector x y z))))
             (slot! mesh pts: pts)
             (if (> (vector-length pts) 1)
                 (send mesh retube:))))
    (slot! mesh addpts:
           (lambda (points)
             (set! pts (vector-append pts points))
             (slot! mesh pts: pts)
             (if (> (vector-length pts) 1)
                 (send mesh retube:))))
    (slot! mesh setpts:
           (lambda (points)
             (set! pts points)
             (slot! mesh pts: pts)
             (if (> (vector-length pts) 1)
                 (send mesh retube:))))
    (slot! mesh retube:
           (lambda ()
             (let* ((curve (%new THREE.CatmullRomCurve3
                                 (vector-map (lambda (v)
                                               (apply vec3 (vector->list v)))
                                             pts)))
                    (tube (%new THREE.TubeGeometry curve
                                (slot mesh lseg:)
                                (slot mesh radius:)
                                (slot mesh rseg:)
                                #f)))
               (send geom copy: tube))))
    ;;\ (`mesh).setpts([[4,0,0],[4.8,0,0], [5,0,0], [6,1,0], [6,3,0], [8,3,0]])
    mesh))

(define cylinder (intern "cylinder"))

(define (place #!optional model)
  (let* ((cyl (cylinder))
         (geom (slot cyl geometry:)))
    (send (slot (slot cyl material:) color:) setHex: #x888888)
    (when (equal? "p0" (slot model name:))
      (let ((sm (%new THREE.ShadowMaterial)))
        (slot! sm opacity: .5)
        (slot! cyl material: sm)))
    (send geom scale: 5 .2 5)
    (send geom translate: 0 -.1 0)
    cyl))

(extern "place" place)

(define (connector #!optional model)
  (let ((cn (tube)))
    (slot! cn ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (connect (and (isobject? data)
                                  (slot data connect:))))
               (when (truthy? connect)
                 (let ((cx (vector->list connect)))
                   ;;(hey "connect" (car cx) (cadr cx))
                   (send cn setpts:
                         (connect-places (obj (car cx))
                                         (obj (cadr cx)))))))))
    cn))
(extern "connector" connector)

(define (connect-places place1 place2)
  (let* ((p1 (slot place1 position:))
         (p2 (slot place2 position:))
         (x1 (vector-ref p1 0))
         (y1 (+ (vector-ref p1 1) .2))
         (z1 (vector-ref p1 2))
         (x2 (vector-ref p2 0))
         (y2 (+ (vector-ref p2 1) .2))
         (z2 (vector-ref p2 2))
         (dx (- x2 x1))
         (dy (- y2 y1))
         (dz (- z2 z1))
         (rr (lambda () (* 2 (- (random-real) .5))))
         (out '()))
    (let loop ((d .05))
      (let ((r (ease-in-out-cubic d 0 1 1)))
        (push! (vector (+ x1 (* dx d)
                          (if (and (> d .25) (< d .75)) (rr) 1))
                       (+ y1 (* dy r)
                          (if (and (> d .25) (< d .75)) (rr) 1))
                       (+ z1 (* dz d)
                          (if (and (> d .25) (< d .75)) (rr) 1)))
               out))
      (when (< d .95)
        (loop (+ d .05))))
    (list->vector (reverse out))))

(extern "connectplaces" connect-places)

(define ease-in-out-cubic \easeInOutCubic)
(define ease-in-out-quad \easeInOutQuad)




(extern "tube" tube)

"<style>\n  body {\n    font-family: monospace;\n    font-size: 80px;\n    background: #333;\n    color: black;\n    width: 100%;\n    height: 1000;\n    margin: 20px;\n    margin-top: 100px;\n  }\n</style>\n\n<body>\nD̴̨̤͉̻̀̈́̽͗O̵̪̬̍̈́̀N̸̞̆̚'̴̢̰̫̈́T̸͈̥̤̊̏͒ ̷̺̋͑͋͝L̶̝̝͠Ö̴̬Ò̸̃̄͜K̸̲̐ ̸͔̅A̸̟̟̹̣̎̾T̵̹̊̀̕ ̵̜͙͛̈́İ̸̛̳̟͘T̷̞̰̫̳̑̾\n\n</body>\n"

(define *factor* 1.0)
(define *amplitude* .01)
(define *offset* .5)

(define *table* '())
(define (set-offset f)
  (set! *offset* f))
(define (set-factor f)
  (set! *factor* f))
(define (set-amplitude a)
  (set! *amplitude* a))

(define MarchingCubes (intern MarchingCubes:))
;;(define MarchingCubes \MarchingCubes)

(define red (%new THREE.Color #xff0000))
(extern "red" red)

(define (mcube #!optional model)
  (let* ((mat (%new THREE.MeshPhysicalMaterial
                    (alist->object
                     '((vertexColors: #t)
                       (clearcoat: #t)
                       (transparent: #t)
                       (opacity: .7)
                       (side: 2)))))
         (mc (%new MarchingCubes 50 mat #t #t 50000)))
    (slot! mc castShadow: #t)
    (slot! mc receiveShadow: #t)
    (send mc init: 50)

    (slot! mc jiggleballs:
           (lambda (#!optional (offset .7) (amplitude .005))
             (let* ((data (slot model data:))
                    (metaballs (slot data metaballs:)))
               (when (vector? metaballs)
                 (send mc reset:)
                 (vector-for-each
                  (lambda (ball)
                    (let* ((r (lambda ()
                                (* (- (random-real) offset) amplitude)))
                           (r0 (+ .7 (* .2 (random-real))))
                           (rr (lambda () (+ .2 (* .7 (random-real))))))
                      (send mc addBall: 
                            (+ (vector-ref ball 0) (r))
                            (+ (vector-ref ball 1) (r))
                            (+ (vector-ref ball 2) (r))
                            *factor*
                            (vector-ref ball 4)
                            (vector (rr) (rr) (rr)))))
                  metaballs)
                 (send mc update:)))))

    '(thread (lambda ()
              (let ((jiggleballs (slot mc jiggleballs:)))
                (let loop ()
                  (jiggleballs)
                  (thread-sleep! .1)
                  (loop)))))

    (slot! mc ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (metaballs (slot data metaballs:)))
               (when (vector? metaballs)
                 (send mc reset:)
                 (vector-for-each
                  (lambda (ball)
                    (apply send mc addBall: (vector->list ball)))
                  metaballs)
                 (send mc update:)))))
    mc))
(extern "mcube" mcube)


(##inline-host-declaration "function _foo() { console.log('_foo'); }")
(define _foo (##inline-host-expression "@host2scm@(_foo)"))
                 
(define (foo)
  (##scm2host-call-return _foo))

(define (frob fn)
  (##scm2host-call-return fn))


(define (wtf x)
  (##inline-host-expression "@host2scm@(@scm2host@(@1@))" x))

(hey "wtf" (wtf (vector 1 2 3)))




))
