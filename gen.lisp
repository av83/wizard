

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

;; Classes


(defclass USER (ENTITY)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)))


(defclass ADMIN (USER)
  ((LAST-VISITS            :initarg :LAST-VISITS         :initform nil :accessor LAST-VISITS)))

(defmethod view ((object ADMIN) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Последние визиты : ~A" (LAST-VISITS object)))


(defclass EXPERT (USER)
  ((LAST-TENDERS           :initarg :LAST-TENDERS        :initform nil :accessor LAST-TENDERS)))

(defmethod initialize-instance :after ((object EXPERT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *USER*) *USER*) object))

(defmethod view ((object EXPERT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Последние тендеры : ~A" (LAST-TENDERS object)))


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

(defmethod initialize-instance :after ((object SUPPLIER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *USER*) *USER*) object))

(defmethod view ((object SUPPLIER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Реферал : ~A" (REFERAL object))
  (format t "~%Статус : ~A" (STATUS object))
  (format t "~%Организация-поставщик : ~A" (NAME object))
  (format t "~%Юридический адрес : ~A" (JURIDICAL-ADDRESS object))
  (format t "~%Фактический адрес : ~A" (ACTUAL-ADDRESS object))
  (format t "~%Контактные телефоны : ~A" (CONTACTS object))
  (format t "~%Email : ~A" (EMAIL object))
  (format t "~%Сайт организации : ~A" (SITE object))
  (format t "~%Руководство : ~A" (HEADS object))
  (format t "~%Реквизиты : ~A" (REQUISITES object))
  (format t "~%Адреса офисов и магазинов : ~A" (ADDRESSES object))
  (format t "~%Контактное лицо : ~A" (CONTACT-PERSON object))
  (format t "~%Поставляемые ресурсы : ~A" (RESOURCES object))
  (format t "~%Скидки и акции : ~A" (SALE object))
  (format t "~%Принятые тендеры : ~A" (OFFERS object)))


(defclass OFFER (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (TENDER                 :initarg :TENDER              :initform nil :accessor TENDER)
   (RESOURCES              :initarg :RESOURCES           :initform nil :accessor RESOURCES)))

(defmethod initialize-instance :after ((object OFFER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *OFFER*) *OFFER*) object))

(defmethod view ((object OFFER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Поставщик ресурсов : ~A" (OWNER object))
  (format t "~%Тендер : ~A" (TENDER object))
  (format t "~%Ресурсы заявки : ~A" (RESOURCES object)))


(defclass OFFER-RESOURCE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (OFFER                  :initarg :OFFER               :initform nil :accessor OFFER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)))

(defmethod initialize-instance :after ((object OFFER-RESOURCE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *OFFER-RESOURCE*) *OFFER-RESOURCE*) object))

(defmethod view ((object OFFER-RESOURCE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Поставщик : ~A" (OWNER object))
  (format t "~%Заявка : ~A" (OFFER object))
  (format t "~%Ресурс : ~A" (RESOURCE object))
  (format t "~%Цена поставщика : ~A" (PRICE object)))


(defclass SALE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PROCENT                :initarg :PROCENT             :initform nil :accessor PROCENT)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)
   (NOTES                  :initarg :NOTES               :initform nil :accessor NOTES)))

(defmethod initialize-instance :after ((object SALE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *SALE*) *SALE*) object))

(defmethod view ((object SALE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Поставщик : ~A" (OWNER object))
  (format t "~%Ресурс : ~A" (RESOURCE object))
  (format t "~%Процент скидки : ~A" (PROCENT object))
  (format t "~%Цена со скидкой : ~A" (PRICE object))
  (format t "~%Дополнительные условия : ~A" (NOTES object)))


(defclass SUPPLIER-RESOURCE-PRICE (ENTITY)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor RESOURCE)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)))

(defmethod initialize-instance :after ((object SUPPLIER-RESOURCE-PRICE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *SUPPLIER-RESOURCE-PRICE*) *SUPPLIER-RESOURCE-PRICE*) object))

