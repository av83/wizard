(require 'RESTAS)
(require 'CLOSURE-TEMPLATE)
(require 'RESTAS-DIRECTORY-PUBLISHER)
(require 'CL-JSON)



(restas:define-module #:WIZARD
    (:use #:CL #:ITER ))

(in-package #:WIZARD)


(defmacro cons-hash-list (hash)
  `(loop :for obj :being the :hash-values :in ,hash :using (hash-key key) :collect
      (cons key obj)))

(defmacro push-hash (hash class &body init)
  `(setf (gethash (hash-table-count ,hash) ,hash)
         (make-instance ,class ,@init)))

(defmacro cons-inner-objs (hash inner-lst)
  `(let ((inner-lst ,inner-lst)
         (cons-hash (cons-hash-list ,hash)))
     (loop :for obj :in inner-lst :collect
        (loop :for cons :in cons-hash :collect
           (when (equal (cdr cons) obj)
             (return cons))))))

(defmacro del-inner-obj (form-element hash inner-lst)
  `(let* ((key  (get-btn-key ,form-element))
          (hobj (gethash key ,hash)))
     (setf ,inner-lst
           (remove-if #'(lambda (x)
                          (equal x hobj))
                      ,inner-lst))
     (remhash key ,hash)
     (hunchentoot:redirect (hunchentoot:request-uri*))))

(defmacro with-obj-save (obj &rest flds)
  `(progn
     ,@(loop :for fld :in flds :collect
          `(setf (,(intern (format nil "A-~A" (symbol-name fld))) ,obj)
                 (cdr (assoc ,(symbol-name fld) (form-data) :test #'equal))))
     (hunchentoot:redirect (hunchentoot:request-uri*))))

(defmacro to (format-str form-elt)
  `(hunchentoot:redirect
    (format nil ,format-str (get-btn-key ,form-elt))))

(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defun get-username (&aux (pid (sb-posix:getpid)))
  (sb-posix:passwd-name
   (sb-posix:getpwuid
    (sb-posix:stat-uid
     (sb-posix:stat (format nil "/proc/~A" pid))))))

(let ((path '(:RELATIVE "wizard")))
  (setf asdf:*central-registry*
        (remove-duplicates (append asdf:*central-registry*
                                   (list (merge-pathnames
                                          (make-pathname :directory path)
                                          (user-homedir-pathname))))
                           :test #'equal)))

(defparameter *basedir*  (format nil "/home/~A/wizard/" (get-username)))

(defun path (relative)
  (merge-pathnames relative *basedir*))

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
