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
  "get current user obj form session"
  (gethash (hunchentoot:session-value 'userid) *USER*))


(defun cur-id ()
  "get current user obj *TODO* !!!"
  (parse-integer (caddr (request-list))))


(defun form-data ()
  "get form data (get/post/ajax unification)"
  (hunchentoot:post-parameters*))


(defun request-str ()
  "multireturn request interpretations"
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
  ""
  (multiple-value-bind (request-str request-list request-get-plist)
      (request-str)
    request-get-plist))


(defun request-list ()
  ""
  (multiple-value-bind (request-str request-list request-get-plist)
      (request-str)
    request-list))


(defun get-btn-key (btn)
  "separate for btn form data"
  (let* ((tilde (position #\~ btn))
         (id    (if tilde
                    (subseq btn (+ 1 tilde))
                    btn)))
    (parse-integer id)))


(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part is replaced with replacement."
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

(defun activate (acts)
  "activation form processing"
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
