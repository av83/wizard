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
(defparameter *resource-types*
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
      (addresses           "Адреса офисов и магазинов" (:list-of-str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (contact-person      "Контактное лицо"           (:str)
                           '(:view   (or :logged :fair)))                   ;; Гость не видит у недобросовестных
      (resources           "Поставляемые ресурсы"      (:list-of-links supplier-resource-price)
                           '(:add-resource :self   ;; создается связующий объект supplier-resource-price содержащий установленную поставщиком цену
                             :del-resource :self   ;; удаляется связующий объект
                             :change-price :self))
      (offers              "Посланные заявки на тендеры"  (:list-of-links offer)
                           '(:view :self
                             :update :self))  ;; offer - связующий объект
      (sales               "Распродажи"                (:list-of-links sale)))    ;; sale - связующий объект
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
     ((owner               "Поставщик ресурсов"         (:link supplier)
                           '(:update :nobody))
      (tender              "Тендер"                     (:link tender)
                           '(:update :nobody))
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
     ((owner               "Поставщик"                  (:link supplier)
                           '(:update :nobody))
      (offer               "Заявка"                     (:link offer)
                           '(:update :nobody))
      (resource            "Ресурс"                     (:link resource)
                           '(:update :nobody))
      (price               "Цена поставщика"            (:num)))
     :perm
     (:create :owner
      :delete :owner
      :view   :all
      :update (and :active :owner)))


    ;; Связующий объект: Распродажи - связывает поставщика, объявленный им ресурс и хранит условия скидки
    (:entity               sale
     :container            sale
     :fields
     ((name                "Распродажа"                 (:str)
                           '(:update :owner))
      (owner               "Поставщик"                  (:link supplier)
                           '(:update :admin))
      (resource            "Ресурс"                     (:link supplier-resource-price))
      (procent             "Процент скидки"             (:num))
      (price               "Цена со скидкой"            (:num))
      (notes               "Дополнительные условия"     (:list-of-str)))
     :perm
     (:create :supplier
      :delete :owner
      :view   :all
      :update :owner))


    ;; Связующий объект - ресурсы, заявленные поставщиком
    (:entity               supplier-resource-price
     :container            supplier-resource-price
     :fields
     ((owner               "Поставщик"                  (:link supplier)
                           '(:update :nobody))
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
                           '(:view   :all))
      (rating              "Рейтинг"                    (:num)
                           '(:update :system)))
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
                           '(:update :admin))
      ;; Дата, когда тендер стал активным (первые сутки новые тендеры видят только добростовестные поставщики)
      (active-date         "Дата активации"             (:date)
                           '(:update :system))
      (all                 "Срок проведения"            (:interval)
                           '(:view   :all
                             :update (or :admin  (and :owner :unactive))))
      (claim               "Срок подачи заявок"         (:interval)
                           '(:update (or :admin  (and :owner :unactive))))
      (analize             "Срок рассмотрения заявок"   (:interval)
                           '(:update (or :admin  (and :owner :unactive))))
      (interview           "Срок проведения интервью"   (:interval)
                           '(:update (or :admin  (and :owner :unactive))))
      (result              "Срок подведения итогов"     (:interval)
                           '(:update (or :admin (and :owner :unactive))))
      (winner              "Победитель тендера"         (:link supplier)
                           '(:view   :finished))
      (price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                           '(:update :system))
      (resources           "Ресурсы"                    (:list-of-links resource)
                           '(:update (and :owner :unactive)))
      (documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                           '(:update (and :owner :unactive)))
      (suppliers           "Поставщики"                 (:list-of-links supplier) ;; строится по ресурсам автоматически
                           '(:update :system))
      (offers              "Заявки"                     (:list-of-links offer)
                           '(:update :system)))
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

(defmacro cons-inner-objs (hash inner-lst)
  `(let ((inner-lst ,inner-lst)
         (cons-hash (cons-hash-list ,hash)))
      (loop :for obj :in inner-lst :collect
         (loop :for cons :in cons-hash :collect
            (when (equal (cdr cons) obj)
              (return cons))))))

(defmacro del-inner-obj (form-element hash inner-lst)
  `(let* ((key  (get-btn-key ,form-element))
          (hobj (gethash key ,hash)))
     (setf ,inner-lst
           (remove-if #'(lambda (x)
                          (equal x hobj))
                      ,inner-lst))
     (remhash key ,hash)
     (hunchentoot:redirect (hunchentoot:request-uri*))))

(defmacro with-obj-save (obj &rest flds)
  `(progn
     ,@(loop :for fld :in flds :collect
          `(setf (,(intern (format nil "A-~A" (symbol-name fld))) ,obj)
                 (cdr (assoc ,(symbol-name fld) (form-data) :test #'equal))))
     (hunchentoot:redirect (hunchentoot:request-uri*))))

(defmacro to (format-str form-elt)
  `(hunchentoot:redirect
    (format nil ,format-str (get-btn-key ,form-elt))))


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
    ;; Новости
    (:place                news
     :url                  "/news"
     :navpoint             "Новости"
     :actions
     '((:caption           "Новости"
        :perm              :all)))

    ;; Каталог ресурсов - категории
    (:place                catalog
     :url                  "/catalog"
     :navpoint             "Каталог ресурсов"
     :actions
     '((:caption           "Категории"
        :perm              :all
        :entity            category
        :val               (cons-hash-list *CATEGORY*)
        :fields            '(name ;; parent child-categoryes
                             (:btn "Показать ресурсы"
                              :act (to "/category/~A" (caar (form-data)))
                              :perm :all)))))

    ;; Каталог ресурсов - содержимое категории
    (:place                category
     :url                  "/category/:id"
     :actions
     '((:caption           "Категории"
        :perm              :all
        :entity            category
        :val               (cons-hash-list *CATEGORY*)
        :fields            '(name
                             ;; parent child-categoryes
                             (:btn "Показать ресурсы"
                              :act (to "/category/~A" (caar (form-data)))
                              :perm :all)))
       (:caption           "Ресурсы категории"
        :perm              :all
        :entity            resource
        :val               (remove-if-not #'(lambda (x)
                                              (equal (a-category (cdr x))
                                                     (gethash (cur-id) *CATEGORY*)))
                            (cons-hash-list *RESOURCE*))
        :fields            '(name resource-type unit
                             (:btn "Страница ресурса"
                              :act (to "/resource/~A" (caar (form-data)))
                              :perm :all)))))
    ;; Линейный список ресурсов
    (:place                resources
     :url                  "/resource"
     :navpoint             "Список ресурсов"
     :actions
     '((:caption           "Ресурсы"
        :perm              :all
        :grid              t
        :entity            resource
        :val               (cons-hash-list *RESOURCE*)
        :fields            '(name resource-type unit
                             (:btn "Страница категории"
                              :act (HUNCHENTOOT:REDIRECT
                                    (FORMAT NIL "/category/~A"
                                            (let ((etalon (a-category (gethash (GET-BTN-KEY (CAAR (form-data))) *RESOURCE*))))
                                              (car (find-if #'(lambda (category-cons)
                                                                (equal (cdr category-cons) etalon))
                                                            (cons-hash-list *CATEGORY*))))))
                              :perm :all)
                             (:btn "Страница ресурса"
                              :act (to "/resource/~A" (caar (form-data)))
                              :perm :all)))))
    ;; Страница ресурса (ресурсы редактированию не подвергаются)
    (:place                resource
     :url                  "/resource/:id"
     :actions
     '((:caption           "Ресурс"
        :perm              :all
        :entity            resource
        :val               (gethash (cur-id) *RESOURCE*)
        :fields            '(name category resource-type unit))))

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
                              :act (let ((obj (cur-user)))
                                     (with-obj-save obj
                                       LOGIN
                                       PASSWORD))
                              :perm :all)))
       (:caption           "Создать аккаунт эксперта"
        :perm              :admin
        :entity            expert
        :val               :clear
        :fields            '(login password name
                             (:btn "Создать новый аккаунт эксперта"
                              :act (progn
                                     (push-hash *USER* 'EXPERT
                                       :login (cdr (assoc "LOGIN" (form-data) :test #'equal))
                                       :password (cdr (assoc "PASSWORD" (form-data) :test #'equal))
                                       :name (cdr (assoc "NAME" (form-data) :test #'equal)))
                                     (hunchentoot:redirect (hunchentoot:request-uri*)))
                              :perm :all)))
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
                                                              :act (let ((key (get-btn-key (caar (form-data)))))
                                                                     (remhash key *USER*)
                                                                     (hunchentoot:redirect (hunchentoot:request-uri*))))))
                              :perm :all)
                             (:btn "Сменить пароль"
                              :popup '(:caption           "Смена пароля эксперта"
                                       :entity            expert
                                       :perm              :admin
                                       :fields            '(password
                                                            (:btn "Изменить пароль эксперта"
                                                             :act (let ((obj (gethash (get-btn-key (caar (last (form-data)))) *USER*)))
                                                                    (with-obj-save obj
                                                                      PASSWORD)))))
                              :perm :all)
                             (:btn "Страница эксперта"
                              :act (to "/expert/~A" (caar (form-data)))
                              :perm :all)))
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
                                                              :act (let ((key (get-btn-key (caar (form-data)))))
                                                                     (setf (a-status (gethash key *USER*)) :fair)
                                                                     (hunchentoot:redirect (hunchentoot:request-uri*))))))
                              :perm :all)))))

    ;; Список экспертов
    (:place                experts
     :url                  "/expert"
     :navpoint             "Эксперты"
     :actions
     '((:caption           "Эксперты"
        :grid              t
        :perm              :all
        :entity            expert
        :grid              t
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'EXPERT)) (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Страница эксперта"
                              :act (to "/expert/~A" (caar (form-data)))
                              :perm :all)
                             (:btn "Доп кнопка"
                              :act (to "/expert/~A" (caar (form-data)))
                              :perm :all)))))
    ;; Страница эксперта
    (:place                expert
     :url                  "/expert/:id"
     :actions
     '((:caption           "Эксперт"
        :perm              :all
        :entity            expert
        :val               (gethash (cur-id) *USER*)
        :fields            '(name))))

    ;; Список поставщиков
    (:place                suppliers
     :url                  "/supplier"
     :navpoint             "Поставщики"
     :actions
     '((:caption           "Организации-поставщики"
        :grid              t
        :perm              :all
        :entity            supplier
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'SUPPLIER))  (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn "Страница поставщика"
                              :act (to "/supplier/~A" (caar (form-data)))
                              :perm :all)))))
    ;; Страница поставщика
    (:place                supplier
     :url                  "/supplier/:id"
     :actions
     '((:caption           "Изменить себе пароль"
        :perm              :admin
        :entity            supplier
        :val               (cur-user)
        :fields            '(login password
                             (:btn "Изменить пароль"
                              :act (let ((obj (cur-user)))
                                     (with-obj-save obj
                                       LOGIN
                                       PASSWORD))
                              :perm :all)))
       (:caption           "Поставщик"
        :entity            supplier
        :val               (gethash (cur-id) *USER*)
        :fields            '(name status juridical-address actual-address contacts email site heads inn kpp ogrn
                             bank-name bik corresp-account client-account addresses contact-person
                             (:btn "Сохранить"
                              :act (let ((obj (gethash (cur-id) *USER*)))
                                     (with-obj-save obj
                                       NAME JURIDICAL-ADDRESS ACTUAL-ADDRESS CONTACTS EMAIL SITE HEADS INN KPP OGRN BANK-NAME
                                       BIK CORRESP-ACCOUNT CLIENT-ACCOUNT ADDRESSES CONTACT-PERSON)
                                     (hunchentoot:redirect (hunchentoot:request-uri*)))
                              :perm :all)
                             ;; resources
                             (:col               "Список поставляемых ресурсов"
                              :perm              222
                              :entity            supplier-resource-price
                              :val               (cons-inner-objs *SUPPLIER-RESOURCE-PRICE* (a-resources (gethash (cur-id) *USER*)))
                              :fields            '(resource price
                                                   (:btn "Удалить"
                                                    :popup '(:caption           "Удаление ресурса"
                                                             :perm              :admin
                                                             :entity            supplier-resource-price
                                                             :fields            '((:btn "Удалить ресурс"
                                                                                   :act (del-inner-obj
                                                                                         (caar (form-data))
                                                                                         *SUPPLIER-RESOURCE-PRICE*
                                                                                         (a-resources (gethash (cur-id) *USER*)))
                                                                                   :perm :all)))
                                                    :perm :all)))
                             (:btn "Добавить ресурс"
                              :popup '(:caption            "Добавление ресурса"
                                       :perm               111
                                       :entity             supplier-resource-price
                                       :fields             '((:btn "Добавить ресурс"
                                                              :act
                                                              (progn
                                                                (push-hash *SUPPLIER-RESOURCE-PRICE* 'SUPPLIER-RESOURCE-PRICE
                                                                  :owner (gethash (cur-user) *USER*)
                                                                  :resource (gethash
                                                                             (cdr (assoc "res" (form-data) :test #'equal))
                                                                             *RESOURCE*)
                                                                  :price (cdr (assoc "PRICE" (form-data) :test #'equal)))
                                                                (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                              :perm :all)))
                              :perm :all)
                              ;; offers
                             (:col               "Список заявок на тендеры"
                              :perm              222
                              :entity            offer
                              :val               (cons-inner-objs *OFFER* (a-offers (gethash (cur-id) *USER*)))
                              :fields            '(tender
                                                   (:btn "Страница заявки"
                                                    :act (to "/offer/~A" (caar (form-data)))
                                                    :perm :all)
                                                   (:btn "Удалить заявку"
                                                    :popup '(:caption           "Удаление заявки"
                                                             :perm              :admin
                                                             :entity            supplier-resource-price
                                                             :fields            '((:btn "Удалить заявку"
                                                                                   :act (del-inner-obj
                                                                                         (caar (form-data))
                                                                                         *OFFER*
                                                                                         (a-offers (gethash (cur-id) *USER*)))
                                                                                   :perm :all)))
                                                    :perm :all)))
                             ;; sale
                             (:col               "Список распродаж"
                              :perm              222
                              :entity            sale
                              :val               (cons-inner-objs *SALE* (a-sales (gethash (cur-id) *USER*)))
                              :fields            '(name
                                                   (:btn "Страница распродажи"
                                                    :act (to "/sale/~A"  (caar (form-data)))
                                                    :perm :all)
                                                   (:btn "Удалить распродажу"
                                                    :popup '(:caption           "Удаление распродажи"
                                                             :perm              :admin
                                                             :entity            supplier-resource-price
                                                             :fields            '((:btn "Удалить распродажу"
                                                                                   :act (del-inner-obj
                                                                                         (caar (form-data))
                                                                                         *SALE*
                                                                                         (a-sales (gethash (cur-id) *USER*)))
                                                                                   :perm :all)))
                                                    :perm :all)))
                             (:btn "Добавить распродажу"
                              :popup '(:caption            "Добавление расподажи"
                                       :perm               222
                                       :entity             sale
                                       :fields             '((:btn "Добавить распродажу"
                                                              :act (create-sale)
                                                              :perm :all)))
                              :perm :all)))
       (:caption           "Отправить заявку на добросовестность" ;; заявка на статус добросовестного поставщика (изменяет статус поставщика)
        :perm              (and :self :unfair)
        :entity            supplier
        :val               (gethash (cur-id) *USER*)
        :fields            '((:btn "Отправить заявку на добросовестность"
                              :act (progn
                                     (setf (a-status (gethash (cur-id) *USER*)) :request)
                                     (hunchentoot:redirect (hunchentoot:request-uri*)))
                              :perm :all)))))

    ;; Распродажи
    (:place                sales
     :url                  "/sale"
     :navpoint             "Распродажи"
     :actions
     '((:caption           "Распродажи"
        :grid              t
        :perm              :all
        :entity            sale
        :val               (cons-hash-list *SALE*)
        :fields            '(name
                             (:btn "Страница распродажи"
                              :act (to "/sale/~A" (caar (form-data)))
                              :perm :all)))))

    ;; Страница распродажи
    (:place                sale
     :url                  "/sale/:id"
     :actions
     '((:caption           "Распродажа"
        :entity            sale
        :val               (gethash (cur-id) *SALE*)
        :fields            '(name owner procent price notes
                             ;; resource
                             ;; (:col               "Список ресурсов распродажи"
                             ;;  :perm              111
                             ;;  :entity            supplier-resource-price
                             ;;  :val               (cons-inner-objs *SUPPLIER-RESOURCE-PRICE* (a-resource (gethash (cur-id) *SALE*)))
                             ;;  :fields            '(resource price
                             ;;                       (:btn "Удалить"
                             ;;                        :popup '(:caption           "Удаление ресурса"
                             ;;                                 :perm              :admin
                             ;;                                 :entity            supplier-resource-price
                             ;;                                 :fields            '((:btn "Удалить ресурс"
                             ;;                                                       :act
                             ;;                                                       (del-inner-obj
                             ;;                                                        (caar (form-data))
                             ;;                                                        *SUPPLIER-RESOURCE-PRICE*
                             ;;                                                        (a-resource (gethash (cur-id) *SALE*)))
                             ;;                                                       ))))))
                             ;; (:btn "Добавить ресурс"
                             ;;  :popup '(:caption            "Добавление ресурса"
                             ;;           :perm               111
                             ;;           :entity             supplier-resource-price
                             ;;           :fields             '((:btn "Добавить ресурс"
                             ;;                                  :act
                             ;;                                  (progn
                             ;;                                    (setf (gethash (hash-table-count *SUPPLIER-RESOURCE-PRICE*) *SUPPLIER-RESOURCE-PRICE*)
                             ;;                                          (make-instance 'SUPPLIER-RESOURCE-PRICE
                             ;;                                                         :owner (gethash 3 *USER*)
                             ;;                                                         :resource (gethash
                             ;;                                                                    (cdr (assoc "res" (form-data) :test #'equal))
                             ;;                                                                    *RESOURCE*)
                             ;;                                                         :price (cdr (assoc "PRICE" (form-data) :test #'equal))))
                             ;;                                    (hunchentoot:redirect (hunchentoot:request-uri*)))
                             ;;                                  ))))
                              (:btn "Сохранить"
                               :act (save-sale)
                               :perm :all)
                              (:btn "Удалить распродажу"
                               :act (delete-sale)
                               :perm :all)))))

    ;; Список застройщиков
    (:place                builders
     :url                  "/builder"
     :navpoint             "Застройщики"
     :actions
     '((:caption           "Организации-застройщики"
        :grid              t
        :perm              :all
        :entity            builder
        :val               (remove-if-not #'(lambda (x) (equal (type-of (cdr x)) 'BUILDER)) (cons-hash-list *USER*))
        :fields            '(name login
                             (:btn  "Страница застройщика"
                              :act  (to "/builder/~A" (caar (form-data)))
                              :perm :all)))))
    ;; Страница застройщика
    (:place                builder
     :url                  "/builder/:id"
     :actions
     '((:caption           "Застройщик"
        :entity            builder
        :val               (gethash (cur-id) *USER*)
        :fields            '(name juridical-address inn kpp ogrn bank-name bik corresp-account client-account rating
                             (:btn "Сохранить"
                              :act (let ((obj (gethash (cur-id) *USER*)))
                                     (with-obj-save obj
                                       NAME JURIDICAL-ADDRESS INN KPP OGRN BANK-NAME BIK CORRESP-ACCOUNT CLIENT-ACCOUNT RATING))
                              :perm :all)
                             ;; tenders
                             (:col              "Тендеры застройщика"
                              :perm             222
                              :entity           tender
                              :val              (cons-inner-objs *TENDER* (a-tenders (gethash 11 *USER*)))
                              :fields           '(name (:btn "Страница тендера"
                                                        :act (to "/tender/~A" (caar (last (form-data))))
                                                        :perm :all)))))
       (:caption           "Объявить новый тендер"
        :perm              :self
        :entity            tender
        :val               :clear
        :fields            '(name all claim analize interview result
                             (:btn "Объявить тендер (+)"
                              :act
                              ;; (format nil "~A" (form-data))
                              (let ((id (hash-table-count *TENDER*)))
                                     (setf (gethash id *TENDER*)
                                           (make-instance 'TENDER
                                                          :name      (cdr (ASSOC "NAME" (FORM-DATA) :test #'equal))
                                                          :status    :unactive
                                                          :owner     (gethash (cur-id) *USER*)
                                                          :all       (cdr (ASSOC "ALL" (FORM-DATA) :test #'equal))
                                                          :claim     (cdr (ASSOC "CLAIM" (FORM-DATA) :test #'equal))
                                                          :analize   (cdr (ASSOC "ANALIZE" (FORM-DATA) :test #'equal))
                                                          :interview (cdr (ASSOC "INTERVIEW" (FORM-DATA) :test #'equal))
                                                          :result    (cdr (ASSOC "RESULT" (FORM-DATA) :test #'equal))
                                                          ))
                                     (hunchentoot:redirect
                                      (format nil "/tender/~A" id)))
                              :perm :all
                              )))))

    ;; Список тендеров
    (:place                tenders
     :url                  "/tender"
     :navpoint             "Тендеры"
     :actions
     '((:caption           "Тендеры"
        :grid              t
        :perm              :all
        :entity            tender
        :val               (cons-hash-list *TENDER*)
        :fields            '(name status owner
                             (:btn "Страница тендера"
                              :act (to "/tender/~A" (caar (form-data)))
                              :perm :all)
                             ))))
    ;; Страница тендера (поставщик может откликнуться)
    (:place                tender
     :url                  "/tender/:id"
     :actions
     '((:caption           "Тендер"
        :entity            tender
        :val               (gethash (cur-id) *TENDER*)
        :fields            '(name status owner active-date all claim analize interview result ;; winner price
                             (:btn "Сохранить"
                              :act (let ((obj (gethash (cur-id) *TENDER*)))
                                     (with-obj-save obj
                                       name active-date all claim analize interview result))
                              :perm :all)
                             ;; resources
                             (:col              "Ресурсы тендера"
                              :perm             222
                              :entity           tender
                              :val              (cons-inner-objs *RESOURCE* (a-resources (gethash (cur-id) *TENDER*)))
                              :fields '(name
                                        (:btn   "Удалить из тендера"
                                         :act   (let ((etalon (gethash (get-btn-key (caar (last (form-data)))) *RESOURCE*)))
                                                  (setf (a-resources (gethash (cur-id) *TENDER*))
                                                        (remove-if #'(lambda (x)
                                                                       (equal x etalon))
                                                                   (a-resources (gethash (cur-id) *TENDER*))))
                                                  (hunchentoot:redirect (hunchentoot:request-uri*)))
                                         :perm  :all)
                                        (:btn   "Страница ресурса"
                                         :act   (to "/resource/~A" (caar (last (form-data))))
                                         :perm  :all)))
                             (:btn "Добавить ресурс"
                              :popup '(:caption           "Выберите ресурсы"
                                       :perm              (and :active :fair)
                                       :entity            resource
                                       :val               (cons-hash-list *RESOURCE*)
                                       :fields            '(
                                                            (:col "Выберите ресурс"
                                                             :perm 222
                                                             :entity resource
                                                             :val (cons-hash-list *RESOURCE*)
                                                             :fields '(name
                                                                       (:btn "Добавить ресурс"
                                                                        :act
                                                                        ;; (format nil "~A" (get-btn-key (caar (last (form-data)))))
                                                                        (progn
                                                                          (push
                                                                           (gethash (get-btn-key (caar (last (form-data)))) *RESOURCE*)
                                                                           (a-resources (gethash (cur-id) *TENDER*)))
                                                                          (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                                        ))
                                                             )))
                              :perm :all)


                             ;; documents
                             (:col              "Документы тендера"
                              :perm             111
                              :entity           tender
                              :val              (cons-inner-objs *DOCUMENT* (a-documents (gethash (cur-id) *TENDER*)))
                              :fields '(name
                                        (:btn   "Удалить из тендера"
                                         :act   (delete-doc-from-tender)
                                         :perm  :all)
                                        (:btn   "Страница документа"
                                         :act   (to "/document/~A" (caar (last (form-data))))
                                         :perm  :all)))
                             (:btn "Добавить документ"
                              :popup '(:caption           "Загрузите документ"
                                       :perm              (and :active :fair)
                                       :entity            resource
                                       :val               (cons-hash-list *RESOURCE*)
                                       :fields            '(
                                                            (:col "Выберите ресурс"
                                                             :perm 222
                                                             :entity resource
                                                             :val (cons-hash-list *RESOURCE*)
                                                             :fields '(name
                                                                       (:btn "Добавить ресурс"
                                                                        :act
                                                                        ;; (format nil "~A" (get-btn-key (caar (last (form-data)))))
                                                                        (progn
                                                                          (push
                                                                           (gethash (get-btn-key (caar (last (form-data)))) *RESOURCE*)
                                                                           (a-resources (gethash (cur-id) *TENDER*)))
                                                                          (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                                        ))
                                                             )))
                              :perm :all)



                             ;; suppliers
                             (:col              "Поставщики ресурсов"
                              :perm             111
                              :entity           tender
                              :val
                              ;; (remove-if-not #'(lambda (x)
                              ;;                                      (equal (type-of (cdr x))
                              ;;                                             'SUPPLIER))
                              ;;                    (cons-hash-list *USER*))
                              (let ((tender-resources   (a-resources (gethash (cur-id) *TENDER*)))
                                                      (all-suppliers      (remove-if-not #'(lambda (x)
                                                                                             (equal (type-of (cdr x))
                                                                                                    'SUPPLIER))
                                                                                         (cons-hash-list *USER*)))
                                                      (supplier-resource  (mapcar #'(lambda (x)
                                                                                      (cons (a-resource (cdr x))
                                                                                            (a-owner (cdr x))))
                                                                                  (cons-hash-list *SUPPLIER-RESOURCE-PRICE*)))
                                                      (result)
                                                      (rs))
                                                  (loop :for tr :in tender-resources :do
                                                     (loop :for sr :in supplier-resource :do
                                                        (when (equal tr (car sr))
                                                          (push (cdr sr) result))))
                                                  (setf result (remove-duplicates result))
                                                  (loop :for rd :in result :do
                                                     (loop :for as :in all-suppliers :do
                                                        (if (equal rd (cdr as))
                                                            (push as rs))
                                                        ))
                                                  rs)
                              :fields '(name
                                        (:btn "Отправить приглашение"
                                         :act (delete-from-tender)
                                         :perm :all)
                                        (:btn "Страница поставщика"
                                         :act (to "/supplier/~A"  (caar (last (form-data))))
                                         :perm :all)))
                             (:btn "Добавить своего поставщика"
                              :act (add-document-to-tender)
                              :perm :all)
                             ;; oferts
                             (:col              "Заявки на тендер"
                              :perm             111
                              :entity           offer
                              :val              (cons-inner-objs *OFFER* (a-offers (gethash (cur-id) *TENDER*)))
                              :fields '((:btn "Страница заявки"
                                         :act (to "/offer/~A"  (caar (last (form-data))))
                                         :perm :all)))
                             ;;
                             (:btn "Ответить заявкой на тендер"
                              :popup '(:caption           "Выберите ресурсы"
                                       :perm              (and :active :fair)
                                       :entity            resource
                                       :fields            '((:btn "Участвовать в тендере"
                                                             :act
                                                             (let* ((id    (hash-table-count *OFFER*))
                                                                    (offer (setf (gethash id *OFFER*)
                                                                                 (make-instance 'OFFER
                                                                                                :owner (cur-user)
                                                                                                :tender (gethash (cur-id) *TENDER*)))))
                                                               (push offer (a-offers (gethash (cur-id) *TENDER*)))
                                                               (hunchentoot:redirect (format nil "/offer/~A" id))))
                                                            :perm :all)))
                             ;;
                             (:btn "Отменить тендер"
                              :popup '(:caption           "Действительно отменить?"
                                       :perm               :owner
                                       :entity             tender
                                       :fields             '((:btn "Подтверждаю отмену"
                                                              :act (hunchentoot:redirect (format nil "/tender"))
                                                              :perm :all)))
                              :perm  :all)
                             ))))

    ;; Заявки на тендер
    (:place                offers
     :url                  "/offers"
     :navpoint             "Заявки на участие в тендере"
     :actions
     '((:caption           "Заявки на участие в тендере"
        :grid              t
        :perm              :all
        :entity            offer
        :val               (cons-hash-list *OFFER*)
        :fields            '(owner tender
                             (:btn "Страница заявки"
                              :act (to "/offer/~A" (caar (form-data)))
                              :perm :all)))))

    ;; Страница заявки на тендер
    (:place                offer
     :url                  "/offer/:id"
     :actions
     '((:caption           "Заявка на тендер"
        :entity            offer
        :val               (gethash (cur-id) *OFFER*)
        :fields            '(tender
                             ;; resources
                             (:col              "Ресурсы оферты"
                              :perm             111
                              :entity           offer-resource
                              :val              (cons-inner-objs *OFFER-RESOURCE* (a-resources (gethash (cur-id) *OFFER*)))
                              :fields '(resource price
                                        (:btn   "Удалить из оферты"
                                         :act   (del-inner-obj
                                                 (caar (last (form-data)))
                                                 *OFFER-RESOURCE*
                                                 (a-resources (gethash (cur-id) *OFFER*)))
                                         :perm  :all)
                                         ;; (let* ((id (get-btn-key (caar (last (form-data)))))
                                         ;;               (etalon (gethash id *OFFER-RESOURCE*)))
                                         ;;          (setf (a-resources (gethash (cur-id) *OFFER*))
                                         ;;                (remove-if #'(lambda (x)
                                         ;;                               (equal etalon x))
                                         ;;                           (a-resources (gethash (cur-id) *OFFER*)))

                                        (:btn   "Страница ресурса"
                                         :act   (to "/resource/~A" (caar (last (form-data))))
                                         :perm  :all)))
                             (:btn "Добавить ресурс"
                              :popup '(:caption           "Выберите ресурсы"
                                       :perm              (and :active :fair)
                                       :entity            resource
                                       :val               (cons-hash-list *RESOURCE*)
                                       :fields            '(
                                                            (:col "Выберите ресурс"
                                                             :perm 222
                                                             :entity resource
                                                             :val (cons-hash-list *RESOURCE*)
                                                             :fields '(name
                                                                       (:btn "Добавить ресурс"
                                                                        :popup '(:caption "Укажите цену"
                                                                                 :perm    1111
                                                                                 :entity  resource
                                                                                 :val     :clear
                                                                                 :fields  '((:calc "<input type=\"text\" name=\"INPRICE\" />")
                                                                                            (:btn "Задать цену"
                                                                                             :act
                                                                                             (let ((res-id (get-btn-key(caar (last (form-data)))))
                                                                                                   (in (cdr (assoc "INPRICE" (form-data) :test #'equal)))
                                                                                                   (id (hash-table-count *OFFER-RESOURCE*)))
                                                                                               (push
                                                                                                (setf (gethash id *OFFER-RESOURCE*)
                                                                                                      (make-instance 'OFFER-RESOURCE
                                                                                                                     :owner (cur-user)
                                                                                                                     :offer (gethash (cur-id) *OFFER*)
                                                                                                                     :resource (gethash res-id *RESOURCE*)
                                                                                                                     :price in))
                                                                                                (a-resources (gethash (cur-id) *OFFER*)))
                                                                                               (hunchentoot:redirect (hunchentoot:request-uri*)))
                                                                                             :perm :all
                                                                                             )))
                                                                        :perm :all)))))
                              :perm :all)))))

    ;; Рейтинг компаний
    (:place                rating
     :url                  "/rating"
     :navpoint             "Рейтинг компаний"
     :actions
     '((:caption           "Рейтинг компаний"
        :perm              :all)))


    ;; Календарь событий
    (:place                calendar
     :url                  "/calender"
     :navpoint             "Календарь событий"
     :actions
     '((:caption           "Календарь событий"
        :perm              :all)))

    ;; Ссылки
    (:place                links
     :url                  "/links"
     :navpoint             "Ссылки"
     :actions
     '((:caption           "Ссылки"
        :perm              :all)))

    ;; О портале
    (:place                about
     :url                  "/about"
     :navpoint             "О портале"
     :actions
     '((:caption           "О портале"
        :perm              :all)))

    ;; Контакты
    (:place                contacts
     :url                  "/contacts"
     :navpoint             "Контакты"
     :actions
     '((:caption           "Контакты"
        :perm              :all)))

    ))
