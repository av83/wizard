
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


(defclass EXPERT (entity)
((LOGIN                  :initarg :LOGIN               :initform nil :accessor A-LOGIN)
(PASSWORD               :initarg :PASSWORD            :initform nil :accessor A-PASSWORD)
(NAME                   :initarg :NAME                :initform nil :accessor A-NAME)))


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
(OFFERS                 :initarg :OFFERS              :initform nil :accessor A-OFFERS)
(SALES                  :initarg :SALES               :initform nil :accessor A-SALES)))


(defclass OFFER (entity)
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(TENDER                 :initarg :TENDER              :initform nil :accessor A-TENDER)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)))


(defclass OFFER-RESOURCE (entity)
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(OFFER                  :initarg :OFFER               :initform nil :accessor A-OFFER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)))


(defclass SALE (entity)
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PROCENT                :initarg :PROCENT             :initform nil :accessor A-PROCENT)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)
(NOTES                  :initarg :NOTES               :initform nil :accessor A-NOTES)))


(defclass SUPPLIER-RESOURCE-PRICE (entity)
((OWNER                  :initarg :OWNER               :initform nil :accessor A-OWNER)
(RESOURCE               :initarg :RESOURCE            :initform nil :accessor A-RESOURCE)
(PRICE                  :initarg :PRICE               :initform nil :accessor A-PRICE)))


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


(defclass CATEGORY (entity)
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(PARENT                 :initarg :PARENT              :initform nil :accessor A-PARENT)
(CHILD-CATEGORYES       :initarg :CHILD-CATEGORYES    :initform nil :accessor A-CHILD-CATEGORYES)
(RESOURCES              :initarg :RESOURCES           :initform nil :accessor A-RESOURCES)))


(defclass RESOURCE (entity)
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(CATEGORY               :initarg :CATEGORY            :initform nil :accessor A-CATEGORY)
(RESOURCE-TYPE          :initarg :RESOURCE-TYPE       :initform nil :accessor A-RESOURCE-TYPE)
(UNIT                   :initarg :UNIT                :initform nil :accessor A-UNIT)
(SUPPLIERS              :initarg :SUPPLIERS           :initform nil :accessor A-SUPPLIERS)))


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
(OFFERS                 :initarg :OFFERS              :initform nil :accessor A-OFFERS)))


(defclass DOCUMENT (entity)
((NAME                   :initarg :NAME                :initform nil :accessor A-NAME)
(FILENAME               :initarg :FILENAME            :initform nil :accessor A-FILENAME)
(TENDER                 :initarg :TENDER              :initform nil :accessor A-TENDER)))

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
                          (list :btn "B10246" :perm 111 :value "Показать ресурсы")))))) 
    (show-acts acts)))

