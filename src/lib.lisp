
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

(defun cur-user ()
  (gethash 0 *USER*))

(defun form-data ()
  (hunchentoot:post-parameters*))

(defun change-admin-password ()
  "!!!change-admin-password")

(defun activate (acts)
  ;; (let ((rs))
    ;; (push (form-data) rs)
    (loop :for key :in acts :do
       ;; (push (car key) rs)
       (when (assoc (car key) (form-data) :test #'equal)
         ;; (push (funcall (cdr key)) rs)
         (return-from activate (funcall (cdr key)))))
    "err: unk:post:controller"
    ;; (format nil "~{~A<br />~}" (reverse rs))
    )


(defun show-acts (acts)
  (tpl:root
   (list
    :navpoints (menu)
    :content
    (loop
       :for act
       :in acts
       :collect
       (list :title (getf act :title)
             :content
             (let ((val (funcall (getf act :val))))
               (cond ((null val) ;; NIL
                      (tpl:frmobj
                       (list :flds
                             (loop :for infld :in (getf act :fields) :collect
                                (let ((typefld (car infld)))
                                  (ecase typefld
                                    (:fld
                                     (let ((captfld   (getf infld :name))
                                           (permfld   (getf infld :perm))
                                           (typedata  (getf infld :typedata)))
                                       (cond ((equal typedata '(str))
                                              (tpl:fld
                                               (list :fldname captfld
                                                     :fldcontent (tpl:strupd (list :name captfld)))))
                                             ((equal typedata '(pswd))
                                              (tpl:fld
                                               (list :fldname captfld
                                                     :fldcontent (tpl:pswdupd (list :name captfld)))))
                                             (t "err:unk typedata"))))
                                    (:btn (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))))))))
                     ((equal 'ADMIN (type-of val)) ;; ADMIN
                      (tpl:frmobj
                       (list :flds
                             (loop :for infld :in (getf act :fields) :collect
                                (let ((typefld (car infld)))
                                  (ecase typefld
                                    (:fld
                                     (let ((namefld   (getf infld :fld))
                                           (captfld   (getf infld :name))
                                           (permfld   (getf infld :perm))
                                           (typedata  (getf infld :typedata)))
                                       (cond ((equal typedata '(str))
                                              (tpl:fld
                                               (list :fldname captfld
                                                     :fldcontent
                                                     (tpl:strupd
                                                      (list :name namefld
                                                            :value (funcall
                                                                    (intern
                                                                     (format nil "A-~A" namefld)
                                                                     (find-package "WIZARD"))
                                                                    val))))))
                                             ((equal typedata '(pswd))
                                              (tpl:fld
                                               (list :fldname captfld
                                                     :fldcontent
                                                     (tpl:pswdupd
                                                      (list :name namefld
                                                            :value (funcall
                                                                    (intern
                                                                     (format nil "A-~A" namefld)
                                                                     (find-package "WIZARD"))
                                                                    val))))))
                                             (t "err:unk typedata"))))
                                    (:btn (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))))))))
                     ((equal 'cons (type-of val)) ;; COLLECTION
                      (tpl:frmtbl
                       (list :objs
                             (loop :for obj :in val :collect
                                (loop :for infld :in (getf act :fields) :collect
                                   (let ((typefld (car infld)))
                                     (ecase typefld
                                       (:fld
                                        (let ((captfld   (getf infld :name))
                                              (permfld   (getf infld :perm))
                                              (typedata  (getf infld :typedata)))
                                          (cond ((equal typedata '(str))
                                                 (tpl:strview
                                                  (list :value
                                                        (funcall
                                                         (intern
                                                          (format nil "A-~A" (getf infld :fld))
                                                          (find-package "WIZARD"))
                                                         obj))))
                                                (t "err:unk typedata"))))
                                       (:btn
                                        (tpl:btn (list :name (getf infld :btn) :value (getf infld :value)))))))))))
                     (t "444"))))))))
