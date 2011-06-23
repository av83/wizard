
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

(defun change-self-password ()
  (setf (a-login (cur-user))     (cdr (assoc "LOGIN" (form-data) :test #'equal)))
  (setf (a-password (cur-user))  (cdr (assoc "PASSWORD" (form-data) :test #'equal)))
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun create-expert ()
  (make-instance 'expert
                 :login (cdr (assoc "LOGIN" (form-data) :test #'equal))
                 :password (cdr (assoc "PASSWORD" (form-data) :test #'equal))
                 :name (cdr (assoc "NAME" (form-data) :test #'equal)))
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun delete-expert ()
  (let* ((x (caar (form-data)))
         (tilde (position #\~ x))
         (id    (if tilde
                    (subseq x (+ 1 tilde))
                    x))
         (num (parse-integer id)))
    (remhash num *USER*))
  (hunchentoot:redirect (hunchentoot:request-uri*)))


(defun activate (acts)
  (with-output-to-string (*standard-output*)
    (format t "form-data: ")
    (print (form-data))
    (format t "<br />~%acts:")
    (loop :for key :in acts :do
       (print (car key))
       (when (assoc (car key)
                    (form-data)
                    :test #'(lambda (a b)
                              (flet ((tld (x)
                                       (let ((tilde (position #\~ x)))
                                         (if tilde
                                           (subseq x 0 tilde)
                                           x))))
                                (funcall #'equal (tld a) (tld b)))))
         (return-from activate (funcall (cdr key)))))
    "err: unk:post:controller"))




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
               (cond ((equal val :clear)
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
                                                     :fldcontent (tpl:strupd (list :name namefld)))))
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
                                                        ;; (format nil "~A" (cdr obj))
                                                        (funcall
                                                         (intern
                                                          (format nil "A-~A" (getf infld :fld))
                                                          (find-package "WIZARD"))
                                                         (cdr obj))
                                                        )))
                                                (t "err:unk typedata"))))
                                       (:btn
                                        (tpl:btn
                                         (list :name (format nil "~A~~~A"
                                                             (getf infld :btn)
                                                             (car obj))
                                               :value (format nil "~A" (getf infld :value))))))))))))
                     (t "Нет объектов"))))))))
