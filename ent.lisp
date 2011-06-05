
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
    :date                 ;; дата
    :interval             ;; диапазоны дат, относящиеся к тендеру
    ))

;; Возможные типы ресурсов: машины, материалы etc
(defparameter *resource-type*
  '(:machine "машина" :material "материал"))

;; Возможные статусы тендеров
(defparameter *tender-status*
  '(:active "активный" :unactive "неактивный" :finished "завершенный" :cancelled "отмененный"))

;; Возможные статусы поставщиков
(defparameter *supplier-status*
  '(:fair "добросовестный" :unfair "недобросовестный" :request "подана заявка"))


;; Перед вызовом действия (даже если это показ поля) в процедуру проверки прав передается правило, субьект действия (пользователь)
;; и объект действия (объект, над котором действие совершается), если разрешение получено - выполняется действие
;; Разрешения полей перекрывают разрешения определенные для сущности, если они есть, иначе поля получают разрешения общие для сущности.

(defparameter *rules*
  '(;; Actors
    :nobody      "Никто"
    :system      "Система (загрузка данных на старте и изменение статуса поставщиков, когда оплаченное время добросовестности истеклл)"
    :all         "Все пользователи"
    :notlogged   "Незалогиненный пользователь (может зарегистрироваться как поставщик)"
    :logged      "Залогиненный пользователь"
    :admin       "Администратор"
    :expert      "Незалогиненный пользователь"
    :builder     "Пользователь-Застройщик"
    :supplier    "Пользователь-Поставщик"
    ;; Objects
    :fair        "Обьект является добросовестным поставщиком"
    :unfair      "Объект является недобросовестным поставщиком"
    :active      "Объект является активным тендером, т.е. время подачи заявок не истекло"
    :unacitve    "Объект является неакивным тендером, т.е. время подачи заявок не наступило"
    :fresh       "Объект является свежим тендером, т.е. недавно стал активным"
    :finished    "Объект является завершенным тендером"
    :cancelled   "Объект является отмененным тендером"
    ;; Mixed
    :self        "Объект олицетворяет пользователя, который совершает над ним действие"
    :owner       "Объект, над которым совершается действие имеет поле owner содержащее ссылку на объект текущего пользователя"
    ))


;; Сущности, используемые в программе, по ним строятся объекты и контейнеры, в которых они хранятся.
;; Также названия полей используются для построения интерфейсов CRUD
(defparameter *entityes*
  '(

    ;; Администратор
    (:entity               admin
     :container            user
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd)))
     :perm
     (:view                :self
      :update              :self))

    ;; Эксперт - имеет доступ не ко всем тендерам (в будущем!)
    (:entity               expert
     :super                user
     :container            user
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd))
      (name                "ФИО"                        (:str)))
     :perm
     (:create              :admin
      :delete              :admin
      :view                (or :admin :self)
      :update              (or :admin :self)))


    ;; Поставщик
    (:entity               supplier
     :super                user
     :container            user
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd))
      (name                "Название организации"       (:str))
      (referal             "Реферал"                    (:link user)
                           '(:create :system             ;; Если застройщик привел этого поставщика
                             :view   (or :admin :expert) ;; то здесь ссылка на застройщика
                             :update :nobody))
      (status              "Статус"                     (:list-of-keys supplier-status)
                           '(:view   :all
                             :update :admin))
      (name                "Организация-поставщик"      (:str))
      (juridical-address   "Юридический адрес"          (:str)
                           '(:view   :logged))          ;; Гость не видит
      (actual-address      "Фактический адрес"          (:str))
      (contacts            "Контактные телефоны"        (:list-of-str)      ;; cписок телефонов с возможностью ввода
                           '(:view   (or :logged :fair)))                   ;; незалогиненные могут видеть только тел. добросовестных
      (email               "Email"                      (:str))             ;; отображение как ссылка mailto://....
      (site                "Сайт организации"           (:str))             ;; отображение как ссылка http://....
      (heads               "Руководство"                (:list-of-str)
                           '(:view   :logged))                              ;; Гости этого не видят руководство фирм-поставщиков
      (inn                 "Инн"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (kpp                 "КПП"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (ogrn                "ОГРН"                       (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (bank-name           "Название банка"             (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (bik                 "Банковский идентификационный код" (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (corresp-account     "Корреспондентский счет)"    (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (client-account      "Рассчетный счет"            (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты (!)
      (addresses           "Адреса офисов и магазинов"  (:list-of-str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (contact-person      "Контактное лицо"            (:str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (resources           "Поставляемые ресурсы"       (:list-of-link supplier-resource-price)
                           '(:add-resource :self   ;; создается связующий объект supplier-resource-price содержащий установленную поставщиком цену
                             :del-resource :self   ;; удаляется связующий объект
                             :change-price :self))
      (sale                "Скидки и акции"             (:list-of-link sale))    ;; sale - связующий объект
      (offers              "Принятые тендеры"           (:list-of-link offer)))  ;; offer - связующий объект
     :perm
     (:create             (or :admin :not-logged)
      :delete             :admin
      :view               :all
      :update             (or :admin :self)))


    ;; Связующий объект: Заявка на участие в тендере. Связывает поставщика, тендер и ресурсы заявки
    ;; Создается поставщиком, когда он отвечает своим предложением на тендер застройщика
    (:entity               offer
     :container            offer
     :fields
     ((owner               "Поставщик ресурсов"         (:link supplier)                 (:update :nobody))
      (tender              "Тендер"                     (:link tender)                   (:update :nobody))
      (resources           "Ресурсы заявки"             (:list-of-link offer-resource)))
     :perm
     (:create (and :active :supplier)  ;; создается связанный объект offer-resource, содержащие ресурсы заявки
      :delete (and :owner  :active)   ;; удаляются связанный объект offer-resource
      :view   :all
      :update (and :active :owner)    ;; Заявка модет быть отредактирвана пока срок приема заявок не истек.
      ))


    ;; Связующий объект: Ресурсы и цены для заявки на участие в тендере
    (:entity               offer-resource
     :container            offer-resource
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update :admin)))
      (offer               "Заявка"                     (:link offer)                    ((:update :admin)))
      (resource            "Ресурс"                     (:link resource)                 ((:update :admin)))
      (price               "Цена поставщика"            (:num)))
     :perm
     (:create :owner
      :delete :owner
      :view   :all
      :update (and :active :owner)))


    ;; Связующий объект: Скидки и акции - связывает поставщика, объявленный им ресурс и хранит условия скидки
    (:entity               sale
     :container            sale
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update :admin)))
      (resource            "Ресурс"                     (:link supplier-resource-price))
      (procent             "Процент скидки"             (:num))
      (price               "Цена со скидкой"            (:num))
      (notes               "Дополнительные условия"     (:text-box)))
     :perm
     (:create :supplier
      :delete :owner
      :view   :all
      :update :owner))


    ;; Связующий объект - ресурсы, заявленные поставщиком
    (:entity               supplier-resource-price
     :container            supplier-resource-price
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update :admin)))
      (resource            "Ресурс"                     (:link resource)                 ((:update :admin)))
      (price               "Цена поставщика"            (:num)))
     :perm
     (:create :owner
      :delete :owner
      :view   :all
      :update :owner))


    ;; Застройщик - набор полей не утвержден (берем с чужого сайта)
    (:entity               builder
     :super                user
     :container            user
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd))
      (name                "Организация-застройщик"     (:str))
      (juridical-address   "Юридический адрес"          (:str))
      (inn                 "Инн"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (kpp                 "КПП"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (ogrn                "ОГРН"                       (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиенные видят только добросовестных
      (bank-name           "Название банка"             (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (bik                 "Банковский идентификационный код" (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (corresp-account     "Корреспондентский счет)"    (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (client-account      "Рассчетный счет"            (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты (!)
      (tenders             "Тендеры"                    (:list-of-link tender))
      (rating              "Рейтинг"                    (:num)
                           ((:update :system))))
     :perm
     (:create :admin
      :delete :admin
      :view   :all
      :update (or :admin :self)))


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
     (:create :system
      :delete :system
      :view   :all
      :update :system))


    ;; Ресурс
    (:entity               resource
     :container            resource
     :fields
     ((name                "Наименование"               (:str))
      (category            "Категория"                  (:link category))
      (resource-type       "Тип"                        (:list-of-keys resource-types))
      (unit                "Единица измерения"          (:str))
      (suppliers           "Поставляющие организации"   (:list-box supplier)))
     :perm
     (:create :system
      :delete :system
      :view   :all
      :update :system))


    ;; Тендеры
    ;; Незалогиненный видит Номер, название, срок проведения, статус
    ;; Недобросовестный поставщик видит то же что и незалогиненный
    (:entity               tender
     :container            tender
     :fields
     ((name                "Название"                   (:str))
      (status              "Статус"                     (:list-of-keys tender-status))
      (owner               "Заказчик"                   (:link builder)
                           ((:update-field :admin)))
      ;; Дата, когда тендер стал активным (первые сутки новые тендеры видят только добростовестные поставщики)
      (active-date         "Дата активации"             (:date)
                           ((:update-field :system)))
      (all                 "Срок проведения"            (:interval)
                           ((:update-field (or :admin  (and :owner :unactive)))))
      (claim               "Срок подачи заявок"         (:interval)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (or :admin  (and :owner :unactive)))))
      (analize             "Срок рассмотрения заявок"   (:interval)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (or :admin  (and :owner :unactive)))))
      (interview           "Срок проведения интервью"   (:interval)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (or :admin  (and :owner :unactive)))))
      (result              "Срок подведения итогов"     (:interval)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (or :admin (and :owner :unactive)))))
      (winner              "Победитель тендера"         (:link supplier)
                           ((:view (and :fair :builder :admin :expert))
                            (:view-field    :finished)))
      (price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                           ((:update-field :nobody)))
      (resources           "Ресурсы"                    (:list-of-links resource)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (and :owner :unactive))))
      (documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field (and :owner :unactive))))
      (suppliers           "Поставщики"                 (:list-of-link  supplier) ;; строится по ресурсам автоматически
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field :system)))
      (offerts             "Откликнувшиеся поставщики"  (:list-of-links supplier)
                           ((:view (and :fair :builder :admin :expert))
                            (:update-field :system))))
     :perm
     (:create :builder
      :delete :admin
      :view   :all
      :update (or :admin :owner)))


    ;; Связанные с тендерами документы
    (:entity               document
     :container            document
     :fields
     ((name                "Название"                   (:str))
      (filename            "Имя файла"                  (:str))
      (tender              "Тендер"                     (:link tender)))
     :perm
     (:create :owner
      :delete (and :owner :unactive)
      :view   :all
      :update :owner))))


