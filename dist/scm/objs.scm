(declare
 (extended-bindings)
 (standard-bindings)
 (block)
 )

(import (_six js))
(import (srfi 28))                      ;format
(import (srfi 69))                      ;hashtable
;(import _match)

(##include "~~lib/_gambit#.scm")  
(include "macros.scm")


(define (extern name obj)
  \ (window[`name] = `obj))

(define (intern name)
  \ (window[`name] || false))

(define (hey . args)
  (println (format ";;; hey ~s" args))
  \console.warn.apply(null, `(cons "hey" args))
  )

(define (ntext #!optional model)
  (let* ((tx (%new troika.Text))
         (set-text (lambda (text)
                     (slot! tx text: text)
                     (send tx sync:))))
    (slot! tx text: ":")
    (slot! tx castShadow: #t)
    (slot! tx receiveShadow: #t)
    (slot! tx font: "./stuff/SpecialElite-Regular.ttf")
    (slot! (slot tx material:) transparent: #t)

    (slot! tx outlineColor: 0)
    (slot! tx outlineOpacity: .7)
    (slot! tx outlineWidth: 0.006)

    (slot! tx fillOpacity: 1)

    (slot! tx strokeColor: #xffffff)
    ;;(slot! tx strokeColor: #x0)
    (slot! tx strokeWidth: .01)
    (slot! tx strokeOpacity: 0.8)
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
  ;;(hey "view-init-hook")
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

(define (import-svg)
  (dynamic-import "/jsm/loaders/SVGLoader.js"))

(define (import-tone)
  (dynamic-import "https://unpkg.com/tone@14.7.77/build/Tone.js"))

(define (tone n)
  (let ((synth (%new Tone.Synth)))
    (set! synth (send synth toDestination:))
    (send synth triggerAttackRelease: "C4" "32n")))

(define (trigger-attack-release p #!optional (q .1))
  (send (synth) triggerAttackRelease: p q))

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
  ;;(hey "vnoc" (slot obj name:) (if (getview) "view" "noview"))
  (when (getview)
    (native-notify-object-changed obj)))


(define (matcap tex)
  (%new THREE.MeshMatcapMaterial
        (alist->object `((matcap: ,(load-texture tex))
                             (side: 2)))))
(extern "matcap" matcap)

(define (latticecube model)
  (let* ((mat (%new THREE.MeshMatcapMaterial
                    (alist->object `((matcap: ,(load-texture "1024/mc188.png"))
                                     (opacity: .7)
                                     (side: 2)
                                     (vertexColors: #f)))))
         (obj (sogltf "latticecube.glb" "latticecube"
                      (lambda (obj)
                        (send obj traverse:
                              (lambda (x)
                                (when (and (isobject? (slot x material:))
                                           (equal? (slot (slot x material:) name:)
                                                   "Material.002"))
                                  (slot! mat wireframe: #t)
                                  (slot! x material: mat))))
                        (view-notify-object-changed model)))))
    (slot! obj ondatachanged:
           (lambda (model)
             (let ((data (slot model data:)))
               '(if (isobject? data)
                 (wireframe obj (truthy? (slot data wireframe:)))))))
    obj))

(extern "latticecube" latticecube)



(define (capsule rad len)
  (let* ((cg (%new THREE.CapsuleGeometry rad len 4 8))
         (mat (%new THREE.MeshPhysicalMaterial))
         (mesh (%new THREE.Mesh cg mat)))
    (send (slot mat color:) setHex: #x334444)
    (slot! mat transparent: #t)
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    mesh))

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
         (mat (slot b material:))
         (cap (capsule .01 .01)))
    ;;(send b add: cap)
    ;;(slot! (slot cap material:) wireframe: #t)
    (send (slot cap position:) set: 0 -.08 -.3)
    (send (slot mat color:) setHex: #xff4444)
    (slot! mat transparent: #t)
    (slot! mat opacity: .8)
    (slot! b castShadow: #t)
    (slot! b receiveShadow: #t)
    b))

(define console-log \console.log)

(define (avatar-hands #!optional model)
  (let* ((b (capsule .06 .7))
         (mat (slot b material:))
         (hands (sogltf "handsbw.glb")))
    (send (slot hands position:) set: 0 0 2)
    (send (slot hands scale:) set: .05 .05 .05)
    (send b add: hands)
    (if (is-embedded?)
        (begin
          (slot! b visible: #f)
          (slide hands 0 -.32 -.5)
          (send (slot hands scale:) set: .01 .01 .01))
      (begin
        (slide hands 0 -.2 -.5 200)
        (grow hands .1 200)))
    (when #f
      (let ((specs (sogltf "glasses.glb")))
        (send b add: specs)
        (slide specs 0 .01 -.2)
        (grow specs .05)
        (roty specs 3.14)))
    (send (slot mat color:) setHex: #xff4444)
    (slot! mat transparent: #t)
    (slot! mat opacity: .8)
    (slot! b castShadow: #t)
    (slot! b receiveShadow: #t)
    b))

(extern "avatar" avatar-hands)


(define vidbox \vidbox)

(define (vbox #!optional model)
  (let* ((vb (vidbox "https://meat.local/Hegre%20ariel%20hegre%20hegre%20art-3yqpc.mp4"))
         (vid (slot vb vid:)))
    (slot! vb model: model)
    (set-timeout (lambda () (slot! vid currentTime: 8)) 1000)
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
  (lambda (#!optional model) (sogltf "lastofbash")))

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

(define (dipshit #!optional model)
  (let ((h (htmlbox)))
    (set-timeout
     (lambda ()
       (when #f
         ((slot h seturl:) "https://sublambda.github.io/")))
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

    (send mesh seturl: "https://sublambda.github.io")

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


(define (load-texture file)
  (let ((tx (send (%new THREE.TextureLoader) load: file)))
    (slot! tx textureEncoding: \THREE.sRGBEncoding) ;???
    tx))

(define (tube #!optional model)
  (let* ((geom (%new THREE.TubeGeometry undefined 10 .2 12 #t))
         (mat (%new THREE.MeshMatcapMaterial
                    (alist->object
                     `((matcap:
                        ,(load-texture
                          ;;"https://makio135.com/matcaps/64/F9E6C7_FCF7DF_EDD3AA_F1D4B4-64px.png"
                          ;;"https://makio135.com/matcaps/64/626A57_3B3F33_7D8973_444C3C-64px.png"
                          ;;"https://makio135.com/matcaps/128/B4B29D_442D0D_604E2A_736542-128px.png"
                          ;;"https://makio135.com/matcaps/128/2A2D21_555742_898974_6C745B-128px.png"
                          ;;"https://makio135.com/matcaps/128/1B1C19_5F615D_4B4E4C_3F403D-128px.png"
                          ;;"https://makio135.com/matcaps/64/745359_BFAEA8_9B8384_AC9392-64px.png"
                          "https://makio135.com/matcaps/64/586A51_CCD5AA_8C9675_8DBBB7-64px.png"
;;                          "1024/mc142.png"
;;                          "mc2.png"
                          ))))))
         (mesh (%new THREE.Mesh geom mat))
         (pts (vector)))
    (slot! mat transparent: #t)
    (slot! mat opacity: .7)
    ;;(send (slot mat color:) setHex: #x555555)
    (slot! mat envMapIntensity: .1)
    (slot! mat side: \THREE.DoubleSide)
    (slot! mesh castShadow: #t)
    (slot! mesh receiveShadow: #t)
    ;; should hang this stuff on userData
    (slot! mesh pts: pts)
    (slot! mesh lseg: 100)
    (slot! mesh rseg: 16)
    (slot! mesh radius: .8)

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
    mesh))

(define cylinder (intern "cylinder"))

(define (catmull-rom-curve pts)
  (let ((curve (%new THREE.CatmullRomCurve3 pts)))
    (slot! curve type: "catmullrom")
    (slot! curve closed: #f)
    curve))

;; radius, curvepts
(define (extrusion-geom r pts)
  (let ((shape (%new THREE.Shape))
        (curve (catmull-rom-curve (list->vector
                                   (map (lambda (p) (apply vec3 p)) pts)))))
    (send shape moveTo: 0 r)
    (send shape quadraticCurveTo: r r r 0)
    (send shape quadraticCurveTo: r (- r) 0 (- r))
    (send shape quadraticCurveTo: (- r) (- r) (- r) 0)
    (send shape quadraticCurveTo: (- r) r 0 r)
    (%new THREE.ExtrudeGeometry shape
          (alist->object
           `((steps: 40)
             ;;(depth: 4)
             (bevelEnabled: #f)
             (extrudePath: ,curve)
             )))))

(define (place #!optional model)
  (let* ((cyl (cylinder))
         (geom (slot cyl geometry:))
         (mat0 (slot cyl material:))
         (mat (%new THREE.MeshMatcapMaterial
                    (alist->object
                     `((matcap:
                        ,(load-texture
                          ;;"https://makio135.com/matcaps/64/586A51_CCD5AA_8C9675_8DBBB7-64px.png"
                          "https://makio135.com/matcaps/64/586A51_CCD5AA_8C9675_8DBBB7-64px.png"
                          ;;"mc1.png"
                          )))))))
    (slot! cyl material: mat)
    ;;(send (slot mat color:) setHex: #xccccbb)
    (slot! cyl castShadow: #t)
    (slot! cyl receiveShadow: #t)
    (slot! mat transparent: #t)
    (slot! mat opacity: .7)
    (when (and (is-embedded?) (equal? "p0" (slot model name:)))
      (let ((sm (%new THREE.ShadowMaterial)))
        (slot! cyl material: sm)
        (slot! sm opacity: .5)))
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
         (y1 (+ (vector-ref p1 1) .3))
         (z1 (vector-ref p1 2))
         (x2 (vector-ref p2 0))
         (y2 (+ (vector-ref p2 1) .3))
         (z2 (vector-ref p2 2))
         (dx (- x2 x1))
         (dy (- y2 y1))
         (dz (- z2 z1))
         (rr (lambda () (* 2 (- (random-real) .5))))
         (out '()))
    (let loop ((d .15))
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

;; function easeInOutCubic (t, b, c, d) {
;;     if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
;;     return c / 2 * ((t -= 2) * t * t + 2) + b;
;; }




(extern "tube" tube)

"<style>\n  body {\n    font-family: monospace;\n    font-size: 80px;\n    background: #333;\n    color: black;\n    width: 100%;\n    height: 1000;\n    margin: 20px;\n    margin-top: 100px;\n  }\n</style>\n\n<body>\nD̴̨̤͉̻̀̈́̽͗O̵̪̬̍̈́̀N̸̞̆̚'̴̢̰̫̈́T̸͈̥̤̊̏͒ ̷̺̋͑͋͝L̶̝̝͠Ö̴̬Ò̸̃̄͜K̸̲̐ ̸͔̅A̸̟̟̹̣̎̾T̵̹̊̀̕ ̵̜͙͛̈́İ̸̛̳̟͘T̷̞̰̫̳̑̾\n\n</body>\n"

(define *factor* .3)
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

(define (matcap0)
  (%new THREE.MeshMatcapMaterial
        (alist->object
         `((matcap: ,(load-texture "1024/mc188.png"))
           (vertexColors: #t)
           (side: 2)
           (transparent: #t)
           ;;(opacity: .7)
           (vertexColors: #f)))))
(extern "matcap0" matcap0)


(define (imesh mesh)
  (let ((im (%new THREE.InstancedMesh
                  (slot mesh geometry:)
                  (slot mesh material:)
                  10000)))
    (send (slot im instanceMatrix:) setUsage: \THREE.DynamicDrawUsage )
    im))

(define (imesh-matrix mesh n)
  (let ((matrix (%new THREE.Matrix4)))
    (send mesh getMatrixAt: n matrix)
    matrix))

(define (imesh-matrix-set! mesh n matrix)
  (send mesh setMatrixAt: n matrix))


(define (mcubes #!optional model)
  (let* ((pmat (%new THREE.MeshPhysicalMaterial
                     (alist->object
                      '((vertexColors: #t)
                        (clearcoat: .3)
                        (transparent: #t)
                        (envMapIntensity: .3)
                        (opacity: .7)
                        (side: 2)))))
         (mmat (%new THREE.MeshMatcapMaterial
                     (alist->object
                      `(;;(matcap: ,(load-texture "1024/mc142.png"))
                        (matcap: ,(load-texture "1024/mc448.png"))
                        (vertexColors: #f)
                        (side: 2)
                        (transparent: #t)
                        (opacity: .7)))))
         (mc (%new MarchingCubes 20 mmat #f #t 50000)))
    (slot! mc castShadow: #t)
    (slot! mc receiveShadow: #t)
    (send mc init: 50)

    (slot! mc ball:
          (lambda (x y z #!optional (r .1) (a 1))
            (send mc addBall: x y z r a)
            (send mc update:)))

    (slot! mc jiggle:
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
                 (send mc update:)
                 (send (slot mc geometry:) computeBoundingSphere:)))))
    mc))
(extern "mcubes" mcubes)

(define (nc r m)
  (let* ((v (lambda (x y z r m)
             (vector x y z r m)))
         (balls (vector 
                 (v  0 .5 .5 r m)
                 (v .1 .5 .5 r m)
                 (v .2 .5 .5 r m)
                 (v .3 .5 .5 r m)
                 (v .4 .5 .5 r m)
                 (v .5 .5 .5 r m)
                 (v .6 .5 .5 r m)
                 (v .7 .5 .5 r m)
                 (v .8 .5 .5 r m)
                 (v .9 .5 .5 r m)
                 )))
    balls))

(define (nc2 rad r m)
  (let* ((n (lambda (x y z r m)
             (vector x y z r m)))
         (nb 23)
         (pi (* 2 (asin 1)))
         (ring (lambda (y)
                 (map (lambda (i)
                        (let* ((a (* i (/ (* 2 pi) nb)))
                               (x (+ .5 (* rad (sin a))))
                               (z (+ .5 (* rad (cos a)))))
                          (vector x y z r m)))
                      (iota nb))))
         (balls (apply append (map ring (iota 10 .1 .087)))))
    (list->vector balls)))
(extern "nc2" nc2)

(define (nc3 r m)
  (let* ((n (lambda (x y z r m)
             (vector x y z r m)))
         (balls (list->vector
                 (map (lambda (i)
                        (let* ((a (* i (/ (* 2 pi) nb)))
                               (x (+ .5 (* .4 (sin a))))
                               (z (+ .5 (* .4 (cos a)))))
                          (vector x .5 z r m)))
                      (iota nb)))))
    balls))
(extern "nc2" nc2)


;;(##inline-host-declaration "function _foo() { console.log('_foo'); }")
;;(define _foo (##inline-host-expression "@host2scm@(_foo)"))
                 
;;(define (foo)
;;  (##scm2host-call-return _foo))

;;(define (frob fn)
;;  (##scm2host-call-return fn))


(define (wtf x)
  (##inline-host-expression "@host2scm@(@scm2host@(@1@))" x))

(define (read-from-string s)
  (with-input-from-string s
    (lambda ()
      (read))))



(define *camhist* (list))

(define (view-listener-hook p q t)
  (push! (list t p q) *camhist*))

\set_view_listener_hook(`view-listener-hook)


(define (meshline #!optional model)
  (let ((ml (%new MeshLine)))
    (slot! ml setpoints:
           (lambda (pl)
             (let ((pts '()))
               pts)))
    ml))


(define sculpty \sculpty)
(define sball \sball)

(define (sculptfuck #!optional model)
  (let ((sc (sculpty)))
    (slot! sc ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (points (slot data points:)))
               (when (vector? points)
                 (let ((vo (send model viewobj:)))
                   (vector-for-each
                    (lambda (pt)
                      (sball vo
                             (vector-ref pt 0)
                             (vector-ref pt 1)
                             (vector-ref pt 2)
                             (vector-ref pt 3)))
                    points))))))
    sc))

(extern "sculptfuck" sculptfuck)


(define cavegen \cavegen)

(define (sxfuck #!optional model)
  (let* ((mat (%new THREE.MeshPhysicalMaterial
                    (alist->object '((vertexColors: #t)))))
         (mmat (%new THREE.MeshMatcapMaterial
                     (alist->object
                      `((matcap: ,(load-texture "1024/mc311.png"))
                        (vertexColors: #t)
                        (side: 2)
                        (transparent: #t)
                        (opacity: .7)
                        (vertexColors: #f)))))
         (sx (%new SXWorld
                   worldgen: (cavegen 0)
                   chunkSize: 50))
         (nball (lambda (x y z r)
                  (send sx updateVolume: (vec3 x y z) r #xff
                        (alist->object '((r 180) (g 180) (b 180))))
                  (send sx updateChunks: (vec3 x y z)))))

    (slot! sx chunkMaterial: mmat)
    (slot! sx renderRadius: 15)

    ;;(nball 0 0 0 1)
    (slot! sx ball: nball)

    (slot! sx update:
           (lambda (x y z)
             (send sx updateChunks: (vec3 x y z))))

    (slot! sx ondatachanged:
           (lambda (model)
             (let* ((data (slot model data:))
                    (points (slot data points:))
                    (ball (slot sx ball:)))
               (when (vector? points)
                 (vector-for-each (lambda (x)
                                    (apply nball (vector->list x)))
                                  points)))))
    sx))

(extern "sxfuck" sxfuck)


(define CSG \CSG)

(define (csg-operation geom csgop material)
  (let ((op (%new CSG.Operation geom)))
    (slot! op operation: csgop)
    ;;(when (truthy? material)
    (slot! op material: (or material *gridmaterial*))
    op))

(define (csg-operation-group ops)
  (let ((og (%new CSG.OperationGroup)))
    (apply send og add: ops)))

(define (csg-addop geom #!optional material)
  (csg-operation geom (slot CSG ADDITION:) material))

(define (csg-subop geom #!optional material)
  (csg-operation geom (slot CSG SUBTRACTION:) material))

(define (csg-diffop geom #!optional material)
  (csg-diffop geom (slot CSG DIFFERENCE:) material))

(define (csg-intersectop geom #!optional material)
  (csg-operation geom (slot CSG INTERSECTION:) material))

(define (csg-brush geom)
  (%new CSG.Brush geom))

(define (csg-evaluator)
  (let ((ev (%new CSG.Evaluator)))
    (slot! ev useGroups: #t)
    ev))

(define (csg-evaluate-hier root)
  (send (csg-evaluator) evaluateHierarchy: root))

(define (csg-evaluate brush1 brush2 op)
  (let ((mesh (%new THREE.Mesh)))
    (send (csg-evaluator) evaluate: brush1 brush2 op mesh)
    mesh))

(define (csg-add brush1 brush2)
  (csg-evaluate brush1 brush2 (slot CSG ADDITION:)))

(define (csg-sub brush1 brush2)
  (csg-evaluate brush1 brush2 (slot CSG SUBTRACTION:)))

(define (csg-diff brush1 brush2)
  (csg-evaluate brush1 brush2 (slot CSG DIFFERENCE:)))

(define (csg-intersect brush1 brush2)
  (csg-evaluate brush1 brush2 (slot CSG INTERSECTION:)))

;; ADDITION, SUBTRACTION, DIFFERENCE, INTERSECTION

(define (capsule-geom rad len)
  (%new THREE.CapsuleGeometry rad len 4 10))

(define (box-geom x y z)
  (%new THREE.BoxGeometry x y z))

(define (sphere-geom #!optional r)
  (%new THREE.SphereGeometry))

(define (tube-geom pts)
  (let ((tb (tube)))
    (send tb setpts: pts)
    (slot tb geometry:)))

(define initbvh \initbvh)
(initbvh)

(define xxx 0)

(define (csg-position! op x y z)
  (send (slot op position:) set: x y z)
  op)

(define *gridmaterial* (%new CSG.GridMaterial))
;;(send (slot *gridmaterial* color:) set: #xbbcccc)

(define (chunk #!optional model)
  (let* ((bg (box-geom 4 4 4))
         (cg (capsule-geom .8 .4))
         (tg (tube-geom #(#(0 -3 0)
                          #(0 3 0))))
         (eg (extrusion-geom .4 '((0 -2.3 0) 
                                  (0 -1 0)
                                  (.5 0 0)
                                  (0 1 0)
                                  (0 2.3 0))))
         (eg2 (extrusion-geom .3 '((-3 0 0)
                                   (2 0 0))))
         (mat (%new THREE.MeshStandardMaterial
                    (alist->object '((color: #x997777)
                                     (side: 2)
                                     (transparent: #t)
                                     (opacity: 0.6)))))
         ;;(xg (csg-sub (csg-brush bg) (csg-brush eg)))
         (xg (let ((root (csg-addop bg mat)))
               (send root add:
                     (csg-operation-group
                      (list (csg-position! (csg-subop cg) 1 1.5 0)
                            (csg-position! (csg-subop cg) 1 1 0)
                            (csg-position! (csg-subop cg) -.3 0 0)
                            (csg-subop eg)
                            (csg-subop eg2))))
               (csg-evaluate-hier root))))
    ;;(slot! xg material: mat)
    (slot! xg castShadow: #t)
    (slot! xg receiveShadow: #t)
    xg))

(define (chunk2 #!optional model)
  (let* ((bg (box-geom 8 3 3))
         (rr (lambda () (* 1 (- (random-real) .5))))
         (eg (extrusion-geom
              .45 (map (lambda (i)
                        (list (- i  4.5) (rr) (rr)))
                      (iota 10))))
         (eg2 (extrusion-geom
               .55 (map (lambda (i)
                          (list (- i  4.5) (rr) (rr)))
                      (iota 10))))
         (mat (%new THREE.MeshStandardMaterial
                    (alist->object '((color: #x997777)
                                     (side: 2)
                                     (transparent: #t)
                                     (opacity: 0.8)))))
         (xg (let ((root (csg-addop bg mat)))
               (send root add:
                     (csg-operation-group
                      (list (csg-subop eg2) (csg-addop eg))))
               (csg-evaluate-hier root))))
    (slot! xg castShadow: #t)
    (slot! xg receiveShadow: #t)
    xg))

(extern "chunk" chunk)
(extern "chunk2" chunk2)
