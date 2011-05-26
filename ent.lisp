(defpackage #:ent
  (:use #:cl #:fld)
  (:export :tmp
           ))

(in-package #:ent)

#|

Обозначим, как "сущность" (entity) все объекты данных (такие как ресурс, поставщик, тендер, etc)
включающие в себя поля (fields). Тогда поля будут представлять собой структуры, содержащие
данные (метаданные, такие как название и тип поля) и их конкретные значения. Типы полей могут
быть простыми (строка или число) и сложными (список строк или даже список других сущностей).

|#

;; Базовый класс, от которого наследуются все сущности
(defclass entity ()
  ())

;; Допустимые типы полей, составляющих сущности (TODO: при создании экземпляра entity написать
;; проверку, чтобы тип входил в этот список)
(defparameter *types*
  '(:bool                 ;; T или NIL (checkbox)
    :num                  ;; число
    :str                  ;; строка
    :pswd                 ;; пароль
    :list-of-str          ;; список строк (модификатор: возможность ввода строк пользователем)
    :link                 ;; связанная сущность (модификатор: тип сущности)
    :list-of-links        ;; список связанных сущностей
    :list-of-keys         ;; выпадающий список ключей, с выбором одного из них
    :text-box             ;; текстовое поле
    :tender-period        ;; диапазоны дат, относящиеся к тендеру
    ))


;; list-of-keys - выпадаюшие списки ключей

;; Возможные типы ресурсов: машины, материалы etc
(defparameter *resource-type*
  '(:machine "машина" :material "материал"))

;; Возможные статусы тендеров
(defparameter *tender-status*
  '(:active "активный" :unactive "неактивный" :finished "завершенный" :cancelled "отмененный"))

;; Возможные статусы поставщиков
(defparameter *supplier-status*
  '(:fair "добросовестный" :unfair "недобросовестный" :request "подана заявка"))


;; Константы для контроля разрешений
(defconstant +nobody+           #*000000000000000)
(defconstant +system+           #*000000000000010)
(defconstant +not-logged+       #*000000000000100)
(defconstant +logged+           #*000000000001000)
(defconstant +supplier+         #*000000000010000)
(defconstant +builder+          #*000000000100000)
(defconstant +expert+           #*000000001000000)
(defconstant +admin+            #*000000010000000)
(defconstant +self+             #*000000100000000)
(defconstant +owner+            #*000001000000000)
(defconstant +all+              #*000001111111110)
(defconstant +active+           #*000010000000000) ;; tender status - если +active+ то время подачи заявок не истекло
(defconstant +unactive+         #*000100000000000)
(defconstant +finished+         #*001000000000000)
(defconstant +cancelled+        #*010000000000000)
(defconstant +unfair+           #*100000000000000) ;; supplier status

;; Разрешения полей (если они есть) перекрывают разрешения определенные для сущности,
;; в противном случае поля получают разрешения общие для сущности.

;; Сущности, используемые в программе
(defparameter *entityes*
  '(

    ;; Сущности, олицетворяющие пользователей

    ;; Базовая сущность "Пользователь"
    (:entity               user
     :container            nil
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd))))


    ;; Администратор
    (:entity               admin
     :super                user
     :container            user
     :fields
     ((last-visits         "Последние визиты"           (:list-of-str)                   ((:update +system+))))
     :perm
     ((:create +nobody+)   (:delete +nobody+)           (:view   +self+)                 (:update +self+)))


    ;; Эксперт
    (:entity               expert
     :super                user
     :container            user
     :fields
     ((last-tenders        "Последние тендеры"          (:list-of-link tender))          ((:update +system+)))
     ;; По идее эксперт может оставлять заметки к тендеру - возможно это потребует объект-связку "эксперт-тендер"
     :perm
     ((:create +admin+)    (:delete +admin+)            (:view (or +admin+ +self+))      (:update (or +admin+ +self+))))


    ;; Поставщик
    (:entity               supplier
     :super                user
     :container            user
     :fields
     ((referal             "Реферал"                    (:link user)
                           ((:view   (or +admin+ +expert+))
                            (:update +admin+)))
      (status              "Статус"                     (:list-of-keys supplier-status)
                           ((:view   +all+)
                            (:update +admin+)))
      (name                "Организация-поставщик"      (:str))
      (juridical-address   "Юридический адрес"          (:str))
      (actual-address      "Фактический адрес"          (:str))
      (contacts            "Контактные телефоны"        (:list-of-str))  ;; cписок телефонов с возможностью ввода
      (email               "Email"                      (:str))          ;; отображение как ссылка mailto://....
      (site                "Сайт организации"           (:str))          ;; отображение как ссылка http://....
      (heads               "Руководство"                (:list-of-str))
      (requisites          "Реквизиты"                  (:text-box))
      (addresses           "Адреса офисов и магазинов"  (:list-of-str))
      (contact-person      "Контактное лицо"            (:str))
      (resources           "Поставляемые ресурсы"       (:list-of-link supplier-resource-price)
                           ((:add-resource +self+)
                            ;; создается связующий объект supplier-resource-price содержащий установленную поставщиком цену
                            (:del-resource +self+)      ;; удаляется связующий объект
                            (:change-price +self+)
                            ))
      (sale                "Скидки и акции"             (:list-of-link sale))    ;; sale - связующий объект
      (offers              "Принятые тендеры"           (:list-of-link offer)))  ;; offer - связующий объект?
     :perm
     ((:create             (or +admin+ +not-logged+))
      (:delete             +admin+)
      (:view               +all+)
      (:update             (or +admin+ +self+))
      (:registration       (or +not-logged+))           ;; регистрация в качестве поставщика (возможно по приглашению)
      (:request-fair       (and +self+ +unfair+))       ;; заявка на статус добросовестного поставщика
      (:offer              (and +active+ +self+))       ;; отвечает заявкой на тендер - (offer:create)
      ;; Найти пересечение ресурсов, заявленных поставщиком и ресурсов, и объявленных в тендере.
      ;; Дать возможность поставщику изменить результирующий список, в т.ч. установить цену каждого ресурса
      ;;
      ))


    ;; Связуюший объект: Заявка на участие в тендере. Связывает поставщика, тендер и ресурсы заявки
    (:entity               offer
     :container            offer
     :fields
     ((owner               "Поставщик ресурсов"         (:link supplier)                 (:update +admin+))
      (tender              "Тендер"                     (:link tender)                   (:update +admin+))
      (resources           "Ресурсы заявки"             (:list-of-link offer-resource)))
     :perm
     ((:create (and +active+ +supplier+)) ;; создается связанные объекты offer-resource, содержащие ресурсы заявки
      (:delete (and +owner+  +active+))   ;; удаляются связанные объекты offer-resource
      (:view   +all+)
      (:update (and +active+ +owner+))))


    ;; Связующий объект: Ресурсы и цены для заявки на участие в тендере
    (:entity               offer-resource
     :container            offer-resource
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update +admin+)))
      (offer               "Заявка"                     (:link offer)                    ((:update +admin+)))
      (resource            "Ресурс"                     (:link resource)                 ((:update +admin+)))
      (price               "Цена поставщика"            (:num)))
     :perm
     ;; Внимание! +active+ относится к тендеру!
     ((:create +owner+)
      (:delete +owner+)
      (:view   +all+)
      (:update (and +active+ +owner+))))


    ;; Связующий объект: Скидки и акции - связывает поставщика, объявленный им ресурс и хранит условия скидки
    (:entity               sale
     :container            sale
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update +admin+)))
      (resource            "Ресурс"                     (:link supplier-resource-price))
      (procent             "Процент скидки"             (:num))
      (price               "Цена со скидкой"            (:num))
      (notes               "Дополнительные условия"     (:text-box)))
     :perm
     ((:create +supplier+)
      (:delete +owner+)
      (:view   +all+)
      (:update +owner+)))


    ;; Связующий объект - ресурсы, заявленные поставщиком
    (:entity               supplier-resource-price
     :container            supplier-resource-price
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update +admin+)))
      (resource            "Ресурс"                     (:link resource)                 ((:update +admin+)))
      (price               "Цена поставщика"            (:num)))
     :perm
     ;; Внимание! +active+ относится к тендеру!
     ((:create +owner+)
      (:delete +owner+)
      (:view   +all+)
      (:update +owner+)))


    ;; Застройщик
    (:entity               builder
     :super                user
     :container            user
     :fields
     ((referal             "Реферал"                    (:link user)
                           ((:view (or +admin+ +expert+))
                            (:update +admin+)))
      (name                "Организация-застройщик"     (:str))
      (juridical-address   "Юридический адрес"          (:str))
      (requisites          "Реквизиты"                  (:text-box))
      (tenders             "Тендеры"                    (:list-of-link tender)))
     :perm
     ((:create +admin+)
      (:delete +admin+)
      (:view   +all+)
      (:update (or +admin+ +self+))
      (:create-tender +self+))


    ;; Иерархический каталог ресурсов


    ;; Категория - группа ресурсов, не содержащая в себе ресурсы, а ссылающаяся на них
    (:entity               category
     :container            category
     :fields
     ((name                "Имя"                        (:str))
      (parent              "Родительская категория"     (:link category))
      (child-categoryes    "Дочерние категории"         (:list-of-links category))
      (resources           "Ресурсы"                    (:list-of-links resource)))
     :perm
     ((:create +system+)
      (:delete +system+)
      (:view +all+)
      (:update +system+)))


    ;; Ресурсы
    (:entity               resource
     :container            resource
     :fields
     ((name                "Наименование"               (:str))
      (category            "Категория"                  (:link category))
      (resource-type       "Тип"                        (:list-of-keys resource-types))
      (unit                "Единица измерения"          (:str))
      (suppliers           "Поставляющие организации"   (:list-box supplier)))
     :perm
     ((:create +system+)
      (:delete +system+)
      (:view   +all+)
      (:update +system+)))


    ;; Связующий объект - пока непонятно сколько их и что они связывают?
    (:entity               resource-link
     :container            resource-link
     :fields
     ((tender              "Тендер"                     (:link tender)                   ((:update +admin+)))
      (resource            "Ресурс"                     (:link resource)                 ((:update +admin+)))
      (supplier            "Поставщик"                  (:link supplier)                 ((:update +admin+)))
      (price               "Цена поставщика"            (:num)))
     :perm
     ;; Внимание! +active+ относится к тендеру!
     ((:create +system+   (:delete (and +suplier+ +active+))  (:view +all+)              (:update (and +supplier+ +active+)))))


    ;; Тендеры
    (:entity               tender
     :container            tender
     :fields
     ((name                "Название"                   (:str))
      (status              "Статус"                     (:list-of-keys tender-status))
      (owner               "Заказчик"                   (:link builder)
                           ((:update-field +admin+))
      (uid                 "Номер"                      (:num)
                           ((:update-field +admin+))
      (dates               "Периоды проведения"         (:tender-period)
                           ((:update-field (or +admin+ (and +owner+ +unactive+)))))
      (result              "Оценка результатов"         (:str)
                           ((:update-field (or +admin (and +owner +active+)))))
      (price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                           ((:update-field +nobody+)))
      (resources           "Ресурсы"                    (:list-of-links resource)
                           ((:update-field (and +owner+ +unactive+))))
      (documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                           ((:update-field (and +owner+ +unactive+))))
      (suppliers           "Поставщики"                 (:list-of-link  supplier) ;; строится по ресурсам автоматически
                           ((:update-field +system+)))
      (offerts             "Откликнувшиеся поставщики"  (:list-of-links supplier)
                           ((:update-field +system+))))))
     :perm
     ((:create +builder+)
      (:delete +admin+)
      (:view +all+)
      (:update (or +admin+ +owner+))
      (:activation (or +owner+ +unactive+))
      (:finish (or +owner+ +active+))
      (:cancel (or +owner+ +active+))))


    ;; Связанные с тендерами документы
    (:entity               document
     :container            document
     :fields
     ((name                "Название"                   (:str))
      (filename            "Имя файла"                  (:str))
      (tender              "Тендер"                     (:link tender)))
     :perm
     ((:create +owner+)
      (:delete (and +owner+ +unactive+))
      (:view   +all+)
      (:update +owner+)))))


;; Из этого всего генерируются объекты и прочий стафф:


(defclass resource (entity)
  ((parent-group  :initarg :parent-group  :initform nil        :accessor parent-group)
   (res-type      :initarg :res-type      :initform :material  :accessor res-type)
   (unit          :initarg :unit          :initform "шт."      :accessor unit)
   (suppliers     :initarg :suppliers     :initform nil        :accessor suppliers)))

(defparameter *block* (make-instance 'resource
                                     :name "Блок бетонный"
                                     :parent-group "Бетонные блоки"))


(defmethod view ((res entity))
  (format nil "<table>~A</table>" "test"))

(view *block*)
