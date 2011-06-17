
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
  (format nil "~{~A~}"
          (mapcar #'(lambda (field)
                      (etypecase field
                          (symbol (render-field-symbol field))
                          (cons   (render-field-cons field))))
                      ;; (format nil "~A : ~A <br />" (type-of field) field))
                  (eval (getf action :fields)))))

(defun render-field-symbol (field)
  (tpl:rndfld (list :fldname field :fldcontent "<input type=\"text\" name=\"~a\" value=\"\" /> <br />")))

(defun render-field-cons (field)
  (format nil "cons <br />" field))
