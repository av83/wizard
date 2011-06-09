
(require 'RESTAS)
(require 'CLOSURE-TEMPLATE)

(restas:define-module #:WIZARD
    (:use #:CL #:ITER ))

(in-package #:WIZARD)

(let ((path '(:RELATIVE "wizard")))
  (setf asdf:*central-registry*
        (remove-duplicates (append asdf:*central-registry*
                                   (list (merge-pathnames
                                          (make-pathname :directory path)
                                          (user-homedir-pathname))))
                           :test #'equal)))

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


(defclass ADMIN (entity)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)))

(defmethod view ((object ADMIN) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Логин : ~A" (LOGIN object))
  (format t "~%Пароль : ~A" (PASSWORD object)))


(defclass EXPERT (entity)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)))

(defmethod initialize-instance :after ((object EXPERT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *USER*) *USER*) object))

(defmethod view ((object EXPERT) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Логин : ~A" (LOGIN object))
  (format t "~%Пароль : ~A" (PASSWORD object))
  (format t "~%ФИО : ~A" (NAME object)))


(defclass SUPPLIER (entity)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (REFERAL                :initarg :REFERAL             :initform nil :accessor LNK-REFERAL)
   (STATUS                 :initarg :STATUS              :initform nil :accessor STATUS)
   (JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor JURIDICAL-ADDRESS)
   (ACTUAL-ADDRESS         :initarg :ACTUAL-ADDRESS      :initform nil :accessor ACTUAL-ADDRESS)
   (CONTACTS               :initarg :CONTACTS            :initform nil :accessor CONTACTS)
   (EMAIL                  :initarg :EMAIL               :initform nil :accessor EMAIL)
   (SITE                   :initarg :SITE                :initform nil :accessor SITE)
   (HEADS                  :initarg :HEADS               :initform nil :accessor HEADS)
   (INN                    :initarg :INN                 :initform nil :accessor INN)
   (KPP                    :initarg :KPP                 :initform nil :accessor KPP)
   (OGRN                   :initarg :OGRN                :initform nil :accessor OGRN)
   (BANK-NAME              :initarg :BANK-NAME           :initform nil :accessor BANK-NAME)
   (BIK                    :initarg :BIK                 :initform nil :accessor BIK)
   (CORRESP-ACCOUNT        :initarg :CORRESP-ACCOUNT     :initform nil :accessor CORRESP-ACCOUNT)
   (CLIENT-ACCOUNT         :initarg :CLIENT-ACCOUNT      :initform nil :accessor CLIENT-ACCOUNT)
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
  (format t "~%Логин : ~A" (LOGIN object))
  (format t "~%Пароль : ~A" (PASSWORD object))
  (format t "~%Название организации : ~A" (NAME object))
  (format t "~%Реферал : ~A" (REFERAL object))
  (format t "~%Статус : ~A" (STATUS object))
  (format t "~%Юридический адрес : ~A" (JURIDICAL-ADDRESS object))
  (format t "~%Фактический адрес : ~A" (ACTUAL-ADDRESS object))
  (format t "~%Контактные телефоны : ~A" (CONTACTS object))
  (format t "~%Email : ~A" (EMAIL object))
  (format t "~%Сайт организации : ~A" (SITE object))
  (format t "~%Руководство : ~A" (HEADS object))
  (format t "~%Инн : ~A" (INN object))
  (format t "~%КПП : ~A" (KPP object))
  (format t "~%ОГРН : ~A" (OGRN object))
  (format t "~%Название банка : ~A" (BANK-NAME object))
  (format t "~%Банковский идентификационный код : ~A" (BIK object))
  (format t "~%Корреспондентский счет) : ~A" (CORRESP-ACCOUNT object))
  (format t "~%Рассчетный счет : ~A" (CLIENT-ACCOUNT object))
  (format t "~%Адреса офисов и магазинов : ~A" (ADDRESSES object))
  (format t "~%Контактное лицо : ~A" (CONTACT-PERSON object))
  (format t "~%Поставляемые ресурсы : ~A" (RESOURCES object))
  (format t "~%Скидки и акции : ~A" (SALE object))
  (format t "~%Посланные заявки на тендеры : ~A" (OFFERS object)))


(defclass OFFER (entity)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor LNK-OWNER)
   (TENDER                 :initarg :TENDER              :initform nil :accessor LNK-TENDER)
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


(defclass OFFER-RESOURCE (entity)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor LNK-OWNER)
   (OFFER                  :initarg :OFFER               :initform nil :accessor LNK-OFFER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor LNK-RESOURCE)
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


(defclass SALE (entity)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor LNK-OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor LNK-RESOURCE)
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


(defclass SUPPLIER-RESOURCE-PRICE (entity)
  ((OWNER                  :initarg :OWNER               :initform nil :accessor LNK-OWNER)
   (RESOURCE               :initarg :RESOURCE            :initform nil :accessor LNK-RESOURCE)
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


(defclass BUILDER (entity)
  ((LOGIN                  :initarg :LOGIN               :initform nil :accessor LOGIN)
   (PASSWORD               :initarg :PASSWORD            :initform nil :accessor PASSWORD)
   (NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor JURIDICAL-ADDRESS)
   (INN                    :initarg :INN                 :initform nil :accessor INN)
   (KPP                    :initarg :KPP                 :initform nil :accessor KPP)
   (OGRN                   :initarg :OGRN                :initform nil :accessor OGRN)
   (BANK-NAME              :initarg :BANK-NAME           :initform nil :accessor BANK-NAME)
   (BIK                    :initarg :BIK                 :initform nil :accessor BIK)
   (CORRESP-ACCOUNT        :initarg :CORRESP-ACCOUNT     :initform nil :accessor CORRESP-ACCOUNT)
   (CLIENT-ACCOUNT         :initarg :CLIENT-ACCOUNT      :initform nil :accessor CLIENT-ACCOUNT)
   (TENDERS                :initarg :TENDERS             :initform nil :accessor TENDERS)
   (RATING                 :initarg :RATING              :initform nil :accessor RATING)))

(defmethod initialize-instance :after ((object BUILDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Запись в контейнер
  (setf (gethash (hash-table-count *USER*) *USER*) object))

(defmethod view ((object BUILDER) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Логин : ~A" (LOGIN object))
  (format t "~%Пароль : ~A" (PASSWORD object))
  (format t "~%Организация-застройщик : ~A" (NAME object))
  (format t "~%Юридический адрес : ~A" (JURIDICAL-ADDRESS object))
  (format t "~%Инн : ~A" (INN object))
  (format t "~%КПП : ~A" (KPP object))
  (format t "~%ОГРН : ~A" (OGRN object))
  (format t "~%Название банка : ~A" (BANK-NAME object))
  (format t "~%Банковский идентификационный код : ~A" (BIK object))
  (format t "~%Корреспондентский счет) : ~A" (CORRESP-ACCOUNT object))
  (format t "~%Рассчетный счет : ~A" (CLIENT-ACCOUNT object))
  (format t "~%Тендеры : ~A" (TENDERS object))
  (format t "~%Рейтинг : ~A" (RATING object)))


(defclass CATEGORY (entity)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (PARENT                 :initarg :PARENT              :initform nil :accessor LNK-PARENT)
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


(defclass RESOURCE (entity)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (CATEGORY               :initarg :CATEGORY            :initform nil :accessor LNK-CATEGORY)
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


(defclass TENDER (entity)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (STATUS                 :initarg :STATUS              :initform nil :accessor STATUS)
   (OWNER                  :initarg :OWNER               :initform nil :accessor LNK-OWNER)
   (ACTIVE-DATE            :initarg :ACTIVE-DATE         :initform nil :accessor ACTIVE-DATE)
   (ALL                    :initarg :ALL                 :initform nil :accessor ALL)
   (CLAIM                  :initarg :CLAIM               :initform nil :accessor CLAIM)
   (ANALIZE                :initarg :ANALIZE             :initform nil :accessor ANALIZE)
   (INTERVIEW              :initarg :INTERVIEW           :initform nil :accessor INTERVIEW)
   (RESULT                 :initarg :RESULT              :initform nil :accessor RESULT)
   (WINNER                 :initarg :WINNER              :initform nil :accessor LNK-WINNER)
   (PRICE                  :initarg :PRICE               :initform nil :accessor PRICE)
   (RESOURCES              :initarg :RESOURCES           :initform nil :accessor RESOURCES)
   (DOCUMENTS              :initarg :DOCUMENTS           :initform nil :accessor DOCUMENTS)
   (SUPPLIERS              :initarg :SUPPLIERS           :initform nil :accessor SUPPLIERS)
   (OFFERTS                :initarg :OFFERTS             :initform nil :accessor OFFERTS)))

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
  (format t "~%Заказчик : ~A" (OWNER object))
  (format t "~%Дата активации : ~A" (ACTIVE-DATE object))
  (format t "~%Срок проведения : ~A" (ALL object))
  (format t "~%Срок подачи заявок : ~A" (CLAIM object))
  (format t "~%Срок рассмотрения заявок : ~A" (ANALIZE object))
  (format t "~%Срок проведения интервью : ~A" (INTERVIEW object))
  (format t "~%Срок подведения итогов : ~A" (RESULT object))
  (format t "~%Победитель тендера : ~A" (WINNER object))
  (format t "~%Рекомендуемая стоимость : ~A" (PRICE object))
  (format t "~%Ресурсы : ~A" (RESOURCES object))
  (format t "~%Документы : ~A" (DOCUMENTS object))
  (format t "~%Поставщики : ~A" (SUPPLIERS object))
  (format t "~%Откликнувшиеся поставщики : ~A" (OFFERTS object)))


(defclass DOCUMENT (entity)
  ((NAME                   :initarg :NAME                :initform nil :accessor NAME)
   (FILENAME               :initarg :FILENAME            :initform nil :accessor FILENAME)
   (TENDER                 :initarg :TENDER              :initform nil :accessor LNK-TENDER)))

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

(restas:define-route main-page ("/")
  (format nil "test"))

(restas:define-route admin-page ("/admin")
  (format nil "test"))

(restas:define-route supplier-page ("/supplier")
  (format nil "test"))

(restas:define-route tender-page ("/tender")
  (format nil "test"))

(restas:define-route builder-page ("/builder")
  (format nil "test"))

(restas:define-route builders-page ("/builders")
  (format nil "test"))
