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
  "Deprecated. For reference."
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


(defmacro show-grid (cons-val-list fields url)
  `(let ((grd (gensym "J"))
         (pgr (gensym "P"))
         (col-names)
         (col-model))
     (with-in-fld-case ,fields
       :fld     (progn
                  (push (getf infld :name) col-names)
                  (let* ((in-name  (getf infld :fld))
                         (model    `(("name"     . ,in-name)
                                     ("index"    . ,in-name)
                                     ("width"    . "300")
                                     ("sortable" . nil)
                                     ("editable" . t))))
                    (push model col-model)))
       :btn     ""
       :popbtn  ""
       :calc    "")
     (setf col-names (reverse col-names))
     (setf col-model (reverse col-model))
     (grid-helper grd pgr
                  (json:encode-json-to-string
                   `(("url"         . ,,url)
                     ("datatype"    . "json")
                     ("colNames"    . ,col-names)
                     ("colModel"    . ,col-model)
                     ("rowNum"      . 10)
                     ("rowList"     . (10 20 30))
                     ("pager"       . ,(format nil "#~A" pgr))
                     ("sortname"    . "id")
                     ("viewrecords" . t)
                     ("sortorder"   . "desc")
                     ("editurl"     . "/rowed")
                     ("caption"     . "show grid"))))))


(pprint (macroexpand-1 '(show-grid val (getf act :fields) "/rowed")))



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
                                      (show-grid val (getf act :fields) (getf act :grid)))
                                     (t "<div style=\"padding-left: 2px\">Нет объектов</div>")))))))
    (tpl:root
     (list
      :personal personal
      :popups popups
      :navpoints (menu)
      :content content))))

(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))


(defun grid-helper (grd pgr jsn)
  (format nil "<table id=\"~A\"></table><div id=\"~A\"></div>
               <script type=\"text/javascript\">
               jQuery('#~A').jqGrid(~A);
               jQuery('#~A').jqGrid('navGrid','#~A',{edit:false,add:false,del:false});
               </script>"
          grd pgr grd jsn grd pgr))

;; (defun xxx ()
;;   (print
;;    (grid-helper (gensym "J") (gensym "J")
;;               (json:encode-json-to-string
;;                '(("url"      . "/rowed")
;;                  ("datatype" . "json")
;;                  ("colNames" . ("Actions" "Inv No" "Date"  "Client" "Amount" "Tax" "Total" "Notes"))
;;                  ("colModel" . ((("name" . "act")      ("index" . "act")       ("width" . "100")  ("sortable" . nil)  ("editable" . nil))
;;                                 (("name" . "id")       ("index" . "id")        ("width" . "55")   ("sortable" . nil)  ("editable" . t))
;;                                 (("name" . "invdate")  ("index" . "invdate")   ("width" . "100")  ("sortable" . nil)  ("editable" . t))
;;                                 (("name" . "name")     ("index" . "name")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))
;;                                 (("name" . "amount")   ("index" . "amount")    ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
;;                                 (("name" . "tax")      ("index" . "tax")       ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
;;                                 (("name" . "total")    ("index" . "total")     ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
;;                                 (("name" . "note")     ("index" . "note")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))))
;;                  ("rowNum"   . 10)
;;                  ("rowList"  . (10 20 30))
;;                  ("pager"    . "#prowed2")
;;                  ("sortname" . "id")
;;                  ("viewrecords" . t)
;;                  ("sortorder" . "desc")
;;                  ("gridComplete" . "-=|=-")
;;                  ("editurl"  . "/rowed")
;;                  ("caption" . "Testttttt3333")))
;;               )))


(defun jqgen ()
  (format nil "<table id=\"rowed2\"></table><div id=\"prowed2\"></div><br />
               <script type=\"text/javascript\">
               jQuery('#~A').jqGrid(~A)~%~A
               </script>"
          "rowed2"
          (replace-all
           (json:encode-json-to-string
            '(("url"      . "/rowed")
              ("datatype" . "json")
              ("colNames" . ("Actions" "Inv No" "Date"  "Client" "Amount" "Tax" "Total" "Notes"))
              ("colModel" . ((("name" . "act")      ("index" . "act")       ("width" . "100")  ("sortable" . nil)  ("editable" . nil))
                             (("name" . "id")       ("index" . "id")        ("width" . "55")   ("sortable" . nil)  ("editable" . t))
                             (("name" . "invdate")  ("index" . "invdate")   ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "name")     ("index" . "name")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "amount")   ("index" . "amount")    ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "tax")      ("index" . "tax")       ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "total")    ("index" . "total")     ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "note")     ("index" . "note")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))))
              ("rowNum"   . 10)
              ("rowList"  . (10 20 30))
              ("pager"    . "#prowed2")
              ("sortname" . "id")
              ("viewrecords" . t)
              ("sortorder" . "desc")
              ("gridComplete" . "-=|=-")
              ("editurl"  . "/rowed")
              ("caption" . "Testttttt")))
           "\"-=|=-\","
           (alexandria:read-file-into-string (path "src/static/rowedex3.js")))
          "jQuery('#rowed2').jqGrid('navGrid','#prowed2',{edit:false,add:false,del:false});"
          ))


(restas:define-route jqgen ("/jqgen")
  ;; (alexandria:read-file-into-string (path "src/static/rowedex2.js")))
  (format nil "jQuery('#~A').jqGrid(~A)~%~A"
          "rowed2"
          (replace-all
           (json:encode-json-to-string
            '(("url"      . "/rowed")
              ("datatype" . "json")
              ("colNames" . ("Actions" "Inv No" "Date"  "Client" "Amount" "Tax" "Total" "Notes"))
              ("colModel" . ((("name" . "act")      ("index" . "act")       ("width" . "100")  ("sortable" . nil)  ("editable" . nil))
                             (("name" . "id")       ("index" . "id")        ("width" . "55")   ("sortable" . nil)  ("editable" . t))
                             (("name" . "invdate")  ("index" . "invdate")   ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "name")     ("index" . "name")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "amount")   ("index" . "amount")    ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "tax")      ("index" . "tax")       ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "total")    ("index" . "total")     ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "note")     ("index" . "note")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))))
              ("rowNum"   . 10)
              ("rowList"  . (10 20 30))
              ("pager"    . "#prowed2")
              ("sortname" . "id")
              ("viewrecords" . t)
              ("sortorder" . "desc")
              ("gridComplete" . "-=|=-")
              ("editurl"  . "/rowed")
              ("caption" . "Testttttt")))
           "\"-=|=-\","
           (alexandria:read-file-into-string (path "src/static/rowedex3.js")))
          "jQuery('#rowed2').jqGrid('navGrid','#prowed2',{edit:false,add:false,del:false});"
          ))




(defun json-assembly (page total records rows)
  "rows: `(id fld1 fld2 fld3...)"
  (json:encode-json-to-string
   `(("page"    . ,page)
     ("total"   . ,total)
     ("records" . ,records)
     ("rows"    . ,(loop :for row :in rows :collect
                      `(("id"   . ,(car row))
                        ("cell" . ,(cdr row))))))))