(defmethod view ((object SUPPLIER-RESOURCE-PRICE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Поставщик : ~A" (OWNER object))
  (format t "~%Ресурс : ~A" (RESOURCE object))
  (format t "~%Цена поставщика : ~A" (PRICE object)))


(defclass BUILDER (USER)
  ((REFERAL                :initarg :REFERAL             :initform nil :accessor REFERAL)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor JURIDICAL-ADDRESS)
   (REQUISITES             :initarg :REQUISITES          :initform nil :accessor REQUISITES)
   (TENDERS                :initarg :TENDERS             :initform nil :accessor TENDERS)))

(defmethod initialize-instance :after ((object BUILDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *USER*) *USER*) object))

(defmethod view ((object BUILDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Реферал : ~A" (REFERAL object))
  (format t "~%Организация-застройщик : ~A" (NAME object))
  (format t "~%Юридический адрес : ~A" (JURIDICAL-ADDRESS object))
  (format t "~%Реквизиты : ~A" (REQUISITES object))
  (format t "~%Тендеры : ~A" (TENDERS object)))


(defclass CATEGORY (ENTITY)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (PARENT                 :initarg :PARENT              :initform nil :accessor PARENT)
   (CHILD-CATEGORYES       :initarg :CHILD-CATEGORYES    :initform nil :accessor CHILD-CATEGORYES)
   (RESOURCES              :initarg :RESOURCES           :initform nil :accessor RESOURCES)))

(defmethod initialize-instance :after ((object CATEGORY) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *CATEGORY*) *CATEGORY*) object))

(defmethod view ((object CATEGORY) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Имя : ~A" (NAME object))
  (format t "~%Родительская категория : ~A" (PARENT object))
  (format t "~%Дочерние категории : ~A" (CHILD-CATEGORYES object))
  (format t "~%Ресурсы : ~A" (RESOURCES object)))


(defclass RESOURCE (ENTITY)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (CATEGORY               :initarg :CATEGORY            :initform nil :accessor CATEGORY)
   (RESOURCE-TYPE          :initarg :RESOURCE-TYPE       :initform nil :accessor RESOURCE-TYPE)
   (UNIT                   :initarg :UNIT                :initform nil :accessor UNIT)
   (SUPPLIERS              :initarg :SUPPLIERS           :initform nil :accessor SUPPLIERS)))

(defmethod initialize-instance :after ((object RESOURCE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *RESOURCE*) *RESOURCE*) object))

(defmethod view ((object RESOURCE) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Наименование : ~A" (NAME object))
  (format t "~%Категория : ~A" (CATEGORY object))
  (format t "~%Тип : ~A" (RESOURCE-TYPE object))
  (format t "~%Единица измерения : ~A" (UNIT object))
  (format t "~%Поставляющие организации : ~A" (SUPPLIERS object)))


(defclass TENDER (ENTITY)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (STATUS                 :initarg :STATUS              :initform nil :accessor STATUS)
   (OWNER                  :initarg :OWNER               :initform nil :accessor OWNER)))

(defmethod initialize-instance :after ((object TENDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *TENDER*) *TENDER*) object))

(defmethod view ((object TENDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Название : ~A" (NAME object))
  (format t "~%Статус : ~A" (STATUS object))
  (format t "~%Заказчик : ~A" (OWNER object)))


(defclass DOCUMENT (ENTITY)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (FILENAME               :initarg :FILENAME            :initform nil :accessor FILENAME)
   (TENDER                 :initarg :TENDER              :initform nil :accessor TENDER)))

(defmethod initialize-instance :after ((object DOCUMENT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *DOCUMENT*) *DOCUMENT*) object))

(defmethod view ((object DOCUMENT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Название : ~A" (NAME object))
  (format t "~%Имя файла : ~A" (FILENAME object))
  (format t "~%Тендер : ~A" (TENDER object)))
