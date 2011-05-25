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
    :list-of-entityes     ;; список скопированных сущностей
    :list-of-keys         ;; выпадающий список ключей, с выбором одного из них
    :text-box             ;; текстовое поле
    :tender-period        ;; диапазоны дат, относящиеся к тендеру
    ))


;; Возможные типы ресурсов: машины, материалы etc
(defparameter *resource-type*  '(:machine "машина" :material "материал"))

;; Возможные статусы тендеров
(defparameter *tender-status*    '(:active "активный" :unactive "неактивный"
                                   :finished "завершенный" :cancelled "отмененный"))
;; Возможные статусы поставщиков
(defparameter *supplier-status*  '(:fair "добросовестный" :unfair "недобросовестный"))


;; Константы для контроля разрешений
(defconstant +nobody+           #*00000000000000)
(defconstant +system+           #*00000000000010)
(defconstant +not-logged+       #*00000000000100)
(defconstant +logged+           #*00000000001000)
(defconstant +supplier+         #*00000000010000)
(defconstant +builder+          #*00000000100000)
(defconstant +expert+           #*00000001000000)
(defconstant +admin+            #*00000010000000)
(defconstant +self+             #*00000100000000)
(defconstant +owner+            #*00001000000000)
(defconstant +all+              #*00001111111100)
(defconstant +active+           #*00010000000000)
(defconstant +unactive+         #*00100000000000)
(defconstant +finished+         #*01000000000000)
(defconstant +cancelled+        #*10000000000000)

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
     :perm
     ((:create +admin+)    (:delete +admin+)            (:view (or +admin+ +self+))      (:update (or +admin+ +self+))))

    ;; Поставщик
    (:entity               supplier
     :super                user
     :container            user
     :fields
     ((referal             "Реферал"                    (:link user)                     ((:view   (or +admin+ +expert+))
                                                                                          (:update +admin+)))
      (status              "Статус"                     (:list-of-keys supplier-status)  ((:view   +all+)
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
      (contact-person      "Контактное лицо"            (:str)))
     :perm
     ((:create +admin+)    (:delete +admin+)            (:view +all+)                    (:update (+admin+ +self+))))

    ;; Застройщик
    (:entity               builder
     :super                user
     :container            user
     :fields
     ((referal             "Реферал"                    (:link user)                     ((:view (or +admin+ +expert+))
                                                                                          (:update +admin+)))
      (name                "Организация-застройщик"     (:str))
      (juridical-address   "Юридический адрес"          (:str))
      (requisites          "Реквизиты"                  (:text-box))
      (tenders             "Тендеры"                    (:list-of-link tender)))
     :perm
     ((:create +admin+)    (:delete +admin+)            (:view +all+)                    (:update (or +admin+ +self+))))

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
     ((:create +system+)   (:delete +system+)           (:view +all+)                    (:update +system+)))

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
     ((:create +system+)   (:delete +system+)           (:view +all+)                    (:update +system+)))

    ;; Связующий объект
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
     ((:create +builder+)  (:delete +admin+)            (:view +all+)                    (:update (or +admin+ +owner+))))

    ;; Связанные с тендерами документы
    (:entity               document
     :container            document
     :fields
     ((name                "Название"                   (:str))
      (filename            "Имя файла"                  (:str))
      (tender              "Тендер"                     (:link tender)))
     :perm
     ((create +supplier+) (:delete (and +supplier+ +unactive+))  (:view +all+)           (update  (and +supplier+ +unactive+))))))


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
