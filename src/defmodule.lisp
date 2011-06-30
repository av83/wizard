
(require 'RESTAS)
(require 'CLOSURE-TEMPLATE)
(require 'RESTAS-DIRECTORY-PUBLISHER)

(restas:define-module #:WIZARD
  (:use #:CL #:ITER ))

(in-package #:WIZARD)

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
  (format t "~%Корреспондентский счет : ~A" (CORRESP-ACCOUNT object))
  (format t "~%Расчетный счет : ~A" (CLIENT-ACCOUNT object))
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
  (format t "~%Корреспондентский счет : ~A" (CORRESP-ACCOUNT object))
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
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Главная страница"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route main-page/post ("/" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route news-page ("/news")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Новости"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route news-page/post ("/news" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route catalog-page ("/catalog")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Категории"
                     :val (lambda () (CONS-HASH-LIST *CATEGORY*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Имя")
                          (list :btn "B13534" :perm 111 :value "Показать ресурсы")))))) 
    (show-acts acts)))

(restas:define-route catalog-page/post ("/catalog" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13534" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/category/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route category-page ("/category/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Категории"
                     :val (lambda () (CONS-HASH-LIST *CATEGORY*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Имя")
                          (list :btn "B13535" :perm 111 :value "Показать ресурсы")))
               (list :perm ':ALL 
                     :title "Ресурсы категории"
                     :val (lambda () (REMOVE-IF-NOT
 #'(LAMBDA (X)
     (EQUAL (A-CATEGORY (CDR X))
            (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *CATEGORY*)))
 (CONS-HASH-LIST *RESOURCE*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :fld "RESOURCE-TYPE" :perm 111 :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип")
                          (list :fld "UNIT" :perm 111 :typedata '(:STR) :name "Единица измерения")
                          (list :btn "B13536" :perm 111 :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route category-page/post ("/category/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13535" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/category/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))
("B13536" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/resource/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route resources-page ("/resource")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Ресурсы"
                     :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :fld "RESOURCE-TYPE" :perm 111 :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип")
                          (list :fld "UNIT" :perm 111 :typedata '(:STR) :name "Единица измерения")
                          (list :btn "B13537" :perm 111 :value "Страница категории")
                          (list :btn "B13538" :perm 111 :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route resources-page/post ("/resource" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13537" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/category/~A"
         (LET ((ETALON
                (A-CATEGORY
                 (GETHASH (GET-BTN-KEY (CAAR (FORM-DATA))) *RESOURCE*))))
           (CAR
            (FIND-IF
             #'(LAMBDA (CATEGORY-CONS) (EQUAL (CDR CATEGORY-CONS) ETALON))
             (CONS-HASH-LIST *CATEGORY*))))))))
("B13538" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/resource/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route resource-page ("/resource/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Ресурсы"
                     :val (lambda () (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *RESOURCE*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :fld "CATEGORY" :perm 111 :typedata '(:LINK CATEGORY) :name "Категория")
                          (list :fld "RESOURCE-TYPE" :perm 111 :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип")
                          (list :fld "UNIT" :perm 111 :typedata '(:STR) :name "Единица измерения")
                          (list :btn "B13539" :perm 111 :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route resource-page/post ("/resource/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13539" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/resource/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route admin-page ("/admin")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ADMIN 
                     :title "Изменить себе пароль"
                     :val (lambda () (CUR-USER))
                     :fields (list 
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :btn "B13540" :perm 111 :value "Изменить пароль")))
               (list :perm ':ADMIN 
                     :title "Создать аккаунт эксперта"
                     :val (lambda () :CLEAR)
                     :fields (list 
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")
                          (list :btn "B13541" :perm 111 :value "Создать новый аккаунт эксперта")))
               (list :perm ':ADMIN 
                     :title "Эксперты"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL 'EXPERT (TYPE-OF (CDR X))))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :popbtn "P13542" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Действительно удалить?" 
                                :fields (list 
                          (list :btn "B13543" :perm 111 :value "Подтверждаю удаление")))
                          (list :popbtn "P13544" 
                                :value "Сменить пароль" 
                                :perm 111 
                                :title "Смена пароля эксперта" 
                                :fields (list 
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :btn "B13545" :perm 111 :value "Изменить пароль эксперта")))
                          (list :btn "B13546" :perm 111 :value "Страница эксперта")))
               (list :perm ':ADMIN 
                     :title "Заявки поставщиков на добросовестность"
                     :val (lambda () (REMOVE-IF-NOT
 #'(LAMBDA (X)
     (AND (EQUAL 'SUPPLIER (TYPE-OF (CDR X)))
          (EQUAL (A-STATUS (CDR X)) :REQUEST)))
 (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название организации")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :popbtn "P13547" 
                                :value "Подтвердить заявку" 
                                :perm 111 
                                :title "Подтвердить заявку поставщика" 
                                :fields (list 
                          (list :btn "B13548" :perm 111 :value "Сделать добросовестным")))))))) 
    (show-acts acts)))

(restas:define-route admin-page/post ("/admin" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13540" . ,(lambda () (PROGN
 (SETF (A-LOGIN (CUR-USER)) (CDR (ASSOC "LOGIN" (FORM-DATA) :TEST #'EQUAL)))
 (SETF (A-PASSWORD (CUR-USER))
         (CDR (ASSOC "PASSWORD" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13541" . ,(lambda () (PROGN
 (MAKE-INSTANCE 'EXPERT :LOGIN (CDR (ASSOC "LOGIN" (FORM-DATA) :TEST #'EQUAL))
                :PASSWORD (CDR (ASSOC "PASSWORD" (FORM-DATA) :TEST #'EQUAL))
                :NAME (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13543" . ,(lambda () (PROGN
 (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
   (REMHASH KEY *USER*))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13545" . ,(lambda () (PROGN
 (LET ((KEY (GET-BTN-KEY (CAAR (LAST (FORM-DATA))))))
   (SETF (A-PASSWORD (GETHASH KEY *USER*))
           (CDR (ASSOC "PASSWORD" (FORM-DATA) :TEST #'EQUAL))))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13546" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/expert/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))
("B13548" . ,(lambda () (PROGN
 (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
   (SETF (A-STATUS (GETHASH KEY *USER*)) :FAIR))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
       (activate acts)))

(restas:define-route experts-page ("/expert")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Эксперты"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'EXPERT))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :btn "B13549" :perm 111 :value "Страница эксперта")))))) 
    (show-acts acts)))

(restas:define-route experts-page/post ("/expert" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13549" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/expert/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route expert-page ("/expert/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Эксперт"
                     :val (lambda () (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *USER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")))))) 
    (show-acts acts)))

(restas:define-route expert-page/post ("/expert/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route suppliers-page ("/supplier")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Организации-поставщики"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'SUPPLIER))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название организации")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :btn "B13550" :perm 111 :value "Страница поставщика")))))) 
    (show-acts acts)))

(restas:define-route suppliers-page/post ("/supplier" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13550" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/supplier/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route supplier-page ("/supplier/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Поставщик"
                     :val (lambda () (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *USER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название организации")
                          (list :fld "STATUS" :perm 111 :typedata '(:LIST-OF-KEYS SUPPLIER-STATUS) :name "Статус")
                          (list :fld "JURIDICAL-ADDRESS" :perm 111 :typedata '(:STR) :name "Юридический адрес")
                          (list :fld "ACTUAL-ADDRESS" :perm 111 :typedata '(:STR) :name "Фактический адрес")
                          (list :fld "CONTACTS" :perm 111 :typedata '(:LIST-OF-STR) :name "Контактные телефоны")
                          (list :fld "EMAIL" :perm 111 :typedata '(:STR) :name "Email")
                          (list :fld "SITE" :perm 111 :typedata '(:STR) :name "Сайт организации")
                          (list :fld "HEADS" :perm 111 :typedata '(:LIST-OF-STR) :name "Руководство")
                          (list :fld "INN" :perm 111 :typedata '(:STR) :name "Инн")
                          (list :fld "KPP" :perm 111 :typedata '(:STR) :name "КПП")
                          (list :fld "OGRN" :perm 111 :typedata '(:STR) :name "ОГРН")
                          (list :fld "BANK-NAME" :perm 111 :typedata '(:STR) :name "Название банка")
                          (list :fld "BIK" :perm 111 :typedata '(:STR) :name "Банковский идентификационный код")
                          (list :fld "CORRESP-ACCOUNT" :perm 111 :typedata '(:STR) :name "Корреспондентский счет")
                          (list :fld "CLIENT-ACCOUNT" :perm 111 :typedata '(:STR) :name "Расчетный счет")
                          (list :fld "ADDRESSES" :perm 111 :typedata '(:LIST-OF-STR) :name "Адреса офисов и магазинов")
                          (list :fld "CONTACT-PERSON" :perm 111 :typedata '(:STR) :name "Контактное лицо")
                          (list :fld "RESOURCES" :perm 111 :typedata '(:LIST-OF-LINKS SUPPLIER-RESOURCE-PRICE) :name "Поставляемые ресурсы"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :fld "SALE" :perm 111 :typedata '(:LIST-OF-LINKS SALE) :name "Скидки и акции"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :fld "OFFERS" :perm 111 :typedata '(:LIST-OF-LINKS OFFER) :name "Посланные заявки на тендеры"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :btn "B13551" :perm 111 :value "Сохранить")
                          (list :col "Список поставляемых ресурсов" :perm 111 
                                :val (lambda () (REMOVE-IF-NOT
                                                 #'(LAMBDA (X)
                                                     (EQUAL (A-OWNER (CDR X))
                                                            (GETHASH 3
                                                                     *USER*)))
                                                 (CONS-HASH-LIST
                                                  *SUPPLIER-RESOURCE-PRICE*)))
                                :fields (list 
                          (list :fld "RESOURCE" :perm 111 :typedata '(:LINK RESOURCE) :name "Ресурс")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена поставщика")
                          (list :popbtn "P13552" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Удаление ресурса" 
                                :fields (list 
                          (list :btn "B13553" :perm 111 :value "Удалить ресурс")))))
                          (list :popbtn "P13554" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Добавление ресурса" 
                                :fields (list 
                          (list :fld "RESOURCE" :perm 111 :typedata '(:LINK RESOURCE) :name "Ресурс")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена поставщика")
                          (list :btn "B13555" :perm 111 :value "Добавить ресурс")))))
               (list :perm '(AND :SELF :UNFAIR) 
                     :title "Отправить заявку на добросовестность"
                     :val (lambda () (GETHASH 3 *USER*))
                     :fields (list 
                          (list :btn "B13556" :perm 111 :value "Отправить заявку на добросовестность")))
               (list :perm ':SELF 
                     :title "Список ресурсов, которые я поставляю"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (A-OWNER (CDR X)) (GETHASH 3 *USER*)))
               (CONS-HASH-LIST *SUPPLIER-RESOURCE-PRICE*)))
                     :fields (list 
                          (list :fld "RESOURCE" :perm 111 :typedata '(:LINK RESOURCE) :name "Ресурс")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена поставщика")
                          (list :popbtn "P13557" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Удаление ресурса" 
                                :fields (list 
                          (list :btn "B13558" :perm 111 :value "Удалить ресурс")))))
               (list :perm ':SELF 
                     :title "Мои заявки на тендеры"
                     :val (lambda () :COLLECTION)
                     :fields (list 
                          (list :fld "TENDER" :perm 111 :typedata '(:LINK TENDER) :name "Тендер")))))) 
    (show-acts acts)))

(restas:define-route supplier-page/post ("/supplier/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13551" . ,(lambda () (PROGN
 (LET ((OBJ (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *USER*)))
   (SETF (A-NAME OBJ) (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-JURIDICAL-ADDRESS OBJ)
           (CDR (ASSOC "JURIDICAL-ADDRESS" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-ACTUAL-ADDRESS OBJ)
           (CDR (ASSOC "ACTUAL-ADDRESS" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-CONTACTS OBJ) (CDR (ASSOC "CONTACTS" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-EMAIL OBJ) (CDR (ASSOC "EMAIL" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-SITE OBJ) (CDR (ASSOC "SITE" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-HEADS OBJ) (CDR (ASSOC "HEADS" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-INN OBJ) (CDR (ASSOC "INN" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-KPP OBJ) (CDR (ASSOC "KPP" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-OGRN OBJ) (CDR (ASSOC "OGRN" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-BANK-NAME OBJ) (CDR (ASSOC "BANK-NAME" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-BIK OBJ) (CDR (ASSOC "BIK" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-CORRESP-ACCOUNT OBJ)
           (CDR (ASSOC "CORRESP-ACCOUNT" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-CLIENT-ACCOUNT OBJ)
           (CDR (ASSOC "CLIENT-ACCOUNT" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-ADDRESSES OBJ) (CDR (ASSOC "ADDRESSES" (FORM-DATA) :TEST #'EQUAL)))
   (SETF (A-CONTACT-PERSON OBJ)
           (CDR (ASSOC "CONTACT-PERSON" (FORM-DATA) :TEST #'EQUAL)))
   (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*))))))
("B13553" . ,(lambda () (PROGN
 (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
   (REMHASH KEY *SUPPLIER-RESOURCE-PRICE*))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13555" . ,(lambda () (PROGN
 (SETF (GETHASH (HASH-TABLE-COUNT *SUPPLIER-RESOURCE-PRICE*)
                *SUPPLIER-RESOURCE-PRICE*)
         (MAKE-INSTANCE 'SUPPLIER-RESOURCE-PRICE :OWNER (GETHASH 3 *USER*)
                        :RESOURCE
                        (GETHASH (CDR (ASSOC "res" (FORM-DATA) :TEST #'EQUAL))
                                 *RESOURCE*)
                        :PRICE
                        (CDR (ASSOC "PRICE" (FORM-DATA) :TEST #'EQUAL))))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13556" . ,(lambda () (PROGN
 (SETF (A-STATUS (GETHASH 3 *USER*)) :REQUEST)
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B13558" . ,(lambda () (PROGN
 (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
   (REMHASH KEY *SUPPLIER-RESOURCE-PRICE*))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
       (activate acts)))

(restas:define-route builders-page ("/builder")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Организации-застройщики"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'BUILDER))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Организация-застройщик")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :btn "B13559" :perm 111 :value "Страница застройщика")))))) 
    (show-acts acts)))

(restas:define-route builders-page/post ("/builder" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13559" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/builder/~A" (GET-BTN-KEY (CAAR (FORM-DATA)))))))))) 
       (activate acts)))

(restas:define-route builder-page ("/builder/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Застройщик"
                     :val (lambda () (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *USER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Организация-застройщик")
                          (list :fld "JURIDICAL-ADDRESS" :perm 111 :typedata '(:STR) :name "Юридический адрес")
                          (list :fld "INN" :perm 111 :typedata '(:STR) :name "Инн")
                          (list :fld "KPP" :perm 111 :typedata '(:STR) :name "КПП")
                          (list :fld "OGRN" :perm 111 :typedata '(:STR) :name "ОГРН")
                          (list :fld "BANK-NAME" :perm 111 :typedata '(:STR) :name "Название банка")
                          (list :fld "BIK" :perm 111 :typedata '(:STR) :name "Банковский идентификационный код")
                          (list :fld "CORRESP-ACCOUNT" :perm 111 :typedata '(:STR) :name "Корреспондентский счет")
                          (list :fld "CLIENT-ACCOUNT" :perm 111 :typedata '(:STR) :name "Рассчетный счет")
                          (list :col "Тендеры застройщика" :perm 111 
                                :val (lambda () (REMOVE-IF-NOT
                                                 #'(LAMBDA (X)
                                                     (EQUAL (A-OWNER (CDR X))
                                                            (GETHASH
                                                             (PARSE-INTEGER
                                                              (NTH 2
                                                                   (REQUEST-LIST)))
                                                             *USER*)))
                                                 (CONS-HASH-LIST *TENDER*)))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :btn "B13560" :perm 111 :value "Страница тендера")))
                          (list :fld "RATING" :perm 111 :typedata '(:NUM) :name "Рейтинг")))
               (list :perm ':SELF 
                     :title "Объявить новый тендер"
                     :val (lambda () :CLEAR)
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :fld "ALL" :perm 111 :typedata '(:INTERVAL) :name "Срок проведения")
                          (list :fld "CLAIM" :perm 111 :typedata '(:INTERVAL) :name "Срок подачи заявок")
                          (list :fld "ANALIZE" :perm 111 :typedata '(:INTERVAL) :name "Срок рассмотрения заявок")
                          (list :fld "INTERVIEW" :perm 111 :typedata '(:INTERVAL) :name "Срок проведения интервью")
                          (list :fld "RESULT" :perm 111 :typedata '(:INTERVAL) :name "Срок подведения итогов")
                          (list :btn "B13561" :perm 111 :value "Объявить тендер (+)")))))) 
    (show-acts acts)))

(restas:define-route builder-page/post ("/builder/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13560" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/tender/~A" (GET-BTN-KEY (CAAR (LAST (FORM-DATA) 2)))))))
("B13561" . ,(lambda () (LET ((ID (HASH-TABLE-COUNT *TENDER*)))
  (SETF (GETHASH ID *TENDER*)
          (MAKE-INSTANCE 'TENDER :NAME
                         (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL))))
  (HUNCHENTOOT:REDIRECT (FORMAT NIL "/tender/~A" ID)))))))) 
       (activate acts)))

(restas:define-route tenders-page ("/tender")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Тендеры"
                     :val (lambda () (CONS-HASH-LIST *TENDER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Организация-застройщик")
                          (list :fld "STATUS" :perm 111 :typedata 'NIL :name "NIL")
                          (list :fld "OWNER" :perm 111 :typedata 'NIL :name "NIL")
                          (list :btn "B13562" :perm 111 :value "Страница тендера")))))) 
    (show-acts acts)))

(restas:define-route tenders-page/post ("/tender" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13562" . ,(lambda () "Страница тендера"))))) 
       (activate acts)))

(restas:define-route tender-page ("/tender/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Тендер"
                     :val (lambda () (GETHASH (PARSE-INTEGER (CADDR (REQUEST-LIST))) *TENDER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :fld "STATUS" :perm 111 :typedata '(:LIST-OF-KEYS TENDER-STATUS) :name "Статус")
                          (list :fld "OWNER" :perm 111 :typedata '(:LINK BUILDER) :name "Заказчик")
                          (list :fld "ACTIVE-DATE" :perm 111 :typedata '(:DATE) :name "Дата активации")
                          (list :fld "ALL" :perm 111 :typedata '(:INTERVAL) :name "Срок проведения")
                          (list :fld "CLAIM" :perm 111 :typedata '(:INTERVAL) :name "Срок подачи заявок")
                          (list :fld "ANALIZE" :perm 111 :typedata '(:INTERVAL) :name "Срок рассмотрения заявок")
                          (list :fld "INTERVIEW" :perm 111 :typedata '(:INTERVAL) :name "Срок проведения интервью")
                          (list :fld "RESULT" :perm 111 :typedata '(:INTERVAL) :name "Срок подведения итогов")
                          (list :fld "WINNER" :perm 111 :typedata '(:LINK SUPPLIER) :name "Победитель тендера")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Рекомендуемая стоимость")
                          (list :fld "RESOURCES" :perm 111 :typedata '(:LIST-OF-LINKS RESOURCE) :name "Ресурсы"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :fld "DOCUMENTS" :perm 111 :typedata '(:LIST-OF-LINKS DOCUMENT) :name "Документы"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :fld "SUPPLIERS" :perm 111 :typedata '(:LIST-OF-LINKS SUPPLIER) :name "Поставщики"
                                :access (lambda () NIL)
                                :iface NIL)
                          (list :fld "OFERTS" :perm 111 :typedata 'NIL :name "NIL")
                          (list :popbtn "P13563" 
                                :value "Ответить заявкой на тендер" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :btn "B13564" :perm 111 :value "Участвовать в тендере")))
                          (list :popbtn "P13565" 
                                :value "Отменить тендер" 
                                :perm 111 
                                :title "Действительно отменить?" 
                                :fields (list 
                          (list :btn "B13566" :perm 111 :value "Подтверждаю отмену")))))))) 
    (show-acts acts)))

(restas:define-route tender-page/post ("/tender/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B13564" . ,(lambda () (CREATE-OFFER)))
("B13566" . ,(lambda () (CANCEL-TENDER)))))) 
       (activate acts)))

(restas:define-route rating-page ("/rating")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Рейтинг компаний"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route rating-page/post ("/rating" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route oferts-page ("/oferts")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Оферты"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route oferts-page/post ("/oferts" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route oferts-page ("/oferts")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Оферты"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route oferts-page/post ("/oferts" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route calendar-page ("/calender")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Календарь событий"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route calendar-page/post ("/calender" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route links-page ("/links")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Ссылки"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route links-page/post ("/links" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route about-page ("/about")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "О портале"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route about-page/post ("/about" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route contacts-page ("/contacts")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Контакты"
                     :val (lambda () NIL)
                     :fields (list ))))) 
    (show-acts acts)))

(restas:define-route contacts-page/post ("/contacts" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))


(defun menu ()  '
((:LINK "/" :TITLE "Главная страница") (:LINK "/news" :TITLE "Новости")
 (:LINK "/catalog" :TITLE "Каталог ресурсов")
 (:LINK "/resource" :TITLE "Список ресурсов")
 (:LINK "/admin" :TITLE "Администратор") (:LINK "/expert" :TITLE "Эксперты")
 (:LINK "/supplier" :TITLE "Поставщики")
 (:LINK "/builder" :TITLE "Застройщики") (:LINK "/tender" :TITLE "Тендеры")
 (:LINK "/rating" :TITLE "Рейтинг компаний") (:LINK "/oferts" :TITLE "Оферты")
 (:LINK "/oferts" :TITLE "Оферты")
 (:LINK "/calender" :TITLE "Календарь событий")
 (:LINK "/links" :TITLE "Ссылки") (:LINK "/about" :TITLE "О портале")
 (:LINK "/contacts" :TITLE "Контакты")))