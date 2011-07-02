(in-package #:WIZARD)

(defparameter *required* '(restas closure-template restas-directory-publisher))
(defparameter *my-package* 'wizard)
(defparameter *used-package* '(cl iter))

(defun gen-fld-symb (fld entity-param)
  (let* ((entity    (find-if #'(lambda (entity)     (equal (getf entity :entity) entity-param))    *entityes*))
         (typedata  (caddr (find-if #'(lambda (x)   (equal (car x) fld))                           (getf entity :fields))))
         (name      (cadr (find-if #'(lambda (x)    (equal (car x) fld))                           (getf entity :fields)))))
    (format nil "~%~25T (list :fld \"~A\" :perm 111 :typedata '~A :name \"~A\")"
            fld
            (subseq (with-output-to-string (*standard-output*)  (pprint typedata)) 1)
            name)))

(defun gen-fld-cons (fld)
  (let ((instr (car fld)))
    (ecase instr
      (:calc
       (values
        (format nil "~%~25T (list :calc (lambda (obj) ~A) :perm 111)"
                (subseq (with-output-to-string (*standard-output*) (pprint (getf fld instr))) 1))
        nil))
      (:btn
       (let ((btntype (nth 2 fld)))
         (ecase btntype
           (:act
            (let ((gen (gensym "B")))
              (values
               (format nil "~%~25T (list :btn \"~A\" :perm 111 :value \"~A\")"
                       gen
                       (getf fld instr))
               (list (list gen (getf fld :act))))))
           (:popup
            (let ((popup (eval (getf fld :popup)))
                  (gen   (gensym "P")))
              (multiple-value-bind (str ctrs)
                  (gen-fields (eval (getf popup :fields))
                              (getf popup :entity))
                ;; (format t "~%---| ~A" ctrs)
                (values
                 (format nil "~%~25T (list :popbtn \"~A\" ~%~31T :value \"~A\" ~%~31T :perm 111 ~%~31T :title \"~A\" ~%~31T :fields ~A)"
                         gen
                         (getf fld instr)
                         (getf popup :caption)
                         str)
                 ctrs)))))))
      (:col
       (multiple-value-bind (str ctrs)
           (gen-fields (eval (getf fld :fields))
                       (getf fld :entity))
         (values
          (format nil "~%~25T (list :col \"~A\" :perm 111 ~%~32T:val (lambda () ~A)~%~32T:fields ~A)"
                  (getf fld instr)
                  (getf fld :val)
                  str)
          ctrs))))))

(defun gen-fields (fields entity)
  ;; (format t "~%gen-fields : ~A : ~A" fields entity)
  (let ((controllers))
    (values
     (format nil "(list ~{~A~})"
             (loop :for fld :in fields :collect
                (etypecase fld
                  (symbol
                   (gen-fld-symb fld entity))
                  (cons
                   (multiple-value-bind (str ctrs)
                       (gen-fld-cons fld)
                     (loop :for ctr :in ctrs :do
                        (setf controllers (append controllers (list ctr))))
                     str)))))
     controllers)))

(defun gen-action (action)
  (let ((controllers))
    (values
     (format nil "~%~14T (list :perm '~A ~%~20T :title \"~A\"~% ~20T :val (lambda () ~A)~% ~20T :fields ~A)"
             (subseq (with-output-to-string (*standard-output*) (pprint (getf action :perm))) 1)
             (getf action :caption)
             (subseq (with-output-to-string (*standard-output*) (pprint (getf action :val))) 1)
             (multiple-value-bind (str ctrs)
                 (gen-fields (eval (getf action :fields))
                             (getf action :entity))
               (setf controllers (append controllers (list ctrs)))
               str))
     controllers)))

(with-open-file (out "/home/rigidus/wizard/src/defmodule.lisp" :direction :output :if-exists :supersede)
  ;; Required
  (format out "~{~%(require '~A)~}" *required*)
  (format out "~%~%(restas:define-module #:~A~%  (:use ~{#:~A ~}))~%~%(in-package #:~A)"
          *my-package* *used-package* *my-package*)
  ;; Containers
  (let ((containers)
        (classes (make-hash-table :test #'equal)))
    ;; Containers
    (loop :for entity :in *entityes* :do
       (let ((container (getf entity :container)))
         (unless (null container)
           (push container containers))))
    (setf containers (reverse (remove-duplicates containers)))
    (format out "~%~%;; Containers~%")
    (loop :for container :in containers :do
       (format out "~%~<(defparameter *~A* ~43:T (make-hash-table :test #'equal))~:>"
               `(,container)))
    ;; Classes
    (format out "~%~%;; Classes")
    (loop :for entity :in *entityes* :do
       (let ((super (getf entity :super)))
         (format out "~%~%~%~<(defclass ~A (entity)~%(~{~A~^~%~}))~:>"
                 `(,(getf entity :entity)
                    ,(loop :for field :in (getf entity :fields) :collect
                        (let ((fld (car field))
                              (tpi (car (nth 2 field))))
                          (format nil "~<(~A ~23:T :initarg :~A ~53:T :initform nil :accessor ~A)~:>"
                                  `(,fld ,fld ,(format nil "A-~A" fld))))))))
       (let ((perm (getf entity :perm)))
         (unless (null (getf perm :create))
           (format out "~%~%(defmethod initialize-instance :after ((object ~A) &key)"
                   (getf entity :entity))
           (format out "~%  ;; Здесь будет проверка прав~%  ;; ...~%  ;; Запись в контейнер")
           (format out "~%  (setf (gethash (hash-table-count *~A*) *~A*) object)"
                   (getf entity :container)
                   (getf entity :container))
           (format out ")"))
         (unless (null (getf perm :view))
           (format out "~%~%(defmethod view ((object ~A) &key)"
                   (getf entity :entity))
           (format out "~%  ;; Здесь будет проверка прав~%  ;; ...~%  ;; Печать")
           (let ((fields (getf entity :fields)))
             (loop :for fld :in fields :collect
                (let ((caption (cadr fld))
                      (name    (car fld)))
                  (format out "~%  (format t \"~A~A : ~A\" (~A object))" "~%" caption "~A" name))))
           (format out ")")))))
  ;; Places
  (let ((menu))
    (loop :for place :in *places* :do
       (unless (null (getf place :navpoint))
         (push (list :link (getf place :url) :title (getf place :navpoint)) menu))
       (let ((controllers))
         ;; (format t "~%--------")
         (format out "~%~%(restas:define-route ~A-page (\"~A\")"
                 (string-downcase (getf place :place))
                 (getf place :url))
         (format out "~%  (let ((session (hunchentoot:start-session))~%~7T (acts (list ~{~A~}))) ~A)"
                 (loop :for action :in (eval (getf place :actions)) :collect
                    (multiple-value-bind (str ctrs)
                        (gen-action action) ;; Вот оно ключевое :)
                      (loop :for ctr :in ctrs :do
                         (setf controllers (append controllers ctr)))
                      str))
                 (format nil  "~%    (show-acts acts))"))
         ;; (loop :for ctr :in controllers :do                  ;;
            ;; (format t "~%~A | ~A" (car ctr) (cadr ctr)))     ;;
         (format out "~%~%(restas:define-route ~A-page/post (\"~A\" :method :post)"
                 (string-downcase (getf place :place))
                 (getf place :url))
         (format out  "~%  (let ((session (hunchentoot:start-session))~%~7T (acts `(~{~%~A~}))) ~%       (activate acts)))"
                 (loop :for controller :in controllers :collect
                    (format nil "(\"~A\" . ,(lambda () ~A))"
                            (car controller)
                            (subseq (with-output-to-string (*standard-output*) (pprint (cadr controller))) 1)
                            )))))
    (format out "~%~%~%(defun menu ()  '")
    (pprint (reverse menu) out)
    (format out ")")))
