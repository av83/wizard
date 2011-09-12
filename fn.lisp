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