(restas:define-route catalog-page/post ("/catalog" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10246" . ,(lambda () (TO "/category/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route category-page ("/category/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Категории"
                     :val (lambda () (CONS-HASH-LIST *CATEGORY*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Имя")
                          (list :btn "B10247" :perm 111 :value "Показать ресурсы")))
               (list :perm ':ALL 
                     :title "Ресурсы категории"
                     :val (lambda () (REMOVE-IF-NOT
 #'(LAMBDA (X) (EQUAL (A-CATEGORY (CDR X)) (GETHASH (CUR-ID) *CATEGORY*)))
 (CONS-HASH-LIST *RESOURCE*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :fld "RESOURCE-TYPE" :perm 111 :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип")
                          (list :fld "UNIT" :perm 111 :typedata '(:STR) :name "Единица измерения")
                          (list :btn "B10248" :perm 111 :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route category-page/post ("/category/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10247" . ,(lambda () (TO "/category/~A" (CAAR (FORM-DATA)))))
("B10248" . ,(lambda () (TO "/resource/~A" (CAAR (FORM-DATA)))))))) 
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
                          (list :btn "B10249" :perm 111 :value "Страница категории")
                          (list :btn "B10250" :perm 111 :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route resources-page/post ("/resource" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10249" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/category/~A"
         (LET ((ETALON
                (A-CATEGORY
                 (GETHASH (GET-BTN-KEY (CAAR (FORM-DATA))) *RESOURCE*))))
           (CAR
            (FIND-IF
             #'(LAMBDA (CATEGORY-CONS) (EQUAL (CDR CATEGORY-CONS) ETALON))
             (CONS-HASH-LIST *CATEGORY*))))))))
("B10250" . ,(lambda () (TO "/resource/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route resource-page ("/resource/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Ресурс"
                     :val (lambda () (GETHASH (CUR-ID) *RESOURCE*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :fld "CATEGORY" :perm 111 :typedata '(:LINK CATEGORY) :name "Категория")
                          (list :fld "RESOURCE-TYPE" :perm 111 :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип")
                          (list :fld "UNIT" :perm 111 :typedata '(:STR) :name "Единица измерения")))))) 
    (show-acts acts)))

(restas:define-route resource-page/post ("/resource/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
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
                          (list :btn "B10251" :perm 111 :value "Изменить пароль")))
               (list :perm ':ADMIN 
                     :title "Создать аккаунт эксперта"
                     :val (lambda () :CLEAR)
                     :fields (list 
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")
                          (list :btn "B10252" :perm 111 :value "Создать новый аккаунт эксперта")))
               (list :perm ':ADMIN 
                     :title "Эксперты"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL 'EXPERT (TYPE-OF (CDR X))))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "ФИО")
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :popbtn "P10253" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Действительно удалить?" 
                                :fields (list 
                          (list :btn "B10254" :perm 111 :value "Подтверждаю удаление")))
                          (list :popbtn "P10255" 
                                :value "Сменить пароль" 
                                :perm 111 
                                :title "Смена пароля эксперта" 
                                :fields (list 
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :btn "B10256" :perm 111 :value "Изменить пароль эксперта")))
                          (list :btn "B10257" :perm 111 :value "Страница эксперта")))
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
                          (list :popbtn "P10258" 
                                :value "Подтвердить заявку" 
                                :perm 111 
                                :title "Подтвердить заявку поставщика" 
                                :fields (list 
                          (list :btn "B10259" :perm 111 :value "Сделать добросовестным")))))))) 
    (show-acts acts)))

(restas:define-route admin-page/post ("/admin" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10251" . ,(lambda () (LET ((OBJ (CUR-USER)))
  (WITH-OBJ-SAVE OBJ LOGIN PASSWORD))))
("B10252" . ,(lambda () (PROGN
 (PUSH-HASH *USER*
     'EXPERT
   :LOGIN
   (CDR (ASSOC "LOGIN" (FORM-DATA) :TEST #'EQUAL))
   :PASSWORD
   (CDR (ASSOC "PASSWORD" (FORM-DATA) :TEST #'EQUAL))
   :NAME
   (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10254" . ,(lambda () (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
  (REMHASH KEY *USER*)
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10256" . ,(lambda () (LET ((OBJ (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *USER*)))
  (WITH-OBJ-SAVE OBJ PASSWORD))))
("B10257" . ,(lambda () (TO "/expert/~A" (CAAR (FORM-DATA)))))
("B10259" . ,(lambda () (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
  (SETF (A-STATUS (GETHASH KEY *USER*)) :FAIR)
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
                          (list :btn "B10260" :perm 111 :value "Страница эксперта")))))) 
    (show-acts acts)))

(restas:define-route experts-page/post ("/expert" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10260" . ,(lambda () (TO "/expert/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route expert-page ("/expert/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Эксперт"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
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
                          (list :btn "B10261" :perm 111 :value "Страница поставщика")))))) 
    (show-acts acts)))

