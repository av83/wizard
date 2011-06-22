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
  ;; Init objects
  (format out "~%~%~%;; Init objects~%(load \"src/init.lisp\")~%")
  ;; Places
  (let ((menu))
    (loop :for place :in *places* :do
       (unless (null (getf place :navpoint))
         (push (list :link (getf place :url) :title (getf place :navpoint)) menu))
       (let ((controllers))
         (format out "~%~%(restas:define-route ~A-page (\"~A\")"
                 (string-downcase (getf place :place))
                 (getf place :url))
         (format out "~%  (let ((acts (list ~{~A~}))) ~A)"
                 (loop :for action :in (eval (getf place :actions)) :collect
                    (format nil "~%~14T (list :perm '~A ~%~20T :title \"~A\"~% ~20T :val (lambda () ~A)~% ~20T :fields ~A)"
                            (subseq (with-output-to-string (*standard-output*) (pprint (getf action :perm))) 1)
                            (getf action :caption)
                            (subseq (with-output-to-string (*standard-output*) (pprint (getf action :val))) 1)
                            (case (getf action :val)
                              ('nil
                               (let ((entity (find-if #'(lambda (entity)
                                                          (equal (getf entity :entity) (getf action :entity)))
                                                      *entityes*)))
                                 (format nil "(list ~{~A~})"
                                         (loop :for fld :in (eval (getf action :fields)) :collect
                                            (etypecase fld
                                              (symbol   (format nil "~%~25T (list :fld \"~A\" :perm 111 :typedata '~A :name \"~A\")"
                                                                fld
                                                                (caddr (find-if #'(lambda (x)
                                                                                    (equal (car x) fld))
                                                                                (getf entity :fields)))
                                                                (cadr (find-if #'(lambda (x)
                                                                                   (equal (car x) fld))
                                                                               (getf entity :fields)))))
                                              (cons     (let ((instr (car fld)))
                                                          (case instr
                                                            (:btn
                                                             (format nil "~%~25T (list :btn \"~A\" :perm 111 :value \"~A\")"
                                                                     (let ((gen (gensym "B")))
                                                                       (push `(,gen . ,(getf fld :act)) controllers)
                                                                       gen)
                                                                     (getf fld instr)))))))))))
                              (otherwise
                               (let ((entity (find-if #'(lambda (entity)
                                                          (equal (getf entity :entity) (getf action :entity)))
                                                      *entityes*)))
                                 (format nil "(list ~{~A~})"
                                         (loop :for fld :in (eval (getf action :fields)) :collect
                                            (etypecase fld
                                              (symbol   (format nil "~%~25T (list :fld \"~A\" :perm 111 :typedata '~A :name \"~A\")"
                                                                fld
                                                                (caddr (find-if #'(lambda (x)
                                                                                    (equal (car x) fld))
                                                                                (getf entity :fields)))
                                                                (cadr (find-if #'(lambda (x)
                                                                                   (equal (car x) fld))
                                                                               (getf entity :fields)))))
                                              (cons     (let ((instr (car fld)))
                                                          (case instr
                                                            (:btn
                                                             (format nil "~%~25T (list :btn \"~A\" :perm 111 :value \"~A\")"
                                                                     (let ((gen (gensym "B")))
                                                                       (push `(,gen . ,(getf fld :act)) controllers)
                                                                       gen)
                                                                     (getf fld instr)))))))))))
                              ;; todo: user
                              )))
                 (format nil  "~%    (show-acts acts))"))
         (format out "~%~%(restas:define-route ~A-page/post (\"~A\" :method :post)"
                 (string-downcase (getf place :place))
                 (getf place :url))
         (format out  "~%  (let ((acts `(~{~%~A~}))) ~%       (activate acts)))"
                 (loop :for controller :in controllers :collect
                    (format nil "(\"~A\" . ,(lambda () ~A))"
                            (car controller)
                            (cdr controller))))))))