;; (let ((val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'EXPERT))
;;                                      (CONS-HASH-LIST *USER*)))))



(defun example-json (val fields)
  ;; (let* ((val (funcall val)))
  (let ((val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'EXPERT))
                                       (CONS-HASH-LIST *USER*)))))
    (json-assembly 1 2 9
                   (loop :for item :in (funcall val) :collect
                      (let ((id  (car item))
                            (obj (cdr item)))
                        `(,id
                          ,(a-name obj)
                          ,(a-login obj)))))))

                   ;; (loop :for i from 1 :to 9 :collect
                   ;;    `(,(car
                   ;;      ,(format nil "Client ~A" i)
                   ;;      ,(random 50)))))

(restas:define-route rowed ("/rowed")
  (example-json))

(restas:define-route rowed/post ("/rowed" :method :post)
  (example-json))

;; (defun jq-script (id pager)
;;   (format nil "  <script type=\"text/javascript\">
;; jQuery("#rowed2").jqGrid({
;;     url:'/rowed',
;;     datatype: "json",
;;     colNames:['Actions','Inv No','Date', 'Client', 'Amount','Tax','Total','Notes'],
;;     colModel:[
;;         {name:'act',index:'act', width:100,sortable:false},
;;         {name:'id',index:'id', width:55},
;;         {name:'invdate',index:'invdate', width:90, editable:true},
;;         {name:'name',index:'name', width:100,editable:true},
;;         {name:'amount',index:'amount', width:80, align:"right",editable:true},
;;         {name:'tax',index:'tax', width:80, align:"right",editable:true},
;;         {name:'total',index:'total', width:80,align:"right",editable:true},
;;         {name:'note',index:'note', width:150, sortable:false,editable:true}
;;     ],
;;     rowNum:10,
;;     rowList:[10,20,30],
;;     pager: '#prowed2',
;;     sortname: 'id',
;;     viewrecords: true,
;;     sortorder: "desc",
;;     gridComplete: function(){
;;         var ids = jQuery("#rowed2").jqGrid('getDataIDs');
;;         for(var i=0;i<ids.length;i++){
;;             var cl = ids[i];
;;             be = "<input style='height:22px;width:20px;' type='button' value='E' onclick=\"jQuery('#rowed2').jqGrid('editRow','"+cl+"');\"  />";
;;             se = "<input style='height:22px;width:20px;' type='button' value='S' onclick=\"jQuery('#rowed2').jqGrid('saveRow','"+cl+"');\"  />";
;;             ce = "<input style='height:22px;width:20px;' type='button' value='C' onclick=\"jQuery('#rowed2').jqGrid('restoreRow','"+cl+"');\" />";
;;             my = "<input style='height:22px;width:30px;' type='button' value='my' onclick=\"location.href='http://ya.ru';\" />";
;;             jQuery("#rowed2").jqGrid('setRowData',ids[i],{act:be+se+ce+my});
;;             }
;;             },
;;             editurl: "/rowed",
;;             caption:"Custom edit "
;;             });
;;   jQuery("#rowed2").jqGrid('navGrid',"#prowed2",{edit:false,add:false,del:false});

;;   </script>
;;   <table id=\"~A\">
;;     <tr>
;;       <td></td>
;;     </tr>
;;   </table>
;;   <div id=\"~A\"></div>


;; jQuery("#rowed2").jqGrid({
;;     url:'/rowed',
;;     datatype: "json",



;; " id pager id pager))

;; (print (jq-script "test" "pager"))
