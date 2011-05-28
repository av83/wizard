(defpackage #:universal-accessor
  (:use #:cl)
  (:export
   #:ref
   #:enable-accessor-syntax
   #:disable-accessor-syntax))

(in-package #:universal-accessor)

(defgeneric ref (object key &key &allow-other-keys)
  (:documentation "Generic getter")
  (:method ((object sequence) (key fixnum) &key)
    (elt object key))
  (:method ((object array) (key fixnum) &key)
    (row-major-aref object key))
  (:method ((object hash-table) key &key default-value)
    (gethash key object default-value))
  (:method ((object standard-object) key &key)
    (slot-value object key))
  (:method ((object structure-object) (key symbol) &key)
    (slot-value object key)))

(defgeneric (setf ref) (new-value object key &key &allow-other-keys)
  (:documentation "Generic setter")
  (:method (new-value (object sequence) (key fixnum) &key)
    (setf (elt object key) new-value))
  (:method (new-value (object array) (key fixnum) &key)
    (setf (row-major-aref object key) new-value))
  (:method (new-value (object hash-table) key &key)
    (setf (gethash key object) new-value))
  (:method (new-value (object standard-object) key &key)
    (setf (slot-value object key) new-value))
  (:method (new-value (object structure-object) (key symbol) &key)
    (setf (slot-value object key) new-value)))

(defmethod ref ((object stream) (key (eql :char))
                &key (eof-error-p t) eof-value recursive-p (wait t)
                (peek-type nil peek-p))
  (if peek-p
      (peek-char peek-type object eof-error-p eof-value recursive-p)
      (funcall (if wait #'read-char #'read-char-no-hang)
               object eof-error-p eof-value recursive-p)))


(defmethod ref ((object stream) (key (eql :line))
                &key (eof-error-p t) eof-value recursive-p)
  (read-line object eof-error-p eof-value recursive-p))


(defmethod ref ((object stream) (key (eql :byte))
                &key (eof-error-p t) eof-value)
  (read-byte object eof-error-p eof-value))


(defmethod ref ((object stream) (key sequence) &key (start 0) end)
  (read-sequence key object :start start :end end))


(defmethod ref ((object stream) (key (eql t))
                &key (eof-error-p t) eof-value recursive-p)
  (read object eof-error-p eof-value recursive-p))


(defmethod ref ((object stream) (key (eql nil)) &key)
  (listen object))


(defmethod (setf ref) (new-value (object stream) (key (eql :char)) &key)
  (write-char new-value object))


(defmethod (setf ref) (new-value (object stream) (key (eql :string))
                       &key (start 0) end)
  (write-string new-value object :start start :end end))


(defmethod (setf ref) (new-value (object stream) (key (eql :line))
                       &key (start 0) end)
  (write-line new-value object :start start :end end))


(defmethod (setf ref) (new-value (object stream) (key (eql :sequence))
                       &key (start 0) end)
  (write-sequence new-value object :start start :end end))


(defmethod (setf ref) (new-value (object stream) (key (eql :byte)) &key)
  (write-byte new-value object))


(defmethod (setf ref) (new-value (object stream) (key (eql t)) &key)
  (write new-value :stream object))



(defun %read-lbracket (stream char)
  (declare (ignore char))
  (let ((form (read-delimited-list #\] stream t)))
    `(ref ,@form)))

(defun %read-rbracket (stream char)
  (declare (ignore stream char))
  (error "Unmatched close bracket"))


(defvar *accessor-readtables* '())


(defun %enable-accessor-syntax ()
  (push *readtable* *accessor-readtables*)
  (setf *readtable* (copy-readtable))
  (set-macro-character #\[ #'%read-lbracket)
  (set-macro-character #\] #'%read-rbracket)
  (values))


(defun %disable-accessor-syntax ()
  (unless (null *accessor-readtables*)
    (setf *readtable* (pop *accessor-readtables*)))
  (values))


(defmacro enable-accessor-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (%enable-accessor-syntax)))


(defmacro disable-accessor-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (%disable-accessor-syntax)))


;; (enable-accessor-syntax)

;; (let ((ht (make-hash-table)))
;;     (setf [ht :my-key] 123)
;;       (+ [ht :my-key]
;;               [ht :my-key]))

;; (setf [*standard-output* :line] "Hello, world!")
