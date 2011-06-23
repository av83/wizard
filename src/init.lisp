(in-package #:wizard)

;; Containers

(defparameter *USER*                        (make-hash-table :test #'equal))
(defparameter *OFFER*                       (make-hash-table :test #'equal))
(defparameter *OFFER-RESOURCE*              (make-hash-table :test #'equal))
(defparameter *SALE*                        (make-hash-table :test #'equal))
(defparameter *SUPPLIER-RESOURCE-PRICE*     (make-hash-table :test #'equal))
(defparameter *CATEGORY*                    (make-hash-table :test #'equal))
(defparameter *RESOURCE*                    (make-hash-table :test #'equal))
(defparameter *TENDER*                      (make-hash-table :test #'equal))
(defparameter *DOCUMENT*                    (make-hash-table :test #'equal))



(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'ADMIN
                     :login "admin"
                     :password "admin"))

(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'EXPERT
                     :name "Эксперт-1"
                     :login "exp1"
                     :password "exp1"))

(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'EXPERT
                     :name "Эксперт-2"
                     :login "exp2"
                     :password "exp2"))

(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :fair
                     :name "Поставщик-1"
                     :login "supp1"
                     :password "supp1"))

(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :unfair
                     :name "Поставщик-2"
                     :login "supp2"
                     :password "supp2"))

(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :request
                     :name "Поставщик-3"
                     :login "supp3"
                     :password "supp3"))


;; dbg out
(maphash #'(lambda (k v)
             (print (list k v (a-login v))))
         *USER*)

