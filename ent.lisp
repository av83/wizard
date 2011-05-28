
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
    :interval             ;; диапазоны дат, относящиеся к тендеру
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
     (:view   +self+
      :update +self+))


    ;; Эксперт
    (:entity               expert
     :super                user
     :container            user
     :fields
     ((last-tenders        "Последние тендеры"          (:list-of-link tender)          ((:update +system+))))
     ;; По идее эксперт может оставлять заметки к тендеру - возможно это потребует объект-связку "эксперт-тендер"
     :perm
     (:create +admin+
      :delete +admin+
      :view   (or +admin+ +self+)
      :update (or +admin+ +self+)))


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
     (:create             (or +admin+ +not-logged+)
      :delete             +admin+
      :view               +all+
      :update             (or +admin+ +self+)
      :registration       (or +not-logged+)            ;; регистрация в качестве поставщика (возможно по приглашению)
      :request-fair       (and +self+ +unfair+)        ;; заявка на статус добросовестного поставщика
      :offer              (and +active+ +self+)        ;; отвечает заявкой на тендер - (offer:create)
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
     (:create (and +active+ +supplier+) ;; создается связанные объекты offer-resource, содержащие ресурсы заявки
      :delete (and +owner+  +active+)   ;; удаляются связанные объекты offer-resource
      :view   +all+
      :update (and +active+ +owner+)))


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
     (:create +owner+
      :delete +owner+
      :view   +all+
      :update (and +active+ +owner+)))


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
     (:create +supplier+
      :delete +owner+
      :view   +all+
      :update +owner+))


    ;; Связующий объект - ресурсы, заявленные поставщиком
    (:entity               supplier-resource-price
     :container            supplier-resource-price
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update +admin+)))
      (resource            "Ресурс"                     (:link resource)                 ((:update +admin+)))
      (price               "Цена поставщика"            (:num)))
     :perm
     ;; Внимание! +active+ относится к тендеру!
     (:create +owner+
      :delete +owner+
      :view   +all+
      :update +owner+))


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
      (tenders             "Тендеры"                    (:list-of-link tender))
      (rating              "Рейтинг"                    (:num)
                           ((:update +system+))))
     :perm
     (:create +admin+
      :delete +admin+
      :view   +all+
      :update (or +admin+ +self+)
      :create-tender +self+))


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
     (:create +system+
      :delete +system+
      :view +all+
      :update +system+))


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
     (:create +system+
      :delete +system+
      :view   +all+
      :update +system+))


    ;; Тендеры
    (:entity               tender
     :container            tender
     :fields
     ((name                "Название"                   (:str))
      (status              "Статус"                     (:list-of-keys tender-status))
      (owner               "Заказчик"                   (:link builder)
                           ((:update-field +admin+)))
      (all                 "Срок проведения"            (:interval)
                           ((:update-field (or +admin+  (and +owner+ +unactive+)))))
      (claim               "Срок подачи заявок"         (:interval)
                           ((:update-field (or +admin+  (and +owner+ +unactive+)))))
      (analize             "Срок рассмотрения заявок"   (:interval)
                           ((:update-field (or +admin+  (and +owner+ +unactive+)))))
      (interview           "Срок проведения интервью"   (:interval)
                           ((:update-field (or +admin+  (and +owner+ +unactive+)))))
      (result              "Срок подведения итогов"     (:interval)
                           ((:update-field (or +admin+ (and +owner+ +unactive+)))))
      (winner              "Победитель тендера"         (:link supplier)
                           ((:view-field    +finished+)))
      (price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                           ((:update-field +nobody+)))
      (resources           "Ресурсы"                    (:list-of-links resource)
                           ((:update-field (and +owner+ +unactive+))))
      (documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                           ((:update-field (and +owner+ +unactive+))))
      (suppliers           "Поставщики"                 (:list-of-link  supplier) ;; строится по ресурсам автоматически
                           ((:update-field +system+)))
      (offerts             "Откликнувшиеся поставщики"  (:list-of-links supplier)
                           ((:update-field +system+))))
     :perm
     (:create +builder+
      :delete +admin+
      :view +all+
      :update (or +admin+ +owner+)
      :activation (or +owner+ +unactive+)
      :finish (or +owner+ +active+)
      :cancel (or +owner+ +active+)))


    ;; Связанные с тендерами документы
    (:entity               document
     :container            document
     :fields
     ((name                "Название"                   (:str))
      (filename            "Имя файла"                  (:str))
      (tender              "Тендер"                     (:link tender)))
     :perm
     (:create +owner+
      :delete (and +owner+ +unactive+)
      :view   +all+
      :update +owner+))))


