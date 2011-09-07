(in-package #:WIZARD)


(defmacro show-grid (cons-val-list fields url)
  `(let ((grid-id (gensym "J"))
         (pager-id (gensym "P"))
         (col-names)
         (col-model)
         (col-replace))
     (with-in-fld-case ,fields
       :fld     (progn
                  (push (getf infld :name) col-names)
                  (let* ((in-name  (getf infld :fld))
                         (model    `(("name"     . ,in-name)
                                     ("index"    . ,in-name)
                                     ("width"    . "200")
                                     ("sortable" . t)
                                     ("editable" . t))))
                    (push model col-model)))
       :btn     (progn
                  (let* ((in-name  (getf infld :btn))
                         (in-capt  (getf infld :value))
                         (btn-str  (format nil "\"<form method='post'><input type='submit' name='~A~~\"+cl+\"' value='~A' /></form>\"" in-name in-capt))
                         (model    `(("name"     . ,in-name)
                                     ("index"    . ,in-name)
                                     ("width"    . "200")
                                     ("sortable" . nil)
                                     ("editable" . nil))))
                    (push in-name col-names)
                    (push model col-model)
                    (push `(,in-name . ,btn-str) col-replace)
                    ))
       :popbtn  ""
       :calc    "")
     (let* ((grid-complete-js
             (format nil
                     " function(){
                        var ids = jQuery(\"#~A\").jqGrid('getDataIDs');
                        for(var i=0;i < ids.length;i++){
                          var cl = ids[i];
                          ~{~A~%~}
                        }
                      }"
                     grid-id
                     (loop :for replace :in (reverse col-replace) :collect
                        (format nil "jQuery(\"#~A\").jqGrid('setRowData',ids[i],{~A: ~A});"
                                grid-id
                                (car replace)
                                (cdr replace)))
                     )))
       (grid-helper grid-id pager-id
                    (replace-all
                     (json:encode-json-to-string
                      `(("url"          . ,,url)
                        ("datatype"     . "json")
                        ("colNames"     . ,(reverse col-names))
                        ("colModel"     . ,(reverse col-model))
                        ("rowNum"       . 3)
                        ("rowList"      . (2 3 5))
                        ("pager"        . ,(format nil "#~A" pager-id))
                        ("sortname"     . "id")
                        ("viewrecords"  . t)
                        ("sortorder"    . "desc")
                        ("editurl"      . "/edit_url")
                        ("gridComplete" . "-=|=-")
                        ("caption"     . "")))
                     "\"-=|=-\"" ;; замена после кодирования в json - иначе никак не вставить js :)
                     grid-complete-js
                     )))))


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
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link resource)
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link tender)
                   (a-name (a-fld (getf infld :fld) (cdr obj))))
                  ((:link supplier)
                   (a-name (a-fld (getf infld :fld) (cdr obj)))))
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


(defun grid-helper (grid-id pager-id json-code)
  (format nil "<table id=\"~A\"></table><div id=\"~A\"></div>
               <script type=\"text/javascript\">
               jQuery('#~A').jqGrid(~A);
               jQuery('#~A').jqGrid('navGrid','#~A',{edit:false,add:false,del:false});
               </script>"
          grid-id pager-id grid-id json-code grid-id pager-id))


(defun json-assembly (cur-page total-page rows-per-page rows)
  "rows: `(id fld1 fld2 fld3...)"
  (json:encode-json-to-string
   `(("page"    . ,cur-page)
     ("total"   . ,total-page)
     ("records" . ,rows-per-page)
     ("rows"    . ,(loop :for row :in rows :collect
                      `(("id"   . ,(car row))
                        ("cell" . ,(cdr row))))))))


(defun pager (val fields page rows-per-page)
  "[debugged 29.08.2011]"
  (let* ((rows            (funcall val))
         (cnt-rows        (length rows))
         (slice-cons)
         (fld-accessors))
    ;; slice-cons
    (loop :for num :from (* page rows-per-page) :below (* (+ 1 page) rows-per-page) :do
       (let ((row (nth num rows)))
         (unless (null row)
           (push (nth num rows) slice-cons))))
    ;; fld-accessors
    (loop :for fld :in fields :collect
       (let ((name (getf fld :fld)))
         (unless (null name)
           (when (equal '(:str) (getf fld :typedata)) ;; todo: perm check
             (push (intern (format nil "A-~A" name) (find-package "WIZARD")) fld-accessors)))))
    (values
     ;; result: get values from obj
     (loop :for cons :in (reverse slice-cons) :collect
        (let* ((id  (car cons))
               (obj (cdr cons))
               (res (loop :for accessor :in (reverse fld-accessors) :collect
                       (if (null accessor)
                           "---"
                           (funcall accessor obj)))))
          (push id res)))
     ;; cnt-rows - two result
     cnt-rows)))


(defun example-json (val fields)
  (let* ((page            (- (parse-integer (hunchentoot:get-parameter "page")) 1))
         (rows-per-page   (parse-integer (hunchentoot:get-parameter "rows"))))
    (multiple-value-bind (slice cnt-rows)
        (pager val fields page rows-per-page)
      (json-assembly  (+ page 1)  (ceiling cnt-rows rows-per-page)  (length slice) slice))))
