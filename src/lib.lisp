
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

(defun get-btn-key (btn)
  (let* ((tilde (position #\~ btn))
         (id    (if tilde
                    (subseq btn (+ 1 tilde))
                    btn)))
    (parse-integer id)))

(defun change-expert-password ()
  (let ((key (get-btn-key (caar (last (form-data))))))
    (setf (a-password (gethash key *USER*))
          (cdr (assoc "PASSWORD" (form-data) :test #'equal))))
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun delete-expert ()
  (let ((key (get-btn-key (caar (form-data)))))
    (remhash key *USER*))
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun approve-supplier-fair ()
  (let ((key (get-btn-key (caar (form-data)))))
    (setf (a-status (gethash key *USER*))
          :fair))
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun supplier-request-fair ()
  (setf (a-status (gethash 3 *USER*))
        :request)
  (hunchentoot:redirect (hunchentoot:request-uri*)))

(defun del-supplier-resource-price ()
  (let ((key (get-btn-key (caar (form-data)))))
    (remhash key *SUPPLIER-RESOURCE-PRICE*))
  ;; (format nil "~A" (form-data)))
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

(defmacro a-fld (name obj)
  `(funcall
    (intern
     (format nil "A-~A" ,name)
     (find-package "WIZARD"))
    ,obj))

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
                                                     :fldcontent (tpl:pswdupd (list :name namefld)))))
                                             (t (format nil "<br />err:unk1 typedata: ~A" typedata)))))
                                    (:btn (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))))))))
                     ((or (equal 'ADMIN (type-of val)) ;; ADMIN
                          (equal 'SUPPLIER (type-of val)) ;; SUPPLIER
                          (equal 'TENDER (type-of val)) ;; TENDER
                          (equal 'BUILDER (type-of val))) ;; BUILDER
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
                                                     :fldcontent (tpl:strupd (list :name namefld :value (a-fld namefld val))))))
                                             ((equal typedata '(pswd))
                                              (tpl:fld
                                               (list :fldname captfld
                                                     :fldcontent
                                                     (tpl:pswdupd(list :name namefld :value (a-fld namefld val))))))
                                             (t (format nil "<br />err:unk2 typedata: ~A" typedata)))))
                                    (:btn
                                     (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))
                                    (:popbtn
                                     "<br />todo: popup")
                                    ))))))
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
                                          (cond ((or (equal typedata '(str))
                                                     (equal typedata '(num)))
                                                 (tpl:strview
                                                  (list :value
                                                        ;; (format nil "~A" (cdr obj))
                                                        (a-fld (getf infld :fld) (cdr obj)))))
                                                ((equal typedata '(link resource))
                                                 (a-name (a-fld (getf infld :fld) (cdr obj))))
                                                (t (format nil "err:unk3 typedata: ~A" typedata))))
                                        )
                                       (:btn
                                        (tpl:btn
                                         (list :name (format nil "~A~~~A"
                                                             (getf infld :btn)
                                                             (car obj))
                                               :value (format nil "~A" (getf infld :value))))
                                        )
                                       (:popbtn
                                        (tpl:popbtn
                                         (list :title (getf infld :title)
                                               :value (getf infld :value)
                                               :popid (format nil "~A~~~A" (getf infld :popbtn) (car obj))
                                               :content
                                               (tpl:frmobj
                                                (list :flds
                                                      (loop :for infld :in (getf infld :fields) :collect
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
                                                                              :fldcontent (tpl:strupd (list :name namefld
                                                                                                            :value (a-fld namefld (cdr obj)))))))
                                                                      ((equal typedata '(pswd))
                                                                       (tpl:fld
                                                                        (list :fldname captfld
                                                                              :fldcontent (tpl:strupd (list :name namefld
                                                                                                            :value (a-fld namefld (cdr obj)))))))
                                                                      (t (format nil "err:unk4 typedata: ~A" typedata)))))
                                                             (:btn
                                                              (tpl:btn
                                                               (list :name (format nil "~A~~~A"
                                                                                   (getf infld :btn)
                                                                                   (car obj))
                                                                     :value (format nil "~A" (getf infld :value)))))))
                                                         )))
                                               ))
                                        )
                                       ))))))
                      )
                     (t "Нет объектов"))))))))
