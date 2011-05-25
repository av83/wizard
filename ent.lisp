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
    :list-of-str          ;; список строк (модификатор: возможность ввода строк пользователем)
    :link                 ;; связанная сущность (модификатор: тип сущности)
    :list-of-links        ;; список связанных сущностей
    :drop-down-key-list   ;; выпадающий список ключей, с выбором одного из них
    :text-box             ;; текстовое поле
    :tender-period        ;; диапазоны дат, относящиеся к тендеру
    ))


;; Возможные типы ресурсов: машины, материалы etc
(defparameter *resource-type*  '(:machine "машина" :material "материал"))

;; Возможные статусы тендеров: активный, неактивный, завершенный, отмененный
(defparameter *tender-type*    '(:active "активный" :unactive "неактивный"
                                 :finished "завершенный" :cancelled "отмененный"))


;; Сущности, используемые в программе
(defparameter *entityes*
  '((resource ((name                "Наименование"               :str)
               (parent-group        "Категория"                  :link                resource)
               (resource-type       "Тип"                        :drop-down-key-list  resource-types)
               (unit                "Единица измерения"          :str)
               (suppliers           "Поставляющие организации"   :list-box            supplier)))
    (supplier ((name                "Организация-поставщик"      :str)
               (fairness            "Добросовестный поставщик"   :bool)
               (juridical-address   "Юридический адрес"          :str)
               (actual-address      "Фактический адрес"          :str)
               (contacts            "Контактные телефоны"        :list-of-str)  ;; cписок телефонов с возможностью ввода
               (email               "Email"                      :str)          ;; отображение как ссылка mailto://....
               (site                "Сайт организации"           :str)          ;; отображение как ссылка http://....
               (heads               "Руководство"                :list-of-str)
               (requisites          "Реквизиты"                  :text-box)
               (addresses           "Адреса офисов и магазинов"  :text-of-str)
               (contact-person      "Контактное лицо"            :str)))
    (builder  ((name                "Организация-застройщик"     :str)
               (juridical-address   "Юридический адрес"          :str)
               (requisites          "Реквизиты"                  :text-box)
               (tenders             "Тендеры"                    :list-of-link        tender)))
    (tender   ((name                "Название"                   :str)
               (status              "Статус"                     :drop-down-key-list  tender-type)
               (builder             "Заказчик"                   :link                builder)
               (uid                 "Номер"                      :num)
               (dates               "Периоды проведения"         :tender-period)
               (result              "Оценка результатов"         :str)
               (price               "Рекомендуемая стоимость"    :num)
               (resources           "Ресурсы"                    :list-of-links       resource)
               (documents           "Документы"                  :list-of-links       document) ;; закачка и удаление файлов
               (suppliers           "Поставщики"                 :list-of-links       supplier) ;; строится по ресурсам автоматически
               (offerts             "Откликнувшиеся поставщики"  :list-of-links       supplier)))
    (document ((name                "Название"                   :str)
               (filename            "Имя файла"                  :str)
               (tender              "Тендер"                     :link                tender)))))



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
