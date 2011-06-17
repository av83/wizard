
(in-package #:WIZARD)

(let ((path '(:RELATIVE "wizard")))
  (setf asdf:*central-registry*
        (remove-duplicates (append asdf:*central-registry*
                                   (list (merge-pathnames
                                          (make-pathname :directory path)
                                          (user-homedir-pathname))))
                           :test #'equal)))

(defparameter *basedir*
  ;; (asdf:component-pathname (asdf:find-system '#:rigidus.ru)))
  "/home/rigidus/wizard/")


(defun path (relative)
  (merge-pathnames relative *basedir*))


(closure-template:compile-template :common-lisp-backend (path "src/templates.soy"))

(restas:mount-submodule -static- (#:restas.directory-publisher)
  (restas.directory-publisher:*directory* (path "src/static/")))

(defun menu ()
  (list (list :link "/" :title "Главная")
        (list :link "/about" :title "About")
        (list :link "/articles/" :title "Статьи")
        (list :link "/faq/" :title "FAQ")
        (list :link "/resources/" :title "Ресурсы")
        (list :link "/contacts" :title "Контакты")))



(defun render (param)
  (mapcar #'(lambda (action)
              (list :title (getf action :caption)
                    :content (render-fields action)))
          param))


(defun render-fields (action)
  (let ((entity (find-if #'(lambda (entity)
                             (equal (getf entity :entity) (getf action :entity)))
                         *entityes*)))
    (format nil "~{~A ~}"
            (mapcar #'(lambda (field)
                        ;; (format nil "~A : ~A <br />" (type-of field) field))
                        (etypecase field
                          (symbol (render-field-symbol (getf entity :fields) field))
                          (cons   (render-field-cons field))))
                    (eval (getf action :fields))))))


(defun render-field-symbol (all-fields field)
  (let ((fld-name (cadr (find-if #'(lambda (x)
                                     (equal (car x) field))
                                 all-fields))))
    (tpl:rndfld (list :fldname fld-name :fldcontent "<input type=\"text\" name=\"~a\" value=\"\" /> <br />"))))


(defun render-field-cons (field)
  (format nil "~{~A ~}"
          (loop :for instr :in field :by #'cddr :collect
             (case instr
               (:btn
                (format nil "<input type=\"button\" name=\"~A\" value=\"~A\" />"
                        (getf field instr)
                        (getf field instr)))
               (:act instr)))))
