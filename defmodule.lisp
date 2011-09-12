
(require 'RESTAS)
(require 'CLOSURE-TEMPLATE)
(require 'RESTAS-DIRECTORY-PUBLISHER)
(require 'CL-JSON)

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
                     :grid NIL 
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
                     :grid NIL 
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
                     :grid NIL 
                     :title "Категории"
                     :val (lambda () (CONS-HASH-LIST *CATEGORY*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Имя" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B973" :perm ':ALL :value "Показать ресурсы")))))) 
    (show-acts acts)))

(restas:define-route catalog-page/post ("/catalog" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B973" . ,(lambda () (TO "/category/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route category-page ("/category/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid NIL 
                     :title "Категории"
                     :val (lambda () (CONS-HASH-LIST *CATEGORY*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Имя" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B974" :perm ':ALL :value "Показать ресурсы")))
               (list :perm ':ALL 
                     :grid NIL 
                     :title "Ресурсы категории"
                     :val (lambda () (REMOVE-IF-NOT
 #'(LAMBDA (X) (EQUAL (A-CATEGORY (CDR X)) (GETHASH (CUR-ID) *CATEGORY*)))
 (CONS-HASH-LIST *RESOURCE*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "RESOURCE-TYPE" :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "UNIT" :typedata '(:STR) :name "Единица измерения" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B975" :perm ':ALL :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route category-page/post ("/category/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B974" . ,(lambda () (TO "/category/~A" (CAAR (FORM-DATA)))))
("B975" . ,(lambda () (TO "/resource/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route resources-page ("/resource")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg976" 
                     :title "Ресурсы"
                     :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "RESOURCE-TYPE" :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "UNIT" :typedata '(:STR) :name "Единица измерения" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B977" :perm ':ALL :value "Страница категории")
                          (list :btn "B978" :perm ':ALL :value "Страница ресурса")))))) 
    (show-acts acts)))

(restas:define-route resources-page/post ("/resource" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B977" . ,(lambda () (HUNCHENTOOT:REDIRECT
 (FORMAT NIL "/category/~A"
         (LET ((ETALON
                (A-CATEGORY
                 (GETHASH (GET-BTN-KEY (CAAR (FORM-DATA))) *RESOURCE*))))
           (CAR
            (FIND-IF
             #'(LAMBDA (CATEGORY-CONS) (EQUAL (CDR CATEGORY-CONS) ETALON))
             (CONS-HASH-LIST *CATEGORY*))))))))
("B978" . ,(lambda () (TO "/resource/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route resources-page/ajax ("/jg976")
  (example-json 
   (lambda () (CONS-HASH-LIST *RESOURCE*)) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "RESOURCE-TYPE" :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "UNIT" :typedata '(:STR) :name "Единица измерения" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B977" :perm ':ALL :value "Страница категории")
                          (list :btn "B978" :perm ':ALL :value "Страница ресурса"))))

(restas:define-route resource-page ("/resource/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid NIL 
                     :title "Ресурс"
                     :val (lambda () (GETHASH (CUR-ID) *RESOURCE*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "CATEGORY" :typedata '(:LINK CATEGORY) :name "Категория" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "RESOURCE-TYPE" :typedata '(:LIST-OF-KEYS RESOURCE-TYPES) :name "Тип" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "UNIT" :typedata '(:STR) :name "Единица измерения" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))))))) 
    (show-acts acts)))

(restas:define-route resource-page/post ("/resource/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route admin-page ("/admin")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ADMIN 
                     :grid NIL 
                     :title "Изменить себе пароль"
                     :val (lambda () (CUR-USER))
                     :fields (list 
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE :SELF :VIEW :SELF))
                          (list :fld "PASSWORD" :typedata '(:PSWD) :name "Пароль" 
                                :permlist '(:UPDATE :SELF :VIEW :SELF))
                          (list :btn "B979" :perm ':ALL :value "Изменить пароль")))
               (list :perm ':ADMIN 
                     :grid NIL 
                     :title "Создать аккаунт эксперта"
                     :val (lambda () :CLEAR)
                     :fields (list 
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :fld "PASSWORD" :typedata '(:PSWD) :name "Пароль" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :fld "NAME" :typedata '(:STR) :name "ФИО" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :btn "B980" :perm ':ALL :value "Создать новый аккаунт эксперта")))
               (list :perm ':ADMIN 
                     :grid NIL 
                     :title "Эксперты"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL 'EXPERT (TYPE-OF (CDR X))))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "ФИО" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :popbtn "P981" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Действительно удалить?" 
                                :fields (list 
                          (list :btn "B982" :perm 'NIL :value "Подтверждаю удаление")))
                          (list :popbtn "P983" 
                                :value "Сменить пароль" 
                                :perm 111 
                                :title "Смена пароля эксперта" 
                                :fields (list 
                          (list :fld "PASSWORD" :typedata '(:PSWD) :name "Пароль" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :btn "B984" :perm 'NIL :value "Изменить пароль эксперта")))
                          (list :btn "B985" :perm ':ALL :value "Страница эксперта")))
               (list :perm ':ADMIN 
                     :grid NIL 
                     :title "Заявки поставщиков на добросовестность"
                     :val (lambda () (REMOVE-IF-NOT
 #'(LAMBDA (X)
     (AND (EQUAL 'SUPPLIER (TYPE-OF (CDR X)))
          (EQUAL (A-STATUS (CDR X)) :REQUEST)))
 (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название организации" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :popbtn "P986" 
                                :value "Подтвердить заявку" 
                                :perm 111 
                                :title "Подтвердить заявку поставщика" 
                                :fields (list 
                          (list :btn "B987" :perm 'NIL :value "Сделать добросовестным")))))))) 
    (show-acts acts)))

(restas:define-route admin-page/post ("/admin" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B979" . ,(lambda () (LET ((OBJ (CUR-USER)))
  (WITH-OBJ-SAVE OBJ LOGIN PASSWORD))))
("B980" . ,(lambda () (PROGN
 (PUSH-HASH *USER* 'EXPERT :LOGIN
  (CDR (ASSOC "LOGIN" (FORM-DATA) :TEST #'EQUAL)) :PASSWORD
  (CDR (ASSOC "PASSWORD" (FORM-DATA) :TEST #'EQUAL)) :NAME
  (CDR (ASSOC "NAME" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B982" . ,(lambda () (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
  (REMHASH KEY *USER*)
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B984" . ,(lambda () (LET ((OBJ (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *USER*)))
  (WITH-OBJ-SAVE OBJ PASSWORD))))
("B985" . ,(lambda () (TO "/expert/~A" (CAAR (FORM-DATA)))))
("B987" . ,(lambda () (LET ((KEY (GET-BTN-KEY (CAAR (FORM-DATA)))))
  (SETF (A-STATUS (GETHASH KEY *USER*)) :FAIR)
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
       (activate acts)))

(restas:define-route experts-page ("/expert")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg988" 
                     :title "Эксперты"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'EXPERT))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "ФИО" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :btn "B989" :perm ':ALL :value "Страница эксперта")
                          (list :btn "B990" :perm ':ALL :value "Доп кнопка")))))) 
    (show-acts acts)))

(restas:define-route experts-page/post ("/expert" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B989" . ,(lambda () (TO "/expert/~A" (CAAR (FORM-DATA)))))
("B990" . ,(lambda () (TO "/expert/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route experts-page/ajax ("/jg988")
  (example-json 
   (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'EXPERT))
               (CONS-HASH-LIST *USER*))) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "ФИО" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))
                          (list :btn "B989" :perm ':ALL :value "Страница эксперта")
                          (list :btn "B990" :perm ':ALL :value "Доп кнопка"))))

(restas:define-route expert-page ("/expert/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid NIL 
                     :title "Эксперт"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "ФИО" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW (OR :ADMIN :SELF) :DELETE :ADMIN :CREATE
 :ADMIN))))))) 
    (show-acts acts)))

(restas:define-route expert-page/post ("/expert/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `())) 
       (activate acts)))

(restas:define-route suppliers-page ("/supplier")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg991" 
                     :title "Организации-поставщики"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'SUPPLIER))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название организации" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :btn "B992" :perm ':ALL :value "Страница поставщика")))))) 
    (show-acts acts)))

(restas:define-route suppliers-page/post ("/supplier" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B992" . ,(lambda () (TO "/supplier/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route suppliers-page/ajax ("/jg991")
  (example-json 
   (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'SUPPLIER))
               (CONS-HASH-LIST *USER*))) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название организации" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :btn "B992" :perm ':ALL :value "Страница поставщика"))))

(restas:define-route supplier-page ("/supplier/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ADMIN 
                     :grid NIL 
                     :title "Изменить себе пароль"
                     :val (lambda () (CUR-USER))
                     :fields (list 
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "PASSWORD" :typedata '(:PSWD) :name "Пароль" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :btn "B993" :perm ':ALL :value "Изменить пароль")))
               (list :perm 'NIL 
                     :grid NIL 
                     :title "Поставщик"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название организации" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "STATUS" :typedata '(:LIST-OF-KEYS SUPPLIER-STATUS) :name "Статус" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "JURIDICAL-ADDRESS" :typedata '(:STR) :name "Юридический адрес" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "ACTUAL-ADDRESS" :typedata '(:STR) :name "Фактический адрес" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "CONTACTS" :typedata '(:LIST-OF-STR) :name "Контактные телефоны" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "EMAIL" :typedata '(:STR) :name "Email" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "SITE" :typedata '(:STR) :name "Сайт организации" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "HEADS" :typedata '(:LIST-OF-STR) :name "Руководство" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "INN" :typedata '(:STR) :name "Инн" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "KPP" :typedata '(:STR) :name "КПП" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "OGRN" :typedata '(:STR) :name "ОГРН" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "BANK-NAME" :typedata '(:STR) :name "Название банка" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "BIK" :typedata '(:STR) :name "Банковский идентификационный код" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "CORRESP-ACCOUNT" :typedata '(:STR) :name "Корреспондентский счет" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "CLIENT-ACCOUNT" :typedata '(:STR) :name "Расчетный счет" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "ADDRESSES" :typedata '(:LIST-OF-STR) :name "Адреса офисов и магазинов" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :fld "CONTACT-PERSON" :typedata '(:STR) :name "Контактное лицо" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE
 (OR :ADMIN :NOT-LOGGED)))
                          (list :btn "B994" :perm ':ALL :value "Сохранить")
                          (list :col "Список поставляемых ресурсов" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS
                                                 *SUPPLIER-RESOURCE-PRICE*
                                                 (A-RESOURCES
                                                  (GETHASH (CUR-ID) *USER*))))
                                :fields (list 
                          (list :fld "RESOURCE" :typedata '(:LINK RESOURCE) :name "Ресурс" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :OWNER))
                          (list :fld "PRICE" :typedata '(:NUM) :name "Цена поставщика" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :OWNER))
                          (list :popbtn "P995" 
                                :value "Удалить" 
                                :perm 111 
                                :title "Удаление ресурса" 
                                :fields (list 
                          (list :btn "B996" :perm ':ALL :value "Удалить ресурс")))))
                          (list :popbtn "P997" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Добавление ресурса" 
                                :fields (list 
                          (list :btn "B998" :perm ':ALL :value "Добавить ресурс")))
                          (list :col "Список заявок на тендеры" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *OFFER*
                                                                 (A-OFFERS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *USER*))))
                                :fields (list 
                          (list :fld "TENDER" :typedata '(:LINK TENDER) :name "Тендер" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :btn "B999" :perm ':ALL :value "Страница заявки")
                          (list :popbtn "P1000" 
                                :value "Удалить заявку" 
                                :perm 111 
                                :title "Удаление заявки" 
                                :fields (list 
                          (list :btn "B1001" :perm ':ALL :value "Удалить заявку")))))
                          (list :col "Список распродаж" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *SALE*
                                                                 (A-SALES
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *USER*))))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Распродажа" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :btn "B1002" :perm ':ALL :value "Страница распродажи")
                          (list :popbtn "P1003" 
                                :value "Удалить распродажу" 
                                :perm 111 
                                :title "Удаление распродажи" 
                                :fields (list 
                          (list :btn "B1004" :perm ':ALL :value "Удалить распродажу")))))
                          (list :popbtn "P1005" 
                                :value "Добавить распродажу" 
                                :perm 111 
                                :title "Добавление расподажи" 
                                :fields (list 
                          (list :btn "B1006" :perm ':ALL :value "Добавить распродажу")))))
               (list :perm '(AND :SELF :UNFAIR) 
                     :grid NIL 
                     :title "Отправить заявку на добросовестность"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
                     :fields (list 
                          (list :btn "B1007" :perm ':ALL :value "Отправить заявку на добросовестность")))))) 
    (show-acts acts)))

(restas:define-route supplier-page/post ("/supplier/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B993" . ,(lambda () (LET ((OBJ (CUR-USER)))
  (WITH-OBJ-SAVE OBJ LOGIN PASSWORD))))
("B994" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *USER*)))
  (WITH-OBJ-SAVE OBJ NAME JURIDICAL-ADDRESS ACTUAL-ADDRESS CONTACTS EMAIL SITE
                 HEADS INN KPP OGRN BANK-NAME BIK CORRESP-ACCOUNT
                 CLIENT-ACCOUNT ADDRESSES CONTACT-PERSON)
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B996" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *SUPPLIER-RESOURCE-PRICE*
               (A-RESOURCES (GETHASH (CUR-ID) *USER*)))))
("B998" . ,(lambda () (PROGN
 (PUSH-HASH *SUPPLIER-RESOURCE-PRICE* 'SUPPLIER-RESOURCE-PRICE :OWNER
  (GETHASH (CUR-USER) *USER*) :RESOURCE
  (GETHASH (CDR (ASSOC "res" (FORM-DATA) :TEST #'EQUAL)) *RESOURCE*) :PRICE
  (CDR (ASSOC "PRICE" (FORM-DATA) :TEST #'EQUAL)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B999" . ,(lambda () (TO "/offer/~A" (CAAR (FORM-DATA)))))
("B1001" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *OFFER* (A-OFFERS (GETHASH (CUR-ID) *USER*)))))
("B1002" . ,(lambda () (TO "/sale/~A" (CAAR (FORM-DATA)))))
("B1004" . ,(lambda () (DEL-INNER-OBJ (CAAR (FORM-DATA)) *SALE* (A-SALES (GETHASH (CUR-ID) *USER*)))))
("B1006" . ,(lambda () (CREATE-SALE)))
("B1007" . ,(lambda () (PROGN
 (SETF (A-STATUS (GETHASH (CUR-ID) *USER*)) :REQUEST)
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))))) 
       (activate acts)))

(restas:define-route sales-page ("/sale")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg1008" 
                     :title "Распродажи"
                     :val (lambda () (CONS-HASH-LIST *SALE*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Распродажа" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :btn "B1009" :perm ':ALL :value "Страница распродажи")))))) 
    (show-acts acts)))

(restas:define-route sales-page/post ("/sale" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1009" . ,(lambda () (TO "/sale/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route sales-page/ajax ("/jg1008")
  (example-json 
   (lambda () (CONS-HASH-LIST *SALE*)) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Распродажа" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :btn "B1009" :perm ':ALL :value "Страница распродажи"))))

(restas:define-route sale-page ("/sale/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :grid NIL 
                     :title "Распродажа"
                     :val (lambda () (GETHASH (CUR-ID) *SALE*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Распродажа" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :fld "OWNER" :typedata '(:LINK SUPPLIER) :name "Поставщик" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :fld "PROCENT" :typedata '(:NUM) :name "Процент скидки" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :fld "PRICE" :typedata '(:NUM) :name "Цена со скидкой" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :fld "NOTES" :typedata '(:LIST-OF-STR) :name "Дополнительные условия" 
                                :permlist '(:UPDATE :OWNER :VIEW :ALL :DELETE :OWNER :CREATE :SUPPLIER))
                          (list :btn "B1010" :perm ':ALL :value "Сохранить")
                          (list :btn "B1011" :perm ':ALL :value "Удалить распродажу")))))) 
    (show-acts acts)))

(restas:define-route sale-page/post ("/sale/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1010" . ,(lambda () (SAVE-SALE)))
("B1011" . ,(lambda () (DELETE-SALE)))))) 
       (activate acts)))

(restas:define-route builders-page ("/builder")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg1012" 
                     :title "Организации-застройщики"
                     :val (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'BUILDER))
               (CONS-HASH-LIST *USER*)))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Организация-застройщик" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :btn "B1013" :perm ':ALL :value "Страница застройщика")))))) 
    (show-acts acts)))

(restas:define-route builders-page/post ("/builder" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1013" . ,(lambda () (TO "/builder/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route builders-page/ajax ("/jg1012")
  (example-json 
   (lambda () (REMOVE-IF-NOT #'(LAMBDA (X) (EQUAL (TYPE-OF (CDR X)) 'BUILDER))
               (CONS-HASH-LIST *USER*))) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Организация-застройщик" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "LOGIN" :typedata '(:STR) :name "Логин" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :btn "B1013" :perm ':ALL :value "Страница застройщика"))))

(restas:define-route builder-page ("/builder/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :grid NIL 
                     :title "Застройщик"
                     :val (lambda () (GETHASH (CUR-ID) *USER*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Организация-застройщик" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "JURIDICAL-ADDRESS" :typedata '(:STR) :name "Юридический адрес" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "INN" :typedata '(:STR) :name "Инн" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "KPP" :typedata '(:STR) :name "КПП" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "OGRN" :typedata '(:STR) :name "ОГРН" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "BANK-NAME" :typedata '(:STR) :name "Название банка" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "BIK" :typedata '(:STR) :name "Банковский идентификационный код" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "CORRESP-ACCOUNT" :typedata '(:STR) :name "Корреспондентский счет" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "CLIENT-ACCOUNT" :typedata '(:STR) :name "Рассчетный счет" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :fld "RATING" :typedata '(:NUM) :name "Рейтинг" 
                                :permlist '(:UPDATE (OR :ADMIN :SELF) :VIEW :ALL :DELETE :ADMIN :CREATE :ADMIN))
                          (list :btn "B1014" :perm ':ALL :value "Сохранить")
                          (list :col "Тендеры застройщика" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *TENDER*
                                                                 (A-TENDERS
                                                                  (GETHASH 11
                                                                           *USER*))))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1015" :perm ':ALL :value "Страница тендера")))))
               (list :perm ':SELF 
                     :grid NIL 
                     :title "Объявить новый тендер"
                     :val (lambda () :CLEAR)
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "ALL" :typedata '(:INTERVAL) :name "Срок проведения" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "CLAIM" :typedata '(:INTERVAL) :name "Срок подачи заявок" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "ANALIZE" :typedata '(:INTERVAL) :name "Срок рассмотрения заявок" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "INTERVIEW" :typedata '(:INTERVAL) :name "Срок проведения интервью" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "RESULT" :typedata '(:INTERVAL) :name "Срок подведения итогов" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1016" :perm ':ALL :value "Объявить тендер (+)")))))) 
    (show-acts acts)))

(restas:define-route builder-page/post ("/builder/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1014" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *USER*)))
  (WITH-OBJ-SAVE OBJ NAME JURIDICAL-ADDRESS INN KPP OGRN BANK-NAME BIK
                 CORRESP-ACCOUNT CLIENT-ACCOUNT RATING))))
("B1015" . ,(lambda () (TO "/tender/~A" (CAAR (LAST (FORM-DATA))))))
("B1016" . ,(lambda () (LET ((ID (HASH-TABLE-COUNT *TENDER*)))
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
                     :grid "jg1017" 
                     :title "Тендеры"
                     :val (lambda () (CONS-HASH-LIST *TENDER*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "STATUS" :typedata '(:LIST-OF-KEYS TENDER-STATUS) :name "Статус" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "OWNER" :typedata '(:LINK BUILDER) :name "Заказчик" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1018" :perm ':ALL :value "Страница тендера")))))) 
    (show-acts acts)))

(restas:define-route tenders-page/post ("/tender" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1018" . ,(lambda () (TO "/tender/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route tenders-page/ajax ("/jg1017")
  (example-json 
   (lambda () (CONS-HASH-LIST *TENDER*)) 
   (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "STATUS" :typedata '(:LIST-OF-KEYS TENDER-STATUS) :name "Статус" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "OWNER" :typedata '(:LINK BUILDER) :name "Заказчик" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1018" :perm ':ALL :value "Страница тендера"))))

(restas:define-route tender-page ("/tender/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :grid NIL 
                     :title "Тендер"
                     :val (lambda () (GETHASH (CUR-ID) *TENDER*))
                     :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "STATUS" :typedata '(:LIST-OF-KEYS TENDER-STATUS) :name "Статус" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "OWNER" :typedata '(:LINK BUILDER) :name "Заказчик" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "ACTIVE-DATE" :typedata '(:DATE) :name "Дата активации" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "ALL" :typedata '(:INTERVAL) :name "Срок проведения" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "CLAIM" :typedata '(:INTERVAL) :name "Срок подачи заявок" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "ANALIZE" :typedata '(:INTERVAL) :name "Срок рассмотрения заявок" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "INTERVIEW" :typedata '(:INTERVAL) :name "Срок проведения интервью" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :fld "RESULT" :typedata '(:INTERVAL) :name "Срок подведения итогов" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1019" :perm ':ALL :value "Сохранить")
                          (list :col "Ресурсы тендера" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *RESOURCE*
                                                                 (A-RESOURCES
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1020" :perm ':ALL :value "Удалить из тендера")
                          (list :btn "B1021" :perm ':ALL :value "Страница ресурса")))
                          (list :popbtn "P1022" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :col "Выберите ресурс" :perm 111 
                                :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B1023" :perm 'NIL :value "Добавить ресурс")))))
                          (list :col "Документы тендера" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *DOCUMENT*
                                                                 (A-DOCUMENTS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1024" :perm ':ALL :value "Удалить из тендера")
                          (list :btn "B1025" :perm ':ALL :value "Страница документа")))
                          (list :popbtn "P1026" 
                                :value "Добавить документ" 
                                :perm 111 
                                :title "Загрузите документ" 
                                :fields (list 
                          (list :col "Выберите ресурс" :perm 111 
                                :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :btn "B1027" :perm 'NIL :value "Добавить ресурс")))))
                          (list :col "Поставщики ресурсов" :perm 111 
                                :val (lambda () (LET ((TENDER-RESOURCES
                                                       (A-RESOURCES
                                                        (GETHASH (CUR-ID)
                                                                 *TENDER*)))
                                                      (ALL-SUPPLIERS
                                                       (REMOVE-IF-NOT
                                                        #'(LAMBDA (X)
                                                            (EQUAL
                                                             (TYPE-OF (CDR X))
                                                             'SUPPLIER))
                                                        (CONS-HASH-LIST
                                                         *USER*)))
                                                      (SUPPLIER-RESOURCE
                                                       (MAPCAR
                                                        #'(LAMBDA (X)
                                                            (CONS
                                                             (A-RESOURCE
                                                              (CDR X))
                                                             (A-OWNER
                                                              (CDR X))))
                                                        (CONS-HASH-LIST
                                                         *SUPPLIER-RESOURCE-PRICE*)))
                                                      (RESULT)
                                                      (RS))
                                                  (LOOP FOR TR IN TENDER-RESOURCES
                                                        DO (LOOP FOR SR IN SUPPLIER-RESOURCE
                                                                 DO (WHEN
                                                                        (EQUAL
                                                                         TR
                                                                         (CAR
                                                                          SR))
                                                                      (PUSH
                                                                       (CDR SR)
                                                                       RESULT))))
                                                  (SETF RESULT
                                                          (REMOVE-DUPLICATES
                                                           RESULT))
                                                  (LOOP FOR RD IN RESULT
                                                        DO (LOOP FOR AS IN ALL-SUPPLIERS
                                                                 DO (IF (EQUAL
                                                                         RD
                                                                         (CDR
                                                                          AS))
                                                                        (PUSH
                                                                         AS
                                                                         RS))))
                                                  RS))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Название" 
                                :permlist '(:UPDATE (OR :ADMIN :OWNER) :VIEW (AND :LOGGED (OR :STALE (AND :FRESH :FAIR)))
 :DELETE :ADMIN :CREATE :BUILDER))
                          (list :btn "B1028" :perm ':ALL :value "Отправить приглашение")
                          (list :btn "B1029" :perm ':ALL :value "Страница поставщика")))
                          (list :btn "B1030" :perm ':ALL :value "Добавить своего поставщика")
                          (list :col "Заявки на тендер" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS *OFFER*
                                                                 (A-OFFERS
                                                                  (GETHASH
                                                                   (CUR-ID)
                                                                   *TENDER*))))
                                :fields (list 
                          (list :btn "B1031" :perm ':ALL :value "Страница заявки")))
                          (list :popbtn "P1032" 
                                :value "Ответить заявкой на тендер" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :btn "B1033" :perm 'NIL :value "Участвовать в тендере")
                          (list :fld "PERM" :typedata 'NIL :name "NIL" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :fld "ALL" :typedata 'NIL :name "NIL" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))))
                          (list :popbtn "P1034" 
                                :value "Отменить тендер" 
                                :perm 111 
                                :title "Действительно отменить?" 
                                :fields (list 
                          (list :btn "B1035" :perm ':ALL :value "Подтверждаю отмену")))))))) 
    (show-acts acts)))

(restas:define-route tender-page/post ("/tender/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1019" . ,(lambda () (LET ((OBJ (GETHASH (CUR-ID) *TENDER*)))
  (WITH-OBJ-SAVE OBJ NAME ACTIVE-DATE ALL CLAIM ANALIZE INTERVIEW RESULT))))
("B1020" . ,(lambda () (LET ((ETALON (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *RESOURCE*)))
  (SETF (A-RESOURCES (GETHASH (CUR-ID) *TENDER*))
          (REMOVE-IF #'(LAMBDA (X) (EQUAL X ETALON))
                     (A-RESOURCES (GETHASH (CUR-ID) *TENDER*))))
  (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B1021" . ,(lambda () (TO "/resource/~A" (CAAR (LAST (FORM-DATA))))))
("B1023" . ,(lambda () (PROGN
 (PUSH (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *RESOURCE*)
       (A-RESOURCES (GETHASH (CUR-ID) *TENDER*)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B1024" . ,(lambda () (DELETE-DOC-FROM-TENDER)))
("B1025" . ,(lambda () (TO "/document/~A" (CAAR (LAST (FORM-DATA))))))
("B1027" . ,(lambda () (PROGN
 (PUSH (GETHASH (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))) *RESOURCE*)
       (A-RESOURCES (GETHASH (CUR-ID) *TENDER*)))
 (HUNCHENTOOT:REDIRECT (HUNCHENTOOT:REQUEST-URI*)))))
("B1028" . ,(lambda () (DELETE-FROM-TENDER)))
("B1029" . ,(lambda () (TO "/supplier/~A" (CAAR (LAST (FORM-DATA))))))
("B1030" . ,(lambda () (ADD-DOCUMENT-TO-TENDER)))
("B1031" . ,(lambda () (TO "/offer/~A" (CAAR (LAST (FORM-DATA))))))
("B1033" . ,(lambda () (LET* ((ID (HASH-TABLE-COUNT *OFFER*))
       (OFFER
        (SETF (GETHASH ID *OFFER*)
                (MAKE-INSTANCE 'OFFER :OWNER (CUR-USER) :TENDER
                               (GETHASH (CUR-ID) *TENDER*)))))
  (PUSH OFFER (A-OFFERS (GETHASH (CUR-ID) *TENDER*)))
  (HUNCHENTOOT:REDIRECT (FORMAT NIL "/offer/~A" ID)))))
("B1035" . ,(lambda () (HUNCHENTOOT:REDIRECT (FORMAT NIL "/tender"))))))) 
       (activate acts)))

(restas:define-route offers-page ("/offers")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm ':ALL 
                     :grid "jg1036" 
                     :title "Заявки на участие в тендере"
                     :val (lambda () (CONS-HASH-LIST *OFFER*))
                     :fields (list 
                          (list :fld "OWNER" :typedata '(:LINK SUPPLIER) :name "Поставщик ресурсов" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :fld "TENDER" :typedata '(:LINK TENDER) :name "Тендер" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :btn "B1037" :perm ':ALL :value "Страница заявки")))))) 
    (show-acts acts)))

(restas:define-route offers-page/post ("/offers" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1037" . ,(lambda () (TO "/offer/~A" (CAAR (FORM-DATA)))))))) 
       (activate acts)))

(restas:define-route offers-page/ajax ("/jg1036")
  (example-json 
   (lambda () (CONS-HASH-LIST *OFFER*)) 
   (list 
                          (list :fld "OWNER" :typedata '(:LINK SUPPLIER) :name "Поставщик ресурсов" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :fld "TENDER" :typedata '(:LINK TENDER) :name "Тендер" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :btn "B1037" :perm ':ALL :value "Страница заявки"))))

(restas:define-route offer-page ("/offer/:id")
  (let ((session (hunchentoot:start-session))
        (acts (list 
               (list :perm 'NIL 
                     :grid NIL 
                     :title "Заявка на тендер"
                     :val (lambda () (GETHASH (CUR-ID) *OFFER*))
                     :fields (list 
                          (list :fld "TENDER" :typedata '(:LINK TENDER) :name "Тендер" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE (AND :OWNER :ACTIVE) :CREATE
 (AND :ACTIVE :SUPPLIER)))
                          (list :col "Ресурсы оферты" :perm 111 
                                :val (lambda () (CONS-INNER-OBJS
                                                 *OFFER-RESOURCE*
                                                 (A-RESOURCES
                                                  (GETHASH (CUR-ID) *OFFER*))))
                                :fields (list 
                          (list :fld "RESOURCE" :typedata '(:LINK RESOURCE) :name "Ресурс" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE :OWNER :CREATE :OWNER))
                          (list :fld "PRICE" :typedata '(:NUM) :name "Цена поставщика" 
                                :permlist '(:UPDATE (AND :ACTIVE :OWNER) :VIEW :ALL :DELETE :OWNER :CREATE :OWNER))
                          (list :btn "B1038" :perm ':ALL :value "Удалить из оферты")
                          (list :btn "B1039" :perm ':ALL :value "Страница ресурса")))
                          (list :popbtn "P1040" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Выберите ресурсы" 
                                :fields (list 
                          (list :col "Выберите ресурс" :perm 111 
                                :val (lambda () (CONS-HASH-LIST *RESOURCE*))
                                :fields (list 
                          (list :fld "NAME" :typedata '(:STR) :name "Наименование" 
                                :permlist '(:UPDATE :SYSTEM :VIEW :ALL :DELETE :SYSTEM :CREATE :SYSTEM))
                          (list :popbtn "P1041" 
                                :value "Добавить ресурс" 
                                :perm 111 
                                :title "Укажите цену" 
                                :fields (list 
                          (list :calc (lambda (obj) "<input type=\"text\" name=\"INPRICE\" />") :perm 111)
                          (list :btn "B1042" :perm ':ALL :value "Задать цену")))))))))))) 
    (show-acts acts)))

(restas:define-route offer-page/post ("/offer/:id" :method :post)
  (let ((session (hunchentoot:start-session))
        (acts `(
("B1038" . ,(lambda () (DEL-INNER-OBJ (CAAR (LAST (FORM-DATA))) *OFFER-RESOURCE*
               (A-RESOURCES (GETHASH (CUR-ID) *OFFER*)))))
("B1039" . ,(lambda () (TO "/resource/~A" (CAAR (LAST (FORM-DATA))))))
("B1042" . ,(lambda () (LET ((RES-ID (GET-BTN-KEY (CAAR (LAST (FORM-DATA)))))
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
                     :grid NIL 
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
                     :grid NIL 
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
                     :grid NIL 
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
                     :grid NIL 
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
                     :grid NIL 
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