(defparameter *places*
  '(

    ;; Мы считаем, что если у пользователя есть права на редактирование
    ;; всего объекта или части его полей - то эти поля показываются как
    ;; доступные для редактирования.

    ;; Страница застройщиков - коллекция по юзерам с фильтром по типу юзера
    (:place               builders
     :caption             "Организации-застройщики"
     :interface
     '((:item-type        :collection
        :element-type     user
        :filter           (:type-of builder)
        :sort             "Добросовестность, кол-во открытых тендеров, поле rating элемента"
        :fields           '((:simple-type  :str
                             :value        "Поле name элемента"
                             :link         "Страница элемента")
                            (:simple-type  :num
                             :value        "Count от кол-ва тендеров объекта"
                             :link         "Страница тендеров объекта")))))


    ;; Страница застройщика - объект юзер с возможностью объявить тендер
    (:place               builder/:id
     :caption             "Застройщик такой-то (name object)"
     :interface
     '((:item-type        :object
        :fields           (name juridical-address requisites tenders))
       (:item-type        :button
        :caption          "Объявить тендер"
        :perm             +builder+
        :goto             create-tender)))


    ;; Страница тендеров застройщика - коллекция по тендерам с фильтром по owner-у
    (:place               builder-tender/:id
     :caption             "Тендеры застройщика такого-то (name (owner object))"
     :interface
     '((:item-type        :collection
        :element-type     tender
        :filter           (:owner :id)
        :sort             "Дата завершения приема заявок?"
        :fields           '((:simple-type  :str
                             :value        "Название тендера"
                             :link         "Страница тендера")
                            (:simple-type  :interval
                             :value        "Дата завершения"
                             :link         "Страница тендера")
                            ;; Здесь можно придумать раскрывающийся список ресурсов
                            (:simple-type  :num
                             :value        "Кол-во ресурсов"
                             :link         "Страница тендера")
                            (:simple-type  :button
                             :caption      "Откликнуться на тендер"
                             :perm         "builder"
                             :link          "Страница оформления заявки"))


    ;; Страница объявления тендера
    (:place               create-tender
     :caption             "Создание нового тендера"
     :perm                +builder+
     :interface           (name all claim analize interview result resources documents price suppliers)
     :hooks
     (:change resources   (set-field price (calc-tender-price (request resources)))
      :change resources   (set-field suppliers (calc-suppliers (request resources))))
     :button              "Объявить тендер"
     :controller          (:request (all claim analize interview result name resources documents)
                           :other   '(:owner      (get-current-user-id)
                                      :price      (calc-tender-price (request resources))
                                      :suppliers  (calc-suppliers (request resources))
                                      :offerts    nil
                                      :winner     nil)
                           :code    (:make-instance tender)
                           :status     :unactive))

    ;; Страница тендера
    (:place               tender
     :caption             "Тендер"
     :interface           (name status owner all claim analize interview result winner price resources document suppliers offerts)
     :button              (:offer              "Оставить заявку"
                           :perm               +supplier+
                           :goto               offer-tender))

    ;; Страница "Оставить заявку на тендер"
    (:place               offer-tender
     :caption             "Оставить заявку"
     :interface




(defun gen (entityes)
  (with-open-file (output "gen.lisp" :direction :output :if-exists :supersede)
    (let ((containers)
          (classes (make-hash-table :test #'equal)))
      ;; Containers
      (loop :for entity :in entityes :do
         (let ((container (getf entity :container)))
           (unless (null container)
             (push container containers))))
      (setf containers (reverse (remove-duplicates containers)))
      (format output "~%~%;; Containers~%")
      (loop :for container :in containers :do
         (format output "~%~<(defparameter *~A* ~43:T (make-hash-table :test #'equal))~:>"
                 `(,container)))
      ;; Classes
      (format output "~%~%;; Classes")
      (loop :for entity :in entityes :do
         (let ((super (getf entity :super)))
           (when (null super)
             (setf super 'entity))
           (format output "~%~%~%~<(defclass ~A (~A)~%(~{~A~^~%~}))~:>"
                   `(,(getf entity :entity)
                      ,super
                      ,(loop :for field :in (getf entity :fields) :collect
                          (let ((fld (car field)))
                            (format nil "~<(~A ~23:T :initarg :~A ~53:T :initform nil :accessor ~A)~:>"
                                    `(,fld ,fld ,fld)))))))
         (let ((perm (getf entity :perm)))
           (unless (null (getf perm :create))
             (format output "~%~%(defmethod initialize-instance :after ((object ~A) &key)"
                     (getf entity :entity))
             (format output "~%  ;; Здесь будет проверка прав~%  ;; ...~%  ;; Запись в контейнер")
             (format output "~%  (setf (gethash (hash-table-count *~A*) *~A*) object)"
                     (getf entity :container)
                     (getf entity :container))
             (format output ")"))
           (unless (null (getf perm :view))
             (format output "~%~%(defmethod view ((object ~A) &key)"
                     (getf entity :entity))
             (format output "~%  ;; Здесь будет проверка прав~%  ;; ...~%  ;; Печать")
             (let ((fields (getf entity :fields)))
               (loop :for fld :in fields :collect
                  (let ((caption (cadr fld))
                        (name    (car fld)))
                    (format output "~%  (format t \"~A~A : ~A\" (~A object))" "~%" caption "~A" name))))

             (format output ")"))
           )))))

(gen *entityes*)

(make-instance 'supplier :name "xxx")

(view (gethash 0 *user*))






