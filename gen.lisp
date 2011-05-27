

;; Containers
(defparameter *USER*                        (make-hash-table :test #'equal))
(defparameter *OFFER*                       (make-hash-table :test #'equal))
(defparameter *OFFER-RESOURCE*              (make-hash-table :test #'equal))
(defparameter *SALE*                        (make-hash-table :test #'equal))
(defparameter *SUPPLIER-RESOURCE-PRICE*     (make-hash-table :test #'equal))

;; Classes

(defclass USER (ENTITY)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)))

(defclass ADMIN (USER)
  ((LAST-VISITS            :initarg :LAST-VISITS         :initform nil :accessor LAST-VISITS)))

(defclass EXPERT (USER)
  ((LAST-TENDERS           :initarg :LAST-TENDERS        :initform nil :accessor LAST-TENDERS)))

(defclass SUPPLIER (USER)
  ((REFERAL                :initarg :REFERAL             :initform nil :accessor REFERAL)
   (STATUS                 :initarg :STATUS              :initform nil :accessor STATUS)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor JURIDICAL-ADDRESS)
   (ACTUAL-ADDRESS         :initarg :ACTUAL-ADDRESS      :initform nil :accessor ACTUAL-ADDRESS)
   (CONTACTS               :initarg :CONTACTS            :initform nil :accessor CONTACTS)
   (EMAIL                  :initarg :EMAIL               :initform nil :accessor EMAIL)
   (SITE                   :initarg :SITE                :initform nil :accessor SITE)
   (HEADS                  :initarg :HEADS               :initform nil :accessor HEADS)
   (REQUISITES             :initarg :REQUISITES          :initform nil :accessor REQUISITES)
   (ADDRESSES              :initarg :ADDRESSES           :initform nil :accessor ADDRESSES)
   (CONTACT-PERSON         :initarg :CONTACT-PERSON      :initform nil :accessor CONTACT-PERSON)
   (RESOURCES              :initarg :RESOURCES           :initform nil :accessor RESOURCES)
   (SALE                   :initarg :SALE                :initform nil :accessor SALE)
   (OFFERS                 :initarg :OFFERS              :initform nil :accessor OFFERS)))

(defclass OFFER (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (TENDER                 :initarg :TENDER              :initform nil :accessor TENDER)
   (RESOURCES              :initarg :RESOURCES           :initform nil :accessor RESOURCES)))

(defclass OFFER-RESOURCE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (OFFER                  :initarg :OFFER               :initform nil :accessor OFFER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)))

(defclass SALE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PROCENT                :initarg :PROCENT             :initform nil :accessor PROCENT)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)
   (NOTES                  :initarg :NOTES               :initform nil :accessor NOTES)))

(defclass SUPPLIER-RESOURCE-PRICE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)))

(defclass BUILDER (USER)
  ((REFERAL                :initarg :REFERAL             :initform nil :accessor REFERAL)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor JURIDICAL-ADDRESS)
   (REQUISITES             :initarg :REQUISITES          :initform nil :accessor REQUISITES)
   (TENDERS                :initarg :TENDERS             :initform nil :accessor TENDERS)))