;; Мы считаем, что если у пользователя есть права на редактирование
;; всего объекта или части его полей - то эти поля показываются как
;; доступные для редактирования.


(defparameter *places*
  '(
    ;; Личный кабинет Администратора
    (:place                admin
     :actions
     '((:caption           "Изменить пароль"
        :perm              :admin
        :entity            admin
        :values            :user
        :fields            '(login password
                             (:btn "Изменить пароль" :act (change-admin-password :user :form))))
       (:caption           "Создать аккаунт эксперта"
        :perm              :admin
        :entity            expert
        :values            nil
        :fields            '(login password
                             (:btn "Создать новый аккаунт эксперта" :act (create-expert :user :form))))
       (:caption           "Эксперты"
        :perm              :admin
        :entity            expert
        :values            :collection ;; В коллекции клик на строчке переходит на страницу объекта
        :fields            '(name login
                             (:btn "Удалить аккаунт эксперта"
                              :actions
                              '((:caption           "Действительно удалить?"
                                 :perm               :admin
                                 :entity             expert
                                 :fields             '(:btn "Подтверждаю удаление" :act (delete-expert :user :row)))))
                             (:btn "Сменить пароль эксперта"
                              :actions
                              '((:caption           "Смена пароля эксперта"
                                 :pern              :admin
                                 :entity            expert
                                 :fields            '((:str "Новый пароль" new-password)
                                                      (:btn "Изменить пароль эксперта" :act (change-expert-password :user :row :form))))))))
       (:caption           "Заявки поставщиков на добросовестность"
        :perm              :admin
        :entity            expert
        :values            :collection
        :fields            '(name login
                             (:btn "Подтвердить заявку"
                              :actions
                              '((:caption           "Подтвердить заявку поставщика"
                                 :perm               :admin
                                 :entity             supplier
                                 :fields             '((:btn "Сделать добросовестным" :act (approve-supplier-fair :user :row))))))))))

    ;; Личный кабинет Поставщика
    (:place                supplier
     :actions
     '((:caption           "Отправить заявку на добросовестность" ;; заявка на статус добросовестного поставщика (изменяет статус поставщика)
        :perm              (and :self :unfair)
        :entity            supplier
        :fields            '((:btn "Отправить заявку на добросовестность" :act (supplier-request-fair :user))))
       (:caption           "Изменить список ресурсов"
        :perm              :self
        :entity            supplier-resource-price
        :values            :collection
        :fields            '(owner resource price
                             (:btn "Добавить ресурс")
                             (:btn "Удалить ресурс")
                             (:btn "Изменить ресурс")))))

    ;; Страница тендера
    (:place                tender
     :actions
     '((:caption           "Ответить заявкой на тендер" ;; Добросовестный поставщик отвечает заявкой на тендер
        :perm              (and :active :fair)
        :entity            tender
        :fields            '(name status owner active-date all claim analize interview result winner price resources documents suppliers offerts
                             (:bnt "Ответить заявкой на тендер"
                              :actions
                              '((:caption           "Выберите ресурсы"
                                 :perm              (and :active :fair)
                                 :entity            :intersect
                                 :fields
                                 '((:btn "Участвовать в тендере" :act (create-offer :user :form tender))))))))
       (:caption           "Отменить тендер"
        :perm              :owner
        :entity            tender
        :fields            '(:btn "Отменить тендер"
                             :actions
                             '((:caption           "Действительно отменить?"
                                :perm               :owner
                                :entity             tender
                                :fields             '(:btn "Подтверждаю отмену" :act (cancel-tender :user :row))))))))


    ;; Личный кабинет застройщика с возможностью объявить тендер
    (:place                builder/:id
     :actions
     '((:caption           "Застройщик такой-то (name object)"
        :entity            builder
        :fields            '(name juridical-address requisites tenders
                             (:btn "Показать тендеры"
                              :actions
                              '((:caption            "Тендеры застройщика"
                                 :perm               "<?>Кто может видеть тендеры застройщика?"
                                 :entity             tender
                                 :filter             (:owner :id)
                                 :values             :collection
                                 :sort               "Дата завершения приема заявок<?>"
                                 :fields             '(name status active-date all claim analize interview))))))
       (:caption           "Объявить тендер"
        :perm              :self
        :entity            tender
        :fields            '(name all claim analize interview result resources documents price suppliers
                             (:btn "Объявить тендер" :act (create-tender :user :form)))
        :hooks
        (:change resources   (set-field price (calc-tender-price (request resources)))
         :change resources   (set-field suppliers (calc-suppliers (request resources))))
        :controller          (:request (all claim analize interview result name resources documents)
                              :other   '(:owner      (get-current-user-id)
                                         :price      (calc-tender-price (request resources))
                                         :suppliers  (calc-suppliers (request resources))
                                         :offerts    nil
                                         :winner     nil)
                              :code    (:make-instance tender)
                              :status     :unactive))
       ))


    ;; Страница застройщиков - коллекция по юзерам с фильтром по типу юзера
    (:place                builders
     :actions
     '((:caption           "Организации-застройщики"
        :perm              "<?>"
        :entity            user
        :values            :collection
        :filter            (:type-of builder)
        :sort              "<?> Добросовестность, кол-во открытых тендеров, поле rating элемента <?>"
        ;; <?> Как будем показывать тендеры застройщика?
        :fields           '((name juridical-address requisites tenders rating)))))



;; генератор
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






