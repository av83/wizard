(in-package #:WIZARD)

(defparameter *required* '(restas closure-template restas-directory-publisher))
(defparameter *my-package* 'wizard)
(defparameter *used-package* '(cl iter))

(load "ent.lisp") ;; *entityes* *places*

(with-open-file (out "src/defmodule.lisp" :direction :output :if-exists :supersede)
  ;; Required
  (format out "~{~%(require '~A)~}" *required*)
  (format out "~%~%(restas:define-module #:~A~%  (:use ~{#:~A ~}))~%~%(in-package #:~A)"
          *my-package* *used-package* *my-package*)
  ;; Lib
  (format out "~%~%(load \"src/lib.lisp\")")
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
       (format out "~%~%(restas:define-route ~A-page (\"~A\")"
               (string-downcase (getf place :place))
               (getf place :url))
       (format out "~%  (tpl:root~%   (list ~%~3T :navpoints (menu) ~% ~3T :content (list ~{~A~}))))"
               (loop :for action :in (eval (getf place :actions)) :collect
                  (format nil "~%~13T (list :title \"~A\"~% ~19T :content ~A)"
                          (getf action :caption)
                          (let ((entity (find-if #'(lambda (entity)
                                                     (equal (getf entity :entity) (getf action :entity)))
                                                 *entityes*)))
                            (format nil "(format nil ~A (list ~{~A ~}))"
                                    "\"~{~A ~}\""
                                    (loop :for field :in (eval (getf action :fields)) :collect
                                       (etypecase field
                                         (symbol   (format nil "~%~30T (tpl:rndfld (list :fldname \"~A\" ~%~48T :fldcontent ~A))"
                                                           (cadr (find-if #'(lambda (x)
                                                                              (equal (car x) field))
                                                                          (getf entity :fields)))
                                                           (format nil "(tpl:simplefld (list :name \"~A\" :value \"~A\"))"
                                                                   field
                                                                   field)))
                                         (cons     (let ((instr (car field)))
                                                     (case instr
                                                       (:btn
                                                        (format nil "~%~30T (tpl:simplebtn (list :name \"~A\" :value \"~A\"))"
                                                                (getf field instr)
                                                                (getf field instr))))))))))))))))
