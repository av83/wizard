(require 'RESTAS)

(restas:define-module #:WIZARD
    (:use #:CL #:ITER ))

(in-package #:WIZARD)

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
;; Пока нет схемы перехода поставщика в добросовестного будем переводить через заявку


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
    :stale       "Объект является тендером, который давно стал активным"
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
      (juridical-address   "Юридический адрес"          (:str)
                           '(:view   :logged))          ;; Гость не видит
      (actual-address      "Фактический адрес"          (:str))
      (contacts            "Контактные телефоны"        (:list-of-str)      ;; cписок телефонов с возможностью ввода
                           '(:view   (or :logged :fair)))                   ;; незалогиненные могут видеть только тел. добросовестных
      (email               "Email"                      (:str)             ;; отображение как ссылка mailto://....
                           '(:view   (or :logged :fair)))
      (site                "Сайт организации"           (:str)             ;; отображение как ссылка http://....
                           '(:view   (or :logged :fair)))
      (heads               "Руководство"                (:list-of-str)
                           '(:view   :logged))                              ;; Гости не видят руководство фирм-поставщиков
      (inn                 "Инн"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (kpp                 "КПП"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (ogrn                "ОГРН"                       (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (bank-name           "Название банка"             (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (bik                 "Банковский идентификационный код" (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (corresp-account     "Корреспондентский счет"    (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (client-account      "Расчетный счет"            (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (addresses           "Адреса офисов и магазинов"  (:list-of-str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (contact-person      "Контактное лицо"            (:str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (resources           "Поставляемые ресурсы"       (:list-of-links supplier-resource-price)
                           '(:add-resource :self   ;; создается связующий объект supplier-resource-price содержащий установленную поставщиком цену
                             :del-resource :self   ;; удаляется связующий объект
                             :change-price :self))
      (sale                "Скидки и акции"             (:list-of-links sale))    ;; sale - связующий объект
      (offers              "Посланные заявки на тендеры"  (:list-of-links offer)
                           '(:view :self
                             :update :self)))  ;; offer - связующий объект
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
      (resources           "Ресурсы заявки"             (:list-of-links offer-resource)))
     :perm
     (:create (and :active :supplier) ;; создается связанный объект offer-resource, содержащие ресурсы заявки
      :delete (and :owner  :active)   ;; удаляются связанный объект offer-resource
      :view   :all
      :update (and :active :owner)    ;; Заявка модет быть отредактирвана пока срок приема заявок не истек.
      ))


    ;; Связующий объект: Ресурсы и цены для заявки на участие в тендере
    (:entity               offer-resource
     :container            offer-resource
     :fields
     ((owner               "Поставщик"                  (:link supplier)                 ((:update :nobody)))
      (offer               "Заявка"                     (:link offer)                    ((:update :nobody)))
      (resource            "Ресурс"                     (:link resource)                 ((:update :nobody)))
      (price               "Цена поставщика"            (:num)))
     :perm
     (:create :owner
      :delete :owner
      :view   :all
      :update (and :active :owner)))


    ;; Связующий объект: Скидки и акции - связывает поставщика, объявленный им ресурс и хранит условия скидки
    ;; (!) Создать страницу скидок и акций
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
     ((owner               "Поставщик"                  (:link supplier)                 ((:update :nobody)))
      (resource            "Ресурс"                     (:link resource))
      (price               "Цена поставщика"            (:num)))
     :perm
     (:create :owner
      :delete :owner
      :view   :all
      :update :owner))


    ;; Застройщик - набор полей не утвержден (берем с чужого сайта)
    (:entity               builder
     :container            user
     :fields
     ((login               "Логин"                      (:str))
      (password            "Пароль"                     (:pswd))
      (name                "Организация-застройщик"     (:str))
      (juridical-address   "Юридический адрес"          (:str))
      (inn                 "Инн"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (kpp                 "КПП"                        (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (ogrn                "ОГРН"                       (:str)
                           '(:view   (or :logged :fair)))                   ;; Незалогиненные видят только добросовестных
      (bank-name           "Название банка"             (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (bik                 "Банковский идентификационный код" (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (corresp-account     "Корреспондентский счет"     (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (client-account      "Рассчетный счет"            (:str)
                           '(:view   :logged))                              ;; Гость не видит банковские реквизиты
      (tenders             "Тендеры"                    (:list-of-links tender)
                           '(:view   :all)
                           (remove-if-not #'(lambda (x)
                                              (equal (a-owner (cdr x))
                                                     (gethash (parse-integer (nth 2 (request-list))) *USER*)))
                                          (cons-hash-list *TENDER*))
                           '(name (:btn "Страница тендера"
                                   :act (hunchentoot:redirect
                                         (format nil "/tender/~A" (get-btn-key (caar (form-data))))))))
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
     ((name                "Название"                   (:str)
                           '(:view   :all))
      (status              "Статус"                     (:list-of-keys tender-status)
                           '(:view   :all))
      (owner               "Заказчик"                   (:link builder)
                           ((:update :admin)))
      ;; Дата, когда тендер стал активным (первые сутки новые тендеры видят только добростовестные поставщики)
      (active-date         "Дата активации"             (:date)
                           ((:update :system)))
      (all                 "Срок проведения"            (:interval)
                           ((:view   :all)
                            (:update (or :admin  (and :owner :unactive)))))
      (claim               "Срок подачи заявок"         (:interval)
                           ((:update (or :admin  (and :owner :unactive)))))
      (analize             "Срок рассмотрения заявок"   (:interval)
                           ((:update (or :admin  (and :owner :unactive)))))
      (interview           "Срок проведения интервью"   (:interval)
                           ((:update (or :admin  (and :owner :unactive)))))
      (result              "Срок подведения итогов"     (:interval)
                           ((:update (or :admin (and :owner :unactive)))))
      (winner              "Победитель тендера"         (:link supplier)
                           ((:view   :finished)))
      (price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                           ((:update :system)))
      (resources           "Ресурсы"                    (:list-of-links resource)
                           ((:update (and :owner :unactive))))
      (documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                           ((:update (and :owner :unactive))))
      (suppliers           "Поставщики"                 (:list-of-links supplier) ;; строится по ресурсам автоматически
                           ((:update :system)))
      (offerts             "Откликнувшиеся поставщики"  (:list-of-links supplier)
                           ((:update-field :system))))
     :perm
     (:create :builder
      :delete :admin
      :view   (and :logged (or :stale (and :fresh :fair)))
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


(defmacro cons-hash-list (hash)
  `(loop :for obj :being the :hash-values :in ,hash :using (hash-key key) :collect
      (cons key obj)))

;; Мы считаем, что если у пользователя есть права на редактирование
;; всего объекта или части его полей - то эти поля показываются как
;; доступные для редактирования.


(defparameter *places*
  '(
    ;; Главная страница
    (:place                main
     :url                  "/"
     :navpoint             "Главная страница"
     :actions
     '((:caption           "Главная страница"
        :perm              :all)))
    ;; Личный кабинет Администратора
    (:place                admin
     :url                  "/admin"
     :navpoint             "Администратор"
     :actions
     '((:caption           "Изменить себе пароль"
        :perm              :admin
        :entity            admin
        :val               (cur-user)
        :fields            '(login password
                             (:btn "Изменить пароль"
                              :act
                              (progn
                                (setf (a-login (cur-user))     (cdr (assoc "LOGIN" (form-data) :test #'equal)))
                                (setf (a-password (cur-user))  (cdr (assoc "PASSWORD" (form-data) :test #'equal)))
                                (hunchentoot:redirect (hunchentoot:request-uri*)))
                              )))
       (:caption           "Создать аккаунт эксперта"
        :perm              :admin
        :entity            expert
        :val               :clear
        :fields            '(login password name
                             (:btn "Создать новый аккаунт эксперта"
                              :act
                              (progn
                                (make-instance 'expert
                                               :login (cdr (assoc "LOGIN" (form-data) :test #'equal))
                                               :password (cdr (assoc "PASSWORD" (form-data) :test #'equal))
                                               :name (cdr (assoc "NAME" (form-data) :test #'equal)))
                                (hunchentoot:redirect (hunchentoot:request-uri*)))
                              )))
       (:caption           "Эксперты"
        :perm              :admin
        :entity            expert
        :val               (remove-if-not #'(lambda (x)
                                              (equal 'expert (type-of (cdr x))))
                            (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Удалить"
                              :popup '(:caption            "Действительно удалить?"
                                       :entity             expert
                                       :perm               :admin
                                       :fields             '((:btn "Подтверждаю удаление"
                                                              :act
                                                              (progn
                                                                (let ((key (get-btn-key (caar (form-data)))))
                                                                  (remhash key *USER*))
                                                                (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                              ))))
                             (:btn "Сменить пароль"
                              :popup '(:caption           "Смена пароля эксперта"
                                       :entity            expert
                                       :perm              :admin
                                       :fields            '(password
                                                            (:btn "Изменить пароль эксперта"
                                                             :act
                                                             (progn
                                                                    (let ((key (get-btn-key (caar (last (form-data))))))
                                                                      (setf (a-password (gethash key *USER*))
                                                                            (cdr (assoc "PASSWORD" (form-data) :test #'equal))))
                                                                    (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                             ))))))

       (:caption           "Заявки поставщиков на добросовестность"
        :perm              :admin
        :entity            supplier
        :val               (remove-if-not #'(lambda (x)
                                              (and (equal 'supplier (type-of (cdr x)))
                                                   (equal (a-status (cdr x)) :request)))
                            (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Подтвердить заявку"
                              :popup '(:caption           "Подтвердить заявку поставщика"
                                       :perm               :admin
                                       :entity             supplier
                                       :fields             '((:btn "Сделать добросовестным"
                                                              :act
                                                              (progn
                                                                (let ((key (get-btn-key (caar (form-data)))))
                                                                  (setf (a-status (gethash key *USER*))
                                                                        :fair))
                                                                (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                              ))))))
       ))
    ;; Список экспертов
    (:place                experts
     :url                  "/expert"
     :navpoint             "Эксперты"
     :actions
     '((:caption           "Эксперты"
        :perm              :all
        :entity            expert
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'EXPERT)) (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Страница эксперта"
                              :act
                               (hunchentoot:redirect
                                 (format nil "/expert/~A" (get-btn-key (caar (form-data))))))))))

    ;; Страница эксперта
    (:place                expert
     :url                  "/expert/:id"
     :actions
     '((:caption           "Эксперт"
        :perm              :all
        :entity            expert
        :val               (gethash (parse-integer (caddr (request-list))) *USER*)
        :fields            '(name))))

    ;; Список поставщиков
    (:place                suppliers
     :url                  "/supplier"
     :navpoint             "Поставщики"
     :actions
     '((:caption           "Организации-поставщики"
        :perm              :all
        :entity            supplier
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'SUPPLIER))  (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Страница поставщика"
                              :act
                              (hunchentoot:redirect
                               (format nil "/supplier/~A" (get-btn-key (caar (form-data))))))))))

    ;; Страница поставщика
    (:place                supplier
     :url                  "/supplier/:id"
     :actions
     '((:caption           "Поставщик"
        :entity            supplier
        :val               (gethash (parse-integer (caddr (request-list))) *USER*)
        :fields            '(name status juridical-address actual-address contacts email site heads inn kpp ogrn
                             bank-name bik corresp-account client-account addresses contact-person resources sale offers))
       (:caption           "Отправить заявку на добросовестность" ;; заявка на статус добросовестного поставщика (изменяет статус поставщика)
        :perm              (and :self :unfair)
        :entity            supplier
        :val               (gethash 3 *USER*)
        :fields            '((:btn "Отправить заявку на добросовестность"
                              :act
                              (progn
                                (setf (a-status (gethash 3 *USER*)) :request)
                                (hunchentoot:redirect (hunchentoot:request-uri*))))))
       (:caption           "Список ресурсов, которые я поставляю"
        :perm              :self
        :entity            supplier-resource-price
        :val               (remove-if-not #'(lambda (x) (equal (a-owner (cdr x))
                                                               (gethash 3 *USER*)))
                            (cons-hash-list *SUPPLIER-RESOURCE-PRICE*))
        :fields            '(resource price
                             (:btn "Удалить"
                              :popup '(:caption           "Удаление ресурса"
                                       :perm              :admin
                                       :entity            expert
                                       :fields            '((:btn "Удалить ресурс"
                                                             :act
                                                             (progn
                                                               (let ((key (get-btn-key (caar (form-data)))))
                                                                 (remhash key *SUPPLIER-RESOURCE-PRICE*))
                                                               (hunchentoot:redirect (hunchentoot:request-uri*)))))))))
       (:caption           "Мои заявки на тендеры"
        :perm              :self
        :entity            offer
        :val               :collection
        :fields            '(tender))))

    ;; Список застройщиков
    (:place                builders
     :url                  "/builder"
     :navpoint             "Застройщики"
     :actions
     '((:caption           "Организации-застройщики"
        :perm              :all
        :entity            builder
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'BUILDER)) (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Страница застройщика"
                              :act
                              (hunchentoot:redirect
                               (format nil "/builder/~A" (get-btn-key (caar (form-data))))))))))

    ;; Страница застройщика
    (:place                builder
     :url                  "/builder/:id"
     :actions
     '((:caption           "Застройщик"
        :entity            builder
        :val               (gethash (parse-integer (caddr (request-list))) *USER*)
        :fields            '(name juridical-address inn kpp ogrn bank-name bik corresp-account client-account
                             (:col              "Тендеры застройщика"
                              :perm             111
                              :entity           tender
                              :val              (remove-if-not #'(lambda (x)
                                                                   (equal (a-owner (cdr x))
                                                                          (gethash (parse-integer (nth 2 (request-list))) *USER*)))
                                                 (cons-hash-list *TENDER*))
                              :fields '(name (:btn "Страница тендера"
                                              :act
                                              (hunchentoot:redirect
                                               (format nil "/tender/~A" (get-btn-key (caar (last (form-data) 2))))))))
                             rating))
       (:caption           "Объявить новый тендер"
        :perm              :self
        :entity            tender
        :val               :clear
        :fields            '(name all claim analize interview result
                             (:btn "Объявить тендер (+)"
                              :act
                              (let ((id (hash-table-count *TENDER*)))
                                (setf (gethash id *TENDER*)
                                      (make-instance 'TENDER
                                                     :name (cdr (ASSOC "NAME" (FORM-DATA) :test #'equal))
                                                     ))
                                (hunchentoot:redirect
                                 (format nil "/tender/~A" id)))
                              )))
       ))

    ;; Список тендеров
    (:place                tenders
     :url                  "/tender"
     :navpoint             "Тендеры"
     :actions
     '((:caption           "Тендеры"
        :perm              :all
        :entity            builder
        :val               (cons-hash-list *TENDER*)
        :fields            '(name status owner
                             (:btn "Страница тендера"
                              :act  "Страница тендера"
                              ;; (hunchentoot:redirect
                              ;;        (format nil "/tender/~A" (get-btn-key (caar (form-data))))))
                             )))))

    ;; Страница тендера (поставщик может откликнуться)
    (:place                tender
     :url                  "/tender/:id"
     :actions
     '((:caption           "Тендер"
        :entity            tender
        :val               (gethash (parse-integer (caddr (request-list))) *TENDER*)
        :fields            '(name status owner active-date all claim analize interview result winner price resources documents suppliers oferts
                             (:btn "Ответить заявкой на тендер"
                              :popup '(:caption           "Выберите ресурсы"
                                       :perm              (and :active :fair)
                                       :entity            resource
                                       :fields
                                       '((:btn "Участвовать в тендере" :act (create-offer)))))
                             (:btn "Отменить тендер"
                              :popup
                              '(:caption           "Действительно отменить?"
                                :perm               :owner
                                :entity             tender
                                :fields             '((:btn "Подтверждаю отмену" :act (cancel-tender)))))
                             ))))

    ;; Список ресурсов
    (:place                resources
     :url                  "/resource"
     :navpoint             "Ресурсы"
     :actions
     '((:caption           "Ресурсы"
        :perm              :all
        :entity            resource
        :val               (cons-hash-list *RESOURCE*)
        :fields            '(name category resource-type unit
                             (:btn "Страница ресурса"
                              :act "Страница ресурса"
                              ;; (hunchentoot:redirect
                              ;;  (format nil "/resource/~A" (get-btn-key (caar (form-data)))))
                              )))))

    ;; Страница ресурса
    (:place                resource
     :url                  "/resource/:id"
     :actions
     '((:caption           "Ресурс"
        :entity            resource
        :val               (gethash (parse-integer (caddr (request-list))) *RESOURCE*)
        :fields            '(name category resource-type unit suppliers))))
    ))
