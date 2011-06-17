
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


