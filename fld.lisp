(defpackage #:fld
  (:use #:cl)
  (:export :field
           :view
           :update
           :controller
           ))

(in-package #:fld)

(defparameter *validators* nil) ;; Валидаторы, определенные для полей

(defclass field ()
  ((name         :initarg :name        :initform "unknown_fld"       :accessor name)
   (value        :initarg :value       :initform ""                  :accessor value)
   (caption      :initarg :caption     :initform "Неизвестное поле"  :accessor caption)
   (typeclass    :initarg :typeclass   :initform :str                :accessor typeclass)
   (validators   :initarg :validators  :initform nil                 :accessor validators)
   ))

;; TODO: name нужно проверять на только английские маленькие буквы (без пробелов)
;; TODO: typeclass должен попадать в список разрешенных типов, валидаторы должны быть заранее определены

;; Возвращает html-код для просмотра поля
(defmethod view ((fld field))
  (format nil "<tr><td>~A</td><td>~A</td></tr>"
          (caption fld)
          (value fld)))

;; Возвращает html-код для редактирования поля
(defmethod update ((fld field))
  (format nil "<tr><td><input type=\"text\" name=\"~A\" value=\"~a\" /></td></tr>"
          (name fld)
          (caption fld)))

;; Возвращает функцию, которая применяет валидаторы к входному значению, и в случае успеха
;; возвращает T, иначе NIL
(defmethod controller ((fld field))
  (lambda (value)
    t))
