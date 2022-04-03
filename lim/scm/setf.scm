
(define-syntax setf
  (syntax-rules ()
    ((setf (?e0 ?e1 ...) ?v)
     ((setter ?e0) ?e1 ... ?v))
    ((setf ?i ?v)
     (setf ?i ?v))))

(define setter 
  (let ((setters (list (cons car  set-car!)
                       (cons cdr  set-cdr!)
                       (cons caar (lambda (p v) (set-car! (car p) v)))
                       (cons cadr (lambda (p v) (set-car! (cdr p) v)))
                       (cons cdar (lambda (p v) (set-cdr! (car p) v)))
                       (cons cddr (lambda (p v) (set-cdr! (cdr p) v)))
                       (cons vector-ref vector-set!)
                       (cons string-ref string-set!))))
    (letrec ((setter
              (lambda (proc)
                (let ((probe (assv proc setters)))
                  (if probe
                      (cdr probe)
                      (error "No setter for " proc)))))
             (set-setter!
              (lambda (proc setter)
                (set! setters (cons (cons proc setter) setters))
                '(unspecified))))
      (set-setter! setter set-setter!)
      setter)))