(restas:define-route suppliers-page/post ("/supplier" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10261" . ,(lambda () (TO "/supplier/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route supplier-page ("/supplier/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ADMIN 
                     :title "Изменить себе пароль"
                     :val (lambda () (CUR-USER))
                     :fields (list 
                          (list :fld "LOGIN" :perm 111 :typedata '(:STR) :name "Логин")
                          (list :fld "PASSWORD" :perm 111 :typedata '(:PSWD) :name "Пароль")
                          (list :btn "B10262" :perm 111 :value "Изменить пароль")))
               (list :perm 'NIL 
                     :title "Поставщик"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
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
                          (list :btn "B10263" :perm 111 :value "Сохранить")
                          (list :col "Список поставляемых ресурсов" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS
                                                 *SUPPLIER-RESOURCE-PRICE*
                                                 (A-RESOURCES
                                                  (GETHASH (CUR-ID) *USER*))))
                                :fields (list 
                          (list :fld "RESOURCE" :perm 111 :typedata '(:LINK RESOURCE) :name "Ресурс")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена поставщика")
                          (list :popbtn "P10264" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Удаление ресурса" 
                                :fields (list 
                          (list :btn "B10265" :perm 111 :value "Удалить ресурс")))))
                          (list :popbtn "P10266" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Добавление ресурса" 
                                :fields (list 
                          (list :btn "B10267" :perm 111 :value "Добавить ресурс")))
                          (list :col "Список заявок на тендеры" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *OFFER*
                                                                 (A-OFFERS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *USER*))))
                                :fields (list 
                          (list :fld "TENDER" :perm 111 :typedata '(:LINK TENDER) :name "Тендер")
                          (list :btn "B10268" :perm 111 :value "Страница заявки")
                          (list :popbtn "P10269" 
                                :value "Удалить заявку" 
                                :perm 111 
                                :title "Удаление заявки" 
                                :fields (list 
                          (list :btn "B10270" :perm 111 :value "Удалить заявку")))))
                          (list :col "Список распродаж" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *SALE*
                                                                 (A-SALES
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *USER*))))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Распродажа")
                          (list :btn "B10271" :perm 111 :value "Страница распродажи")
                          (list :popbtn "P10272" 
                                :value "Удалить распродажу" 
                                :perm 111 
                                :title "Удаление распродажи" 
                                :fields (list 
                          (list :btn "B10273" :perm 111 :value "Удалить распродажу")))))
                          (list :popbtn "P10274" 
                                :value "Добавить распродажу" 
                                :perm 111 
                                :title "Добавление расподажи" 
                                :fields (list 
                          (list :btn "B10275" :perm 111 :value "Добавить распродажу")))))
               (list :perm '(AND :SELF :UNFAIR) 
                     :title "Отправить заявку на добросовестность"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
                     :fields (list 
                          (list :btn "B10276" :perm 111 :value "Отправить заявку на добросовестность")))))) 
    (show-acts acts)))

(restas:define-route supplier-page/post ("/supplier/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10262" . ,(lambda () (LET ((OBJ (CUR-USER)))
  (WITH-OBJ-SAVE OBJ LOGIN PASSWORD))))
("B10263" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *USER*)))
  (WITH-OBJ-SAVE OBJ NAME JURIDICAL-ADDRESS ACTUAL-ADDRESS CONTACTS EMAIL SITE
                 HEADS INN KPP OGRN BANK-NAME BIK CORRESP-ACCOUNT
                 CLIENT-ACCOUNT ADDRESSES CONTACT-PERSON)
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10265" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *SUPPLIER-RESOURCE-PRICE*
               (A-RESOURCES (GETHASH (CUR-ID) *USER*)))))
