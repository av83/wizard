(in-package #:WIZARD)

(let ((path '(:RELATIVE "wizard")))
  (setf asdf:*central-registry*
        (remove-duplicates (append asdf:*central-registry*
                                   (list (merge-pathnames
                                          (make-pathname :directory path)
                                          (user-homedir-pathname))))
                           :test #'equal)))

(defparameter *basedir*  "/home/rigidus/wizard/")

(defun path (relative)
  (merge-pathnames relative *basedir*))

(closure-template:compile-template :common-lisp-backend (path "src/templates.soy"))

(restas:mount-submodule -static- (#:restas.directory-publisher)
  (restas.directory-publisher:*directory* (path "src/static/")))

(defun cur-user ()
  (gethash (hunchentoot:session-value 'userid) *USER*))

(defun cur-id ()
  (parse-integer (caddr (request-list))))

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
  `(if (equal val :clear)
       ""
       (funcall
        (intern
         (format nil "A-~A" ,name)
         (find-package "WIZARD"))
        ,obj)))

(defun show-fld (captfld tplfunc namefld valuefld)
  (tpl:fld
   (list :fldname captfld
         :fldcontent (funcall tplfunc (list :name namefld
                                            :value valuefld)))))

(defmacro with-let-infld (body)
  `(let ((namefld   (getf infld :fld))
         (captfld   (getf infld :name))
         (permfld   (getf infld :perm))
         (typedata  (getf infld :typedata)))
     ,body))

(defmacro with-infld-typedata-cond (default &rest cases)
  `(with-let-infld
       (cond ,@(loop :for case :in cases :collect
                  `((equal typedata ',(car case)) ,(cadr case)))
             (t ,default))))

(defmacro with-in-fld-case (fields &rest cases)
  `(loop :for infld :in ,fields :collect
      (let ((typefld (car infld)))
        (ecase typefld
          ,@(loop :for case :in cases :by #'cddr :collect
              (list case (getf cases case)))))))

(defmacro show-linear (fields)
  `(with-in-fld-case ,fields
     :fld    (with-infld-typedata-cond (format nil "<br />err:unk2 typedata: ~A | ~A" namefld typedata)
               ((:str)      (show-fld captfld #'tpl:strupd  namefld (a-fld namefld val)))
               ((:pswd)     (show-fld captfld #'tpl:pswdupd namefld (a-fld namefld val)))
               ((:num)      (show-fld captfld #'tpl:strupd  namefld (a-fld namefld val)))
               ((:interval) (show-fld captfld #'tpl:strupd namefld (a-fld namefld val)))
               ((:date)     (show-fld captfld #'tpl:strupd namefld (a-fld namefld val)))
               ((:list-of-keys supplier-status)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (getf *supplier-status* (a-fld namefld val)))))))
               ((:list-of-keys resource-types)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (getf *resource-types* (a-fld namefld val)))))))
               ((:list-of-keys tender-status)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (getf *tender-status* (a-fld namefld val)))))))
               ((:link builder)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (a-name (a-fld namefld val)))))))
               ((:link category)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (a-name (a-fld namefld val)))))))
               ((:link supplier)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (let ((it (a-fld namefld val)))
                                                               (if (null it)
                                                                   ""
                                                                   (a-name it))))))))
               ((:link tender)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:strview (list :value (a-name (a-fld namefld val)))))))
               ((:list-of-str)
                (tpl:fld
                 (list :fldname captfld
                       :fldcontent (tpl:textupd (list :name namefld
                                                      :value (a-fld namefld val)))))))
     :btn    (tpl:btnlin (list :name (getf infld :btn) :value (getf infld :value)))
     :popbtn (with-let-infld
                 (let* ((popid (getf infld :popbtn))
                        (popup (with-in-fld-case (getf infld :fields)
                                 :fld    (with-infld-typedata-cond (format nil "err:unk5 typedata: ~A" typedata)
                                           ((:str)   (show-fld captfld #'tpl:strupd namefld))
                                           ((:num)   (show-fld captfld #'tpl:strupd namefld))

                                           ((:link resource))
                                           (tpl:selres
                                            (list :name "res"
                                                  :options
                                                  (mapcar #'(lambda (x)
                                                              (list :id (car x)
                                                                    :name (a-name (cdr x))))
                                                          (cons-hash-list *RESOURCE*)))))
                                 :btn    (tpl:btn (list :name (format nil "~A" (getf infld :btn))
                                                        :value (format nil "~A" (getf infld :value))))
                                 :col    (tpl:col (list :title (getf infld :col)
                                                        :content (tpl:frmtbl
                                                                  (list :objs (show-collection (funcall (getf infld :val))
                                                                                               (getf infld :fields))))))
                                 )))
                   (push (list :id popid  :title (getf infld :title)  :left 200  :width 730
                               :content (tpl:frmobj (list :flds popup)))
                         popups)
                   (tpl:popbtn (list :value (getf infld :value) :popid popid))))
     :col    (tpl:col (list :title (getf infld :col)
                            :content (tpl:frmtbl
                                      (list :objs (show-collection (funcall (getf infld :val))
                                                                   (getf infld :fields))))))))

(defmacro show-collection (cons-val-list fields)
  `(loop :for obj :in ,cons-val-list :collect
      (with-in-fld-case ,fields
        :fld    (with-infld-typedata-cond (format nil "err:unk3 typedata: ~A" typedata)
                  ((:str)    (tpl:strview (list :value (a-fld (getf infld :fld) (cdr obj)))))
                  ((:num)    (tpl:strview (list :value (a-fld (getf infld :fld) (cdr obj)))))
                  ((:list-of-keys tender-status)
                   (tpl:strview (list :value (getf *tender-status* (a-fld (getf infld :fld) (cdr obj))))))
                  ((:list-of-keys resource-types)
                   (tpl:strview (list :value (getf *resource-types* (a-fld (getf infld :fld) (cdr obj))))))
                  ((:link builder)
                   (a-name (a-fld (getf infld :fld) (cdr obj)))
                   )
                  ;; (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link resource)
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link tender)
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link supplier)
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  )
        :btn    (tpl:btncol (list :name (format nil "~A~~~A"  (getf infld :btn) (car obj))
                                  :value (format nil "~A" (getf infld :value))))
        :popbtn (let* ((popid (format nil "~A~~~A" (getf infld :popbtn) (car obj)))
                       (popup (with-in-fld-case (getf infld :fields)
                                :fld     (with-infld-typedata-cond (format nil "err:unk4 typedata: ~A" typedata)
                                           ((:str)     (show-fld captfld #'tpl:strupd namefld (a-fld namefld (cdr obj))))
                                           ((:num)     (show-fld captfld #'tpl:strupd namefld (a-fld namefld (cdr obj))))
                                           ((:pswd)    (show-fld captfld #'tpl:strupd namefld (a-fld namefld (cdr obj)))))
                                :btn     (tpl:btn (list :name (format nil "~A~~~A" (getf infld :btn) (car obj))
                                                        :value (format nil "~A" (getf infld :value))))
                                :calc    (tpl:strview (list :value (funcall (getf infld :calc) obj)))
                                )))
                  (push (list :id popid  :title (getf infld :title)  :left 200  :width 730
                              :content (tpl:frmobj (list :flds popup)))
                        popups)
                  (tpl:popbtn (list :value (getf infld :value) :popid popid)))
        :calc   (tpl:strview (list :value (funcall (getf infld :calc) obj)))
        )))

(defun show-acts (acts)
  (let* ((personal  (let ((userid (hunchentoot:session-value 'userid)))
                      (if (null userid)
                          (tpl:loginform)
                          (tpl:logoutform (list :user (a-login (gethash userid *USER*)))))))
         (popups    (list
                     (list :id "trest"      :title "Регистрация" :content "TODO"           :left 200 :width 500)
                     (list :id "popupLogin" :title "Вход"        :content (tpl:popuplogin) :left 720 :width 196)))
         (content   (loop :for act :in acts :collect
                       (list :title (getf act :title)
                             :content
                             (let ((val (funcall (getf act :val))))
                               (cond ((or (equal :clear val)
                                          (equal 'ADMIN (type-of val))     ;; ADMIN
                                          (equal 'SUPPLIER (type-of val))  ;; SUPPLIER
                                          (equal 'TENDER (type-of val))    ;; TENDER
                                          (equal 'BUILDER (type-of val))   ;; BUILDER
                                          (equal 'EXPERT (type-of val))    ;; EXPERT
                                          (equal 'RESOURCE (type-of val))  ;; RESOURCE
                                          (equal 'OFFER (type-of val))     ;; OFFER
                                          (equal 'SALE (type-of val)))     ;; SALE
                                      (tpl:frmobj (list :flds (show-linear (getf act :fields)))))
                                     ((equal 'cons (type-of val))          ;; COLLECTION
                                      (tpl:frmtbl (list :objs (show-collection val (getf act :fields)))))
                                     (t "<div style=\"padding-left: 2px\">Нет объектов</div>")))))))
    (tpl:root
     (list
      :personal personal
      :popups popups
      :navpoints (menu)
      :content content))))


(restas:define-route grid ("/grid")
  "<rows>
<page>1</page>
<total>2</total>
<records>13</records>
<userdata name=\"tamount\">3820.00</userdata>
<userdata name=\"ttax\">462.00</userdata>
<userdata name=\"ttotal\">4284.00</userdata>
−
<row id=\"13\">
<cell>13</cell>
<cell>2007-10-06</cell>
<cell>Client 3</cell>
<cell>1000.00</cell>
<cell>0.00</cell>
<cell>1000.00</cell>
<cell></cell>
</row>
−
<row id=\"12\">
<cell>12</cell>
<cell>2007-10-06</cell>
<cell>Client 2</cell>
<cell>700.00</cell>
<cell>140.00</cell>
<cell>840.00</cell>
<cell></cell>
</row>
−
<row id=\"11\">
<cell>11</cell>
<cell>2007-10-06</cell>
<cell>Client 1</cell>
<cell>600.00</cell>
<cell>120.00</cell>
<cell>720.00</cell>
<cell></cell>
</row>
−
<row id=\"10\">
<cell>10</cell>
<cell>2007-10-06</cell>
<cell>Client 2</cell>
<cell>100.00</cell>
<cell>20.00</cell>
<cell>120.00</cell>
<cell></cell>
</row>
−
<row id=\"9\">
<cell>9</cell>
<cell>2007-10-06</cell>
<cell>Client 1</cell>
<cell>200.00</cell>
<cell>40.00</cell>
<cell>240.00</cell>
<cell></cell>
</row>
−
<row id=\"8\">
<cell>8</cell>
<cell>2007-10-06</cell>
<cell>Client 3</cell>
<cell>200.00</cell>
<cell>0.00</cell>
<cell>200.00</cell>
<cell></cell>
</row>
−
<row id=\"7\">
<cell>7</cell>
<cell>2007-10-05</cell>
<cell>Client 2</cell>
<cell>120.00</cell>
<cell>12.00</cell>
<cell>134.00</cell>
<cell></cell>
</row>
−
<row id=\"6\">
<cell>6</cell>
<cell>2007-10-05</cell>
<cell>Client 1</cell>
<cell>50.00</cell>
<cell>10.00</cell>
<cell>60.00</cell>
<cell></cell>
</row>
−
<row id=\"5\">
<cell>5</cell>
<cell>2007-10-05</cell>
<cell>Client 3</cell>
<cell>100.00</cell>
<cell>0.00</cell>
<cell>100.00</cell>
<cell>no tax at all</cell>
</row>
−
<row id=\"4\">
<cell>4</cell>
<cell>2007-10-04</cell>
<cell>Client 3</cell>
<cell>150.00</cell>
<cell>0.00</cell>
<cell>150.00</cell>
<cell>no tax</cell>
</row>
</rows>")


(restas:define-route rowed ("/rowed")
  "{\"page\":\"1\",\"total\":2,\"records\":\"13\",\"rows\":[{\"id\":\"13\",\"cell\":[\"\",\"13\",\"2007-10-06\",\"Client 3\",\"1000.00\",\"0.00\",\"1000.00\",null]},{\"id\":\"12\",\"cell\":[\"\",\"12\",\"2007-10-06\",\"Client 2\",\"700.00\",\"140.00\",\"840.00\",null]},{\"id\":\"11\",\"cell\":[\"\",\"11\",\"2007-10-06\",\"Client 1\",\"600.00\",\"120.00\",\"720.00\",null]},{\"id\":\"10\",\"cell\":[\"\",\"10\",\"2007-10-06\",\"Client 2\",\"100.00\",\"20.00\",\"120.00\",null]},{\"id\":\"9\",\"cell\":[\"\",\"9\",\"2007-10-06\",\"Client 1\",\"200.00\",\"40.00\",\"240.00\",null]},{\"id\":\"8\",\"cell\":[\"\",\"8\",\"2007-10-06\",\"Client 3\",\"200.00\",\"0.00\",\"200.00\",null]},{\"id\":\"7\",\"cell\":[\"\",\"7\",\"2007-10-05\",\"Client 2\",\"120.00\",\"12.00\",\"134.00\",null]},{\"id\":\"6\",\"cell\":[\"\",\"6\",\"2007-10-05\",\"Client 1\",\"50.00\",\"10.00\",\"60.00\",\"\"]},{\"id\":\"5\",\"cell\":[\"\",\"5\",\"2007-10-05\",\"Client 3\",\"100.00\",\"0.00\",\"100.00\",\"no tax at all\"]},{\"id\":\"4\",\"cell\":[\"\",\"4\",\"2007-10-04\",\"Client 3\",\"150.00\",\"0.00\",\"150.00\",\"no tax\"]}]}")

(restas:define-route rowed/post ("/rowed" :method :post)
  "{\"page\":\"1\",\"total\":2,\"records\":\"13\",\"rows\":[{\"id\":\"13\",\"cell\":[\"\",\"13\",\"2007-10-06\",\"Client 3\",\"1000.00\",\"0.00\",\"1000.00\",null]},{\"id\":\"12\",\"cell\":[\"\",\"12\",\"2007-10-06\",\"Client 2\",\"700.00\",\"140.00\",\"840.00\",null]},{\"id\":\"11\",\"cell\":[\"\",\"11\",\"2007-10-06\",\"Client 1\",\"600.00\",\"120.00\",\"720.00\",null]},{\"id\":\"10\",\"cell\":[\"\",\"10\",\"2007-10-06\",\"Client 2\",\"100.00\",\"20.00\",\"120.00\",null]},{\"id\":\"9\",\"cell\":[\"\",\"9\",\"2007-10-06\",\"Client 1\",\"200.00\",\"40.00\",\"240.00\",null]},{\"id\":\"8\",\"cell\":[\"\",\"8\",\"2007-10-06\",\"Client 3\",\"200.00\",\"0.00\",\"200.00\",null]},{\"id\":\"7\",\"cell\":[\"\",\"7\",\"2007-10-05\",\"Client 2\",\"120.00\",\"12.00\",\"134.00\",null]},{\"id\":\"6\",\"cell\":[\"\",\"6\",\"2007-10-05\",\"Client 1\",\"50.00\",\"10.00\",\"60.00\",\"\"]},{\"id\":\"5\",\"cell\":[\"\",\"5\",\"2007-10-05\",\"Client 3\",\"100.00\",\"0.00\",\"100.00\",\"no tax at all\"]},{\"id\":\"4\",\"cell\":[\"\",\"4\",\"2007-10-04\",\"Client 3\",\"150.00\",\"0.00\",\"150.00\",\"no tax\"]}]}")

