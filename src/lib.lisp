
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

(defun get-current-user ()
  (make-instance 'admin :login "admin" :password "admin"))

(defun show-acts (acts)
  (tpl:root
   (list
    :navpoints (menu)
    :content
    (loop
       :for act
       :in acts
       :collect
       (list :perm (getf act :perm)
             :title (getf act :title)
             :content
             (tpl:frm
              (list :flds
                    (loop
                       :for act
                       :in (getf act :in)
                       :collect
                       (ecase (car act)
                         (:fld (tpl:rndfld
                                (list :fldname (getf act :name)
                                      :fldcontent (tpl:simplefld
                                                   (list :name (getf act :fld) :value (getf act :value))))))
                         (:btn (tpl:simplebtn (list :name (getf act :btn) :value (getf act :value)))))))))))))