("B10267" . ,(lambda () (PROGN
 (PUSH-HASH *SUPPLIER-RESOURCE-PRICE*
     'SUPPLIER-RESOURCE-PRICE
   :OWNER
   (GETHASH (CUR-USER) *USER*)
   :RESOURCE
   (GETHASH (CDR (ASSOC "res" (FORM-DATA) :TEST #'EQUAL)) *RESOURCE*)
   :PRICE
   (CDR (ASSOC "PRICE" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10268" . ,(lambda () (TO "/offer/~A" (CAAR (FORM-DATA)))))
("B10270" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *OFFER* (A-OFFERS (GETHASH (CUR-ID) *USER*)))))
("B10271" . ,(lambda () (TO "/sale/~A" (CAAR (FORM-DATA)))))
("B10273" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *SALE* (A-SALES (GETHASH (CUR-ID) *USER*)))))
("B10275" . ,(lambda () (CREATE-SALE)))
("B10276" . ,(lambda () (PROGN
 (SETF (A-STATUS (GETHASH (CUR-ID) *USER*)) :REQUEST)
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
       (activate acts)))

(restas:define-route sales-page ("/sale")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Распродажи"
                     :val (lambda () (CONS-HASH-LIST *SALE*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Распродажа")
                          (list :btn "B10277" :perm 111 :value "Страница распродажи")))))) 
    (show-acts acts)))

(restas:define-route sales-page/post ("/sale" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10277" . ,(lambda () (TO "/sale/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route sale-page ("/sale/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Распродажа"
                     :val (lambda () (GETHASH (CUR-ID) *SALE*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Распродажа")
                          (list :fld "OWNER" :perm 111 :typedata '(:LINK SUPPLIER) :name "Поставщик")
                          (list :fld "PROCENT" :perm 111 :typedata '(:NUM) :name "Процент скидки")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена со скидкой")
                          (list :fld "NOTES" :perm 111 :typedata '(:LIST-OF-STR) :name "Дополнительные условия")
                          (list :btn "B10278" :perm 111 :value "Сохранить")
                          (list :btn "B10279" :perm 111 :value "Удалить распродажу")))))) 
    (show-acts acts)))

(restas:define-route sale-page/post ("/sale/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10278" . ,(lambda () (SAVE-SALE)))
("B10279" . ,(lambda () (DELETE-SALE)))))) 
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
                          (list :btn "B10280" :perm 111 :value "Страница застройщика")))))) 
    (show-acts acts)))

(restas:define-route builders-page/post ("/builder" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10280" . ,(lambda () (TO "/builder/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route builder-page ("/builder/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Застройщик"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
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
                          (list :fld "RATING" :perm 111 :typedata '(:NUM) :name "Рейтинг")
                          (list :btn "B10281" :perm 111 :value "Сохранить")
                          (list :col "Тендеры застройщика" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *TENDER*
                                                                 (A-TENDERS
                                                                  (GETHASH 11
                                                                           *USER*))))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :btn "B10282" :perm 111 :value "Страница тендера")))))
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
                          (list :btn "B10283" :perm 111 :value "Объявить тендер (+)")))))) 
    (show-acts acts)))

(restas:define-route builder-page/post ("/builder/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10281" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *USER*)))
  (WITH-OBJ-SAVE OBJ NAME JURIDICAL-ADDRESS INN KPP OGRN BANK-NAME BIK
                 CORRESP-ACCOUNT CLIENT-ACCOUNT RATING))))
