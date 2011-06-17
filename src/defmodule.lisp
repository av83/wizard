
(require 'RESTAS)
(require 'CLOSURE-TEMPLATE)
(require 'RESTAS-DIRECTORY-PUBLISHER)

(restas:define-module #:WIZARD
  (:use #:CL #:ITER ))

(in-package #:WIZARD)

(load "src/lib.lisp")

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
((LOGIN                  :initarg :LOGIN               :initform nil :accessor A-LOGIN)
(PASSWORD               :initarg :PASSWORD            :initform nil :accessor A-PASSWORD)))

(defmethod view ((object ADMIN) &key)
  ;; Здесь будет проверка прав
  ;; ...
  ;; Печать
  (format t "~%Логин : ~A" (LOGIN object))
  (format t "~%Пароль : ~A" (PASSWORD object)))


(defclass EXPERT (entity)
((LOGIN                  :initarg :LOGIN               :initform nil :accessor A-LOGIN)
(PASSWORD               :initarg :PASSWORD            :initform nil :accessor A-PASSWORD)
(NAME                   :initarg :NAME                :initform nil :accessor A-NAME)))

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
((LOGIN                  :initarg :LOGIN               :initform nil :accessor A-LOGIN)
(PASSWORD               :initarg :PASSWORD            :initform nil :accessor A-PASSWORD)
(NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(REFERAL                :initarg :REFERAL             :initform nil :accessor A-REFERAL)
(STATUS                 :initarg :STATUS              :initform nil :accessor A-STATUS)
(JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor A-JURIDICAL-ADDRESS)
(ACTUAL-ADDRESS         :initarg :ACTUAL-ADDRESS      :initform nil :accessor A-ACTUAL-ADDRESS)
(CONTACTS               :initarg :CONTACTS            :initform nil :accessor A-CONTACTS)
(EMAIL                  :initarg :EMAIL               :initform nil :accessor A-EMAIL)
(SITE                   :initarg :SITE                :initform nil :accessor A-SITE)
(HEADS                  :initarg :HEADS               :initform nil :accessor A-HEADS)
(INN                    :initarg :INN                 :initform nil :accessor A-INN)
(KPP                    :initarg :KPP                 :initform nil :accessor A-KPP)
(OGRN                   :initarg :OGRN                :initform nil :accessor A-OGRN)
(BANK-NAME              :initarg :BANK-NAME           :initform nil :accessor A-BANK-NAME)
(BIK                    :initarg :BIK                 :initform nil :accessor A-BIK)
(CORRESP-ACCOUNT        :initarg :CORRESP-ACCOUNT     :initform nil :accessor A-CORRESP-ACCOUNT)
(CLIENT-ACCOUNT         :initarg :CLIENT-ACCOUNT      :initform nil :accessor A-CLIENT-ACCOUNT)
(ADDRESSES              :initarg :ADDRESSES           :initform nil :accessor A-ADDRESSES)
(CONTACT-PERSON         :initarg :CONTACT-PERSON      :initform nil :accessor A-CONTACT-PERSON)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)
(SALE                   :initarg :SALE                :initform nil :accessor A-SALE)
(OFFERS                 :initarg :OFFERS              :initform nil :accessor A-OFFERS)))

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
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(TENDER                 :initarg :TENDER              :initform nil :accessor A-TENDER)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)))

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
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(OFFER                  :initarg :OFFER               :initform nil :accessor A-OFFER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)))

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
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PROCENT                :initarg :PROCENT             :initform nil :accessor A-PROCENT)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)
(NOTES                  :initarg :NOTES               :initform nil :accessor A-NOTES)))

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
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)))

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
((LOGIN                  :initarg :LOGIN               :initform nil :accessor A-LOGIN)
(PASSWORD               :initarg :PASSWORD            :initform nil :accessor A-PASSWORD)
(NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(JURIDICAL-ADDRESS      :initarg :JURIDICAL-ADDRESS   :initform nil :accessor A-JURIDICAL-ADDRESS)
(INN                    :initarg :INN                 :initform nil :accessor A-INN)
(KPP                    :initarg :KPP                 :initform nil :accessor A-KPP)
(OGRN                   :initarg :OGRN                :initform nil :accessor A-OGRN)
(BANK-NAME              :initarg :BANK-NAME           :initform nil :accessor A-BANK-NAME)
(BIK                    :initarg :BIK                 :initform nil :accessor A-BIK)
(CORRESP-ACCOUNT        :initarg :CORRESP-ACCOUNT     :initform nil :accessor A-CORRESP-ACCOUNT)
(CLIENT-ACCOUNT         :initarg :CLIENT-ACCOUNT      :initform nil :accessor A-CLIENT-ACCOUNT)
(TENDERS                :initarg :TENDERS             :initform nil :accessor A-TENDERS)
(RATING                 :initarg :RATING              :initform nil :accessor A-RATING)))

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
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(PARENT                 :initarg :PARENT              :initform nil :accessor A-PARENT)
(CHILD-CATEGORYES       :initarg :CHILD-CATEGORYES    :initform nil :accessor A-CHILD-CATEGORYES)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)))

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
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(CATEGORY               :initarg :CATEGORY            :initform nil :accessor A-CATEGORY)
(RESOURCE-TYPE          :initarg :RESOURCE-TYPE       :initform nil :accessor A-RESOURCE-TYPE)
(UNIT                   :initarg :UNIT                :initform nil :accessor A-UNIT)
(SUPPLIERS              :initarg :SUPPLIERS           :initform nil :accessor A-SUPPLIERS)))

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
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(STATUS                 :initarg :STATUS              :initform nil :accessor A-STATUS)
(OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(ACTIVE-DATE            :initarg :ACTIVE-DATE         :initform nil :accessor A-ACTIVE-DATE)
(ALL                    :initarg :ALL                 :initform nil :accessor A-ALL)
(CLAIM                  :initarg :CLAIM               :initform nil :accessor A-CLAIM)
(ANALIZE                :initarg :ANALIZE             :initform nil :accessor A-ANALIZE)
(INTERVIEW              :initarg :INTERVIEW           :initform nil :accessor A-INTERVIEW)
(RESULT                 :initarg :RESULT              :initform nil :accessor A-RESULT)
(WINNER                 :initarg :WINNER              :initform nil :accessor A-WINNER)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)
(DOCUMENTS              :initarg :DOCUMENTS           :initform nil :accessor A-DOCUMENTS)
(SUPPLIERS              :initarg :SUPPLIERS           :initform nil :accessor A-SUPPLIERS)
(OFFERTS                :initarg :OFFERTS             :initform nil :accessor A-OFFERTS)))

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
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(FILENAME               :initarg :FILENAME            :initform nil :accessor A-FILENAME)
(TENDER                 :initarg :TENDER              :initform nil :accessor A-TENDER)))

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
  (let ((acts (list 
               (list :perm ':ALL 
                     :title "Главная страница"
                     :content (tpl:frm (list :flds (list )))) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))

(restas:define-route admin-page ("/admin")
  (let ((acts (list 
               (list :perm ':ADMIN 
                     :title "Изменить пароль"
                     :content NIL) 
               (list :perm ':ADMIN 
                     :title "Создать аккаунт эксперта"
                     :content (tpl:frm (list :flds (list 
                                (tpl:rndfld (list :fldname "Логин" 
                                                  :fldcontent (tpl:simplefld (list :name "LOGIN" :value ""))))
                                (tpl:rndfld (list :fldname "Пароль" 
                                                  :fldcontent (tpl:simplefld (list :name "PASSWORD" :value ""))))
                                (tpl:simplebtn (list :name "Создать новый аккаунт эксперта" :value "Создать новый аккаунт эксперта")))))) 
               (list :perm ':ADMIN 
                     :title "Эксперты"
                     :content NIL) 
               (list :perm ':ADMIN 
                     :title "Заявки поставщиков на добросовестность"
                     :content NIL) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))

(restas:define-route supplier-page ("/supplier")
  (let ((acts (list 
               (list :perm '(AND :SELF :UNFAIR) 
                     :title "Отправить заявку на добросовестность"
                     :content (tpl:frm (list :flds (list 
                                (tpl:simplebtn (list :name "Отправить заявку на добросовестность" :value "Отправить заявку на добросовестность")))))) 
               (list :perm ':SELF 
                     :title "Изменить список ресурсов"
                     :content NIL) 
               (list :perm ':SELF 
                     :title "Заявки на тендеры"
                     :content NIL) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))

(restas:define-route tender-page ("/tender")
  (let ((acts (list 
               (list :perm '(AND :ACTIVE :FAIR) 
                     :title "Ответить заявкой на тендер"
                     :content (tpl:frm (list :flds (list 
                                (tpl:rndfld (list :fldname "Название" 
                                                  :fldcontent (tpl:simplefld (list :name "NAME" :value ""))))
                                (tpl:rndfld (list :fldname "Статус" 
                                                  :fldcontent (tpl:simplefld (list :name "STATUS" :value ""))))
                                (tpl:rndfld (list :fldname "Заказчик" 
                                                  :fldcontent (tpl:simplefld (list :name "OWNER" :value ""))))
                                (tpl:rndfld (list :fldname "Дата активации" 
                                                  :fldcontent (tpl:simplefld (list :name "ACTIVE-DATE" :value ""))))
                                (tpl:rndfld (list :fldname "Срок проведения" 
                                                  :fldcontent (tpl:simplefld (list :name "ALL" :value ""))))
                                (tpl:rndfld (list :fldname "Срок подачи заявок" 
                                                  :fldcontent (tpl:simplefld (list :name "CLAIM" :value ""))))
                                (tpl:rndfld (list :fldname "Срок рассмотрения заявок" 
                                                  :fldcontent (tpl:simplefld (list :name "ANALIZE" :value ""))))
                                (tpl:rndfld (list :fldname "Срок проведения интервью" 
                                                  :fldcontent (tpl:simplefld (list :name "INTERVIEW" :value ""))))
                                (tpl:rndfld (list :fldname "Срок подведения итогов" 
                                                  :fldcontent (tpl:simplefld (list :name "RESULT" :value ""))))
                                (tpl:rndfld (list :fldname "Победитель тендера" 
                                                  :fldcontent (tpl:simplefld (list :name "WINNER" :value ""))))
                                (tpl:rndfld (list :fldname "Рекомендуемая стоимость" 
                                                  :fldcontent (tpl:simplefld (list :name "PRICE" :value ""))))
                                (tpl:rndfld (list :fldname "Ресурсы" 
                                                  :fldcontent (tpl:simplefld (list :name "RESOURCES" :value ""))))
                                (tpl:rndfld (list :fldname "Документы" 
                                                  :fldcontent (tpl:simplefld (list :name "DOCUMENTS" :value ""))))
                                (tpl:rndfld (list :fldname "Поставщики" 
                                                  :fldcontent (tpl:simplefld (list :name "SUPPLIERS" :value ""))))
                                (tpl:rndfld (list :fldname "Откликнувшиеся поставщики" 
                                                  :fldcontent (tpl:simplefld (list :name "OFFERTS" :value ""))))
                                (tpl:simplebtn (list :name "Ответить заявкой на тендер" :value "Ответить заявкой на тендер")))))) 
               (list :perm ':OWNER 
                     :title "Отменить тендер"
                     :content (tpl:frm (list :flds (list 
                                (tpl:simplebtn (list :name "Отменить тендер" :value "Отменить тендер")))))) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))

(restas:define-route builder-page ("/builder")
  (let ((acts (list 
               (list :perm ':SELF 
                     :title "Застройщик такой-то (name object)"
                     :content (tpl:frm (list :flds (list 
                                (tpl:rndfld (list :fldname "Организация-застройщик" 
                                                  :fldcontent (tpl:simplefld (list :name "NAME" :value ""))))
                                (tpl:rndfld (list :fldname "Юридический адрес" 
                                                  :fldcontent (tpl:simplefld (list :name "JURIDICAL-ADDRESS" :value ""))))
                                (tpl:rndfld (list :fldname "Инн" 
                                                  :fldcontent (tpl:simplefld (list :name "INN" :value ""))))
                                (tpl:rndfld (list :fldname "КПП" 
                                                  :fldcontent (tpl:simplefld (list :name "KPP" :value ""))))
                                (tpl:rndfld (list :fldname "ОГРН" 
                                                  :fldcontent (tpl:simplefld (list :name "OGRN" :value ""))))
                                (tpl:rndfld (list :fldname "Название банка" 
                                                  :fldcontent (tpl:simplefld (list :name "BANK-NAME" :value ""))))
                                (tpl:rndfld (list :fldname "Банковский идентификационный код" 
                                                  :fldcontent (tpl:simplefld (list :name "BIK" :value ""))))
                                (tpl:rndfld (list :fldname "Корреспондентский счет)" 
                                                  :fldcontent (tpl:simplefld (list :name "CORRESP-ACCOUNT" :value ""))))
                                (tpl:rndfld (list :fldname "Рассчетный счет" 
                                                  :fldcontent (tpl:simplefld (list :name "CLIENT-ACCOUNT" :value ""))))
                                (tpl:rndfld (list :fldname "Тендеры" 
                                                  :fldcontent (tpl:simplefld (list :name "TENDERS" :value ""))))
                                (tpl:rndfld (list :fldname "Рейтинг" 
                                                  :fldcontent (tpl:simplefld (list :name "RATING" :value "")))))))) 
               (list :perm ':SELF 
                     :title "Объявить новый тендер"
                     :content (tpl:frm (list :flds (list 
                                (tpl:rndfld (list :fldname "Название" 
                                                  :fldcontent (tpl:simplefld (list :name "NAME" :value ""))))
                                (tpl:rndfld (list :fldname "Срок проведения" 
                                                  :fldcontent (tpl:simplefld (list :name "ALL" :value ""))))
                                (tpl:rndfld (list :fldname "Срок подачи заявок" 
                                                  :fldcontent (tpl:simplefld (list :name "CLAIM" :value ""))))
                                (tpl:rndfld (list :fldname "Срок рассмотрения заявок" 
                                                  :fldcontent (tpl:simplefld (list :name "ANALIZE" :value ""))))
                                (tpl:rndfld (list :fldname "Срок проведения интервью" 
                                                  :fldcontent (tpl:simplefld (list :name "INTERVIEW" :value ""))))
                                (tpl:rndfld (list :fldname "Срок подведения итогов" 
                                                  :fldcontent (tpl:simplefld (list :name "RESULT" :value ""))))
                                (tpl:rndfld (list :fldname "Ресурсы" 
                                                  :fldcontent (tpl:simplefld (list :name "RESOURCES" :value ""))))
                                (tpl:rndfld (list :fldname "Документы" 
                                                  :fldcontent (tpl:simplefld (list :name "DOCUMENTS" :value ""))))
                                (tpl:rndfld (list :fldname "Рекомендуемая стоимость" 
                                                  :fldcontent (tpl:simplefld (list :name "PRICE" :value ""))))
                                (tpl:rndfld (list :fldname "Поставщики" 
                                                  :fldcontent (tpl:simplefld (list :name "SUPPLIERS" :value ""))))
                                (tpl:simplebtn (list :name "Объявить тендер" :value "Объявить тендер")))))) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))

(restas:define-route builders-page ("/builders")
  (let ((acts (list 
               (list :perm '"<?>" 
                     :title "Организации-поставщики"
                     :content NIL) ))) 
  (tpl:root
   (list 
    :navpoints (menu) 
    :content acts #| Здесь проверить права |#))))


(defun menu ()  '
((:LINK "/" :TITLE "Главная страница") (:LINK "/admin" :TITLE "Администратор")
 (:LINK "/supplier" :TITLE "Поставщик такой-то")
 (:LINK "/tender" :TITLE "Тендер такой-то")
 (:LINK "/builder" :TITLE "Застройщик такой-то")
 (:LINK "/builders" :TITLE "Поставщики")))