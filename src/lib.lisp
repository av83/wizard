
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
  (gethash (hunchentoot:session-value 'userid) *USER*))

(defun form-data ()
  (hunchentoot:post-parameters*))


(defun request-str ()
  (let* ((request-full-str (hunchentoot:request-uri hunchentoot:*request*))
         (request-parted-list (split-sequence:split-sequence #\? request-full-str))
         (request-str (string-right-trim "\/" (car request-parted-list)))
         (request-list (split-sequence:split-sequence #\/ request-str))
         (request-get-plist (if (null (cadr request-parted-list))
                                nil
                                ;; else
                                (let ((result))
                                  (loop :for param :in (split-sequence:split-sequence #\& (cadr request-parted-list)) :do
                                     (let ((split (split-sequence:split-sequence #\= param)))
                                       (setf (getf result (intern (string-upcase (car split)) :keyword))
                                             (if (null (cadr split))
                                                 ""
                                                 (cadr split)))))
                                  result))))
    (values request-str request-list request-get-plist)))


(defun request-get-plist ()
  (multiple-value-bind (request-str request-list request-get-plist)
      (request-str)
    request-get-plist))


(defun request-list ()
  (multiple-value-bind (request-str request-list request-get-plist)
      (request-str)
    request-list))


(defun get-btn-key (btn)
  (let* ((tilde (position #\~ btn))
         (id    (if tilde
                    (subseq btn (+ 1 tilde))
                    btn)))
    (parse-integer id)))

(defun auth (login password)
  (loop :for obj :being the :hash-values :in *USER* :using (hash-key key) :do
     (when (and (equal (a-login obj) login)
                (equal (a-password obj) password))
       (return-from auth
         (progn
           (setf (hunchentoot:session-value 'userid) key)
           (hunchentoot:redirect (hunchentoot:request-uri*))))))
  (hunchentoot:redirect (hunchentoot:request-uri*)))


(defun activate (acts)
  (when (assoc "AUTH" (form-data) :test #'equal)
    (return-from activate
      (auth (cdr (assoc "LOGIN" (form-data) :test #'equal))
            (cdr (assoc "PASSWORD" (form-data) :test #'equal)))))
  (when (assoc "LOGOUT" (form-data) :test #'equal)
    (return-from activate
      (progn
        (hunchentoot:delete-session-value 'userid)
        (hunchentoot:redirect (hunchentoot:request-uri*)))))
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


(defmacro with-let-infld (body)
  `(let ((namefld   (getf infld :fld))
         (captfld   (getf infld :name))
         (permfld   (getf infld :perm))
         (typedata  (getf infld :typedata))
         (access    (getf infld :access))
         (iface     (getf infld :iface)))
     ,body))


(defun show-fld (captfld tplfunc namefld valuefld)
  (tpl:fld
   (list :fldname captfld
         :fldcontent (funcall tplfunc (list :name namefld
                                            :value valuefld)))))

(defun show-acts (acts)
  (let* ((personal  (let ((userid (hunchentoot:session-value 'userid)))
                      (if (null userid)
                          (tpl:loginform)
                          (tpl:logoutform (list :user (a-login (gethash userid *USER*)))))))
         (popups    (list
                     (list :id "trest"      :title "Регистрация" :content "TODO"           :left 200 :width 500)
                     (list :id "popupLogin" :title "Вход"        :content (tpl:popuplogin) :left 720 :width 196)))
         (content
          (loop :for act :in acts :collect
             (list :title (getf act :title)
                   :content
                   (let ((val (funcall (getf act :val))))
                     (cond ((equal val :clear) ;; :CLEAR
                            (tpl:frmobj
                             (list :flds
                                   (loop :for infld :in (getf act :fields) :collect
                                      (let ((typefld (car infld)))
                                        (ecase typefld
                                          (:fld
                                           (with-let-infld
                                               (cond ((equal typedata '(:str))   (show-fld captfld #'tpl:strupd  namefld ""))
                                                     ((equal typedata '(:pswd))  (show-fld captfld #'tpl:pswdupd namefld ""))
                                                     ((equal typedata '(:num))   (show-fld captfld #'tpl:pswdupd namefld ""))
                                                     ((equal typedata '(:interval)) (show-fld captfld #'tpl:strupd  namefld ""))
                                                     (t (format nil "<br />err:unk1 typedata: ~A" typedata)))))
                                          (:btn
                                           (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))))))))
                           ((or (equal 'ADMIN (type-of val))     ;; ADMIN
                                (equal 'SUPPLIER (type-of val))  ;; SUPPLIER
                                (equal 'TENDER (type-of val))    ;; TENDER
                                (equal 'BUILDER (type-of val))   ;; BUILDER
                                (equal 'EXPERT (type-of val))    ;; EXPERT
                                (equal 'RESOURCE (type-of val))) ;; EXPERT
                            (tpl:frmobj
                             (list :flds
                                   (loop :for infld :in (getf act :fields) :collect
                                      (let ((typefld (car infld)))
                                        (ecase typefld
                                          (:fld
                                           (with-let-infld
                                               (cond ((equal typedata '(:str))  (show-fld captfld #'tpl:strupd  namefld (a-fld namefld val)))
                                                     ((equal typedata '(:pswd)) (show-fld captfld #'tpl:pswdupd namefld (a-fld namefld val)))
                                                     ((equal typedata '(:num))  (show-fld captfld #'tpl:strupd  namefld (a-fld namefld val)))
                                                     ((equal typedata '(:list-of-links tender))
                                                      (show-collection
                                                       (funcall access)
                                                       ;; iface
                                                       (eval (read-from-string
                                                              (gen-fields
                                                               iface
                                                               ;; '(name (:btn "Страница тендера"
                                                               ;;         :act (hunchentoot:redirect
                                                               ;;               (format nil "/tender/~A" (get-btn-key (caar (form-data)))))))
                                                               'tender)
                                                              ))))
                                                     ((equal typedata '(:list-of-keys supplier-status))
                                                      (tpl:fld
                                                       (list :fldname captfld
                                                             :fldcontent (tpl:strview (list :value (getf *supplier-status* (a-fld namefld val)))))))
                                                     ((equal typedata '(:list-of-str))
                                                      (tpl:fld
                                                       (list :fldname captfld
                                                             :fldcontent (tpl:textupd (list :name namefld
                                                                                            :value (a-fld namefld val))))))
                                                     ((equal typedata '(list-of-str)) (show-fld captfld #'tpl:strupd  namefld (a-fld namefld val)))
                                                     (t (format nil "<br />err:unk2 typedata: ~A | ~A" namefld typedata)))))
                                          (:btn
                                           (tpl:btn (list :name (getf infld :btn) :value (getf infld :value))))

                                          (:popbtn
                                           (with-let-infld
                                               (let* ((popid (getf infld :popbtn))
                                                      (popup (loop :for infld :in (getf infld :fields) :collect
                                                                (let ((typefld (car infld)))
                                                                  (ecase typefld
                                                                    (:fld
                                                                     (with-let-infld
                                                                         (cond ((equal typedata '(:str))
                                                                                (show-fld captfld #'tpl:strupd namefld))
                                                                               ((equal typedata '(:num))
                                                                                (show-fld captfld #'tpl:strupd namefld ""))
                                                                               ((equal typedata '(:link resource))
                                                                                (tpl:selres
                                                                                 (list :name "res"
                                                                                       :options
                                                                                       (mapcar #'(lambda (x)
                                                                                                   (list :id (car x)
                                                                                                         :name (a-name (cdr x))))
                                                                                               (cons-hash-list *RESOURCE*))
                                                                                       )))
                                                                               (t (format nil "err:unk5 typedata: ~A" typedata)))
                                                                       ))
                                                                    (:btn
                                                                     (tpl:btn (list :name (format nil "~A" (getf infld :btn))
                                                                                    :value (format nil "~A" (getf infld :value))))))))))
                                                 (push (list :id popid  :title (getf infld :title)  :left 200  :width 730
                                                             :content (tpl:frmobj (list :flds popup)))
                                                       popups)
                                                 (tpl:popbtn (list :value (getf infld :value) :popid popid)))))

                                          (:col
                                           (tpl:col (list :title (getf infld :col)
                                                          :content
                                                          ;; (format nil "~A" infld)
                                                          ;; )))
                                                          ;; (format nil "~A" (getf infld :fields)))))
                                                          (show-collection (funcall (getf infld :val))
                                                                           (getf infld :fields)))))
                                          ))))))
                           ((equal 'cons (type-of val)) ;; COLLECTION
                            (show-collection val (getf act :fields)))
                           (t "<div style=\"padding-left: 2px\">Нет объектов</div>")))))))
    (tpl:root
     (list
      :personal personal
      :popups popups
      :navpoints (menu)
      :content content))))

;; (eval (read-from-string "(values 1 2)"))


(defmacro show-collection (cons-val-list fields)
  `(tpl:frmtbl
   (list :objs
         (loop :for obj :in ,cons-val-list :collect
            (loop :for infld :in ,fields :collect
               (let ((typefld (car infld)))
                 (ecase typefld
                   (:fld
                    (with-let-infld
                        (cond ((or (equal typedata '(:str))
                                   (equal typedata '(:num)))
                               (tpl:strview (list :value (a-fld (getf infld :fld) (cdr obj)))))
                              ((equal typedata '(:link resource))
                               (a-name (a-fld (getf infld :fld) (cdr obj))))
                              (t (format nil "err:unk3 typedata: ~A" typedata)))))
                   (:btn
                    (tpl:btn (list :name (format nil "~A~~~A"  (getf infld :btn) (car obj))
                                   :value (format nil "~A" (getf infld :value)))))
                   (:popbtn
                    (let* ((popid (format nil "~A~~~A" (getf infld :popbtn) (car obj)))
                           (popup (loop :for infld :in (getf infld :fields) :collect
                                     (let ((typefld (car infld)))
                                       (ecase typefld
                                         (:fld
                                          (with-let-infld
                                              (cond ((equal typedata '(:str))
                                                     (show-fld captfld #'tpl:strupd namefld (a-fld namefld (cdr obj))))
                                                    ((equal typedata '(:pswd))
                                                     (show-fld captfld #'tpl:strupd namefld (a-fld namefld (cdr obj))))
                                                    (t (format nil "err:unk4 typedata: ~A" typedata)))))
                                         (:btn
                                          (tpl:btn (list :name (format nil "~A~~~A" (getf infld :btn) (car obj))
                                                         :value (format nil "~A" (getf infld :value))))))))))
                      (push (list :id popid  :title (getf infld :title)  :left 200  :width 730
                                  :content (tpl:frmobj (list :flds popup)))
                            popups)
                      (tpl:popbtn (list :value (getf infld :value) :popid popid)))))))))))