("B10282" . ,(lambda () (TO "/tender/~A" (CAAR (LAST (FORM-DATA))))))
("B10283" . ,(lambda () (LET ((ID (HASH-TABLE-COUNT *TENDER*)))
  (SETF (GETHASH ID *TENDER*)
          (MAKE-INSTANCE 'TENDER :NAME
                         (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL)) :STATUS
                         :UNACTIVE :OWNER (GETHASH (CUR-ID) *USER*) :ALL
                         (CDR (ASSOC "ALL" (FORM-DATA) :TEST #'EQUAL)) :CLAIM
                         (CDR (ASSOC "CLAIM" (FORM-DATA) :TEST #'EQUAL))
                         :ANALIZE
                         (CDR (ASSOC "ANALIZE" (FORM-DATA) :TEST #'EQUAL))
                         :INTERVIEW
                         (CDR (ASSOC "INTERVIEW" (FORM-DATA) :TEST #'EQUAL))
                         :RESULT
                         (CDR (ASSOC "RESULT" (FORM-DATA) :TEST #'EQUAL))))
  (HUNCHENTOOT:REDIRECT (FORMAT NIL "/tender/~A" ID)))))))) 
       (activate acts)))

(restas:define-route tenders-page ("/tender")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Тендеры"
                     :val (lambda () (CONS-HASH-LIST *TENDER*))
                     :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :fld "STATUS" :perm 111 :typedata '(:LIST-OF-KEYS TENDER-STATUS) :name "Статус")
                          (list :fld "OWNER" :perm 111 :typedata '(:LINK BUILDER) :name "Заказчик")
                          (list :btn "B10284" :perm 111 :value "Страница тендера")))))) 
    (show-acts acts)))

(restas:define-route tenders-page/post ("/tender" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10284" . ,(lambda () (TO "/tender/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route tender-page ("/tender/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Тендер"
                     :val (lambda () (GETHASH (CUR-ID) *TENDER*))
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
                          (list :btn "B10285" :perm 111 :value "Сохранить")
                          (list :col "Ресурсы тендера" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *RESOURCE*
                                                                 (A-RESOURCES
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :btn "B10286" :perm 111 :value "Удалить из тендера")
                          (list :btn "B10287" :perm 111 :value "Страница ресурса")))
                          (list :popbtn "P10288" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :col "Выберите ресурс" :perm 111 
                                :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :btn "B10289" :perm 111 :value "Добавить ресурс")))))
                          (list :col "Документы тендера" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *DOCUMENT*
                                                                 (A-DOCUMENTS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :btn "B10290" :perm 111 :value "Удалить из тендера")
                          (list :btn "B10291" :perm 111 :value "Страница документа")))
                          (list :btn "B10292" :perm 111 :value "Добавить документ")
                          (list :col "Поставщики ресурсов" :perm 111 
                                :val (lambda () (REMOVE-IF-NOT
                                                 #'(LAMBDA (X)
                                                     (EQUAL (TYPE-OF (CDR X))
                                                            'SUPPLIER))
                                                 (CONS-HASH-LIST *USER*)))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Название")
                          (list :btn "B10293" :perm 111 :value "Отправить приглашение")
                          (list :btn "B10294" :perm 111 :value "Страница поставщика")))
                          (list :btn "B10295" :perm 111 :value "Добавить своего поставщика")
                          (list :col "Заявки на тендер" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *OFFER*
                                                                 (A-OFFERS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :btn "B10296" :perm 111 :value "Страница заявки")))
                          (list :popbtn "P10297" 
                                :value "Ответить заявкой на тендер" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :btn "B10298" :perm 111 :value "Участвовать в тендере")))
                          (list :popbtn "P10299" 
                                :value "Отменить тендер" 
                                :perm 111 
                                :title "Действительно отменить?" 
                                :fields (list 
                          (list :btn "B10300" :perm 111 :value "Подтверждаю отмену")))))))) 
    (show-acts acts)))

(restas:define-route tender-page/post ("/tender/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10285" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *TENDER*)))
  (WITH-OBJ-SAVE OBJ NAME ACTIVE-DATE ALL CLAIM ANALIZE INTERVIEW RESULT))))
("B10286" . ,(lambda () (LET ((ETALON (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *RESOURCE*)))
  (SETF (A-RESOURCES (GETHASH (CUR-ID) *TENDER*))
          (REMOVE-IF #'(LAMBDA (X) (EQUAL X ETALON))
                     (A-RESOURCES (GETHASH (CUR-ID) *TENDER*))))
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10287" . ,(lambda () (TO "/resource/~A" (CAAR (LAST (FORM-DATA))))))
("B10289" . ,(lambda () (PROGN
 (PUSH (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *RESOURCE*)
       (A-RESOURCES (GETHASH (CUR-ID) *TENDER*)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B10290" . ,(lambda () (DELETE-DOC-FROM-TENDER)))
("B10291" . ,(lambda () (TO "/document/~A" (CAAR (LAST (FORM-DATA))))))
("B10292" . ,(lambda () (ADD-DOCUMENT-TO-TENDER)))
("B10293" . ,(lambda () (DELETE-FROM-TENDER)))
("B10294" . ,(lambda () (TO "/supplier/~A" (CAAR (LAST (FORM-DATA))))))
("B10295" . ,(lambda () (ADD-DOCUMENT-TO-TENDER)))
("B10296" . ,(lambda () (TO "/offer/~A" (CAAR (LAST (FORM-DATA))))))
("B10298" . ,(lambda () (LET* ((ID (HASH-TABLE-COUNT *OFFER*))
       (OFFER
        (SETF (GETHASH ID *OFFER*)
                (MAKE-INSTANCE 'OFFER :OWNER (CUR-USER) :TENDER
                               (GETHASH (CUR-ID) *TENDER*)))))
  (PUSH OFFER (A-OFFERS (GETHASH (CUR-ID) *TENDER*)))
  (HUNCHENTOOT:REDIRECT (FORMAT NIL "/offer/~A" ID)))))
("B10300" . ,(lambda () (CANCEL-TENDER)))))) 
       (activate acts)))

(restas:define-route offers-page ("/offers")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :title "Заявки на участие в тендере"
                     :val (lambda () (CONS-HASH-LIST *OFFER*))
                     :fields (list 
                          (list :fld "OWNER" :perm 111 :typedata '(:LINK SUPPLIER) :name "Поставщик ресурсов")
                          (list :fld "TENDER" :perm 111 :typedata '(:LINK TENDER) :name "Тендер")
                          (list :btn "B10301" :perm 111 :value "Страница заявки")))))) 
    (show-acts acts)))

(restas:define-route offers-page/post ("/offers" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10301" . ,(lambda () (TO "/offer/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route offer-page ("/offer/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :title "Заявка на тендер"
                     :val (lambda () (GETHASH (CUR-ID) *OFFER*))
                     :fields (list 
                          (list :fld "TENDER" :perm 111 :typedata '(:LINK TENDER) :name "Тендер")
                          (list :col "Ресурсы оферты" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS
                                                 *OFFER-RESOURCE*
                                                 (A-RESOURCES
                                                  (GETHASH (CUR-ID) *OFFER*))))
                                :fields (list 
                          (list :fld "RESOURCE" :perm 111 :typedata '(:LINK RESOURCE) :name "Ресурс")
                          (list :fld "PRICE" :perm 111 :typedata '(:NUM) :name "Цена поставщика")
                          (list :btn "B10302" :perm 111 :value "Удалить из оферты")
                          (list :btn "B10303" :perm 111 :value "Страница ресурса")))
                          (list :popbtn "P10304" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :col "Выберите ресурс" :perm 111 
                                :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                                :fields (list 
                          (list :fld "NAME" :perm 111 :typedata '(:STR) :name "Наименование")
                          (list :popbtn "P10305" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Укажите цену" 
                                :fields (list 
                          (list :calc (lambda (obj) "<input type=\"text\" name=\"INPRICE\" />") :perm 111)
                          (list :btn "B10306" :perm 111 :value "Задать цену")))))))))))) 
    (show-acts acts)))

(restas:define-route offer-page/post ("/offer/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B10302" . ,(lambda () (DEL-INNER-OBJ (CAAR (LAST (FORM-DATA))) *OFFER-RESOURCE*
               (A-RESOURCES (GETHASH (CUR-ID) *OFFER*)))))
("B10303" . ,(lambda () (TO "/resource/~A" (CAAR (LAST (FORM-DATA))))))
("B10306" . ,(lambda () (LET ((RES-ID (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))))
      (IN (CDR (ASSOC "INPRICE" (FORM-DATA) :TEST #'EQUAL)))
      (ID (HASH-TABLE-COUNT *OFFER-RESOURCE*)))
  (PUSH
   (SETF (GETHASH ID *OFFER-RESOURCE*)
           (MAKE-INSTANCE 'OFFER-RESOURCE :OWNER (CUR-USER) :OFFER
                          (GETHASH (CUR-ID) *OFFER*) :RESOURCE
                          (GETHASH RES-ID *RESOURCE*) :PRICE IN))
   (A-RESOURCES (GETHASH (CUR-ID) *OFFER*)))
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
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
 (:LINK "/supplier" :TITLE "Поставщики") (:LINK "/sale" :TITLE "Распродажи")
 (:LINK "/builder" :TITLE "Застройщики") (:LINK "/tender" :TITLE "Тендеры")
 (:LINK "/offers" :TITLE "Заявки на участие в тендере")
 (:LINK "/rating" :TITLE "Рейтинг компаний")
 (:LINK "/calender" :TITLE "Календарь событий")
 (:LINK "/links" :TITLE "Ссылки") (:LINK "/about" :TITLE "О портале")
 (:LINK "/contacts" :TITLE "Контакты")))