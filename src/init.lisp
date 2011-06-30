(in-package #:wizard)

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

(defmacro push-hash (hash class &body init)
  `(setf (gethash (hash-table-count ,hash) ,hash)
        (make-instance ,class ,@init)))

;; USERS

;; ADMIN
(push-hash *USER* 'ADMIN :login "admin" :password "admin")
;; EXPERT
(loop :for i :from 1 :to 9 :do
   (push-hash *USER* 'EXPERT
     :name (format nil "Эксперт-~A" i)
     :login (format nil "exp~A" i)
     :password (format nil "exp~A" i)))
;; SUPPLIER
(loop :for i :from 0 :to 9 :do
   (push-hash *USER* 'SUPPLIER
     :status (nth (* 2 (random (floor (length *supplier-status*) 2)))
                  *supplier-status*)
     :name (format nil "Поставщик-~A" i)
     :login (format nil "supp~A" i)
     :password (format nil "supp~A" i)))
;; BUILDER
(loop :for i :from 0 :to 9 :do
   (push-hash *USER* 'BUILDER
     :name (format nil "Застройщик-~A" i)
     :login (format nil "buil~A" i)
     :password (format nil "buil~A" i)))

;; RESOURCES & CATEGORYES

(loop :for cat :in '("Строительные товары" "Крепеж" "Оснастка" "Инструменты") :do
   (let ((category (push-hash *CATEGORY* 'CATEGORY
                     :name cat
                     ;; :parent
                     ;; :child-categoryes
                     ;; :resources
                     )))
     (loop :for i :from 0 :to 9 :do
        (let ((resource (push-hash *RESOURCE* 'RESOURCE
                          :name (format nil "Ресурс-~A из ~A" i (a-name category))
                          :category category
                          :resource-type (nth (* 2 (random (floor (length *resource-type*) 2)))
                                              *resource-type*)
                          :unit "шт."
                          ;; :suppliers
                          )))
          (push resource (a-resources category))))))




;; Categoryes
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'ADMIN
                     :login "admin"
                     :password "admin"))







;; RESOURCES

(setf (gethash (hash-table-count *RESOURCE*) *RESOURCE*)
      (make-instance 'RESOURCE
                     :name "Блок бетонный"
                     :resource-type :matherial
                     :unit "шт"))

(setf (gethash (hash-table-count *RESOURCE*) *RESOURCE*)
      (make-instance 'RESOURCE
                     :name "Труба сантехническая"
                     :resource-type :material
                     :unit "шт"))

(setf (gethash (hash-table-count *RESOURCE*) *RESOURCE*)
      (make-instance 'RESOURCE
                     :name "Плита перекрытия"
                     :resource-type :material
                     :unit "шт"))

(setf (gethash (hash-table-count *RESOURCE*) *RESOURCE*)
      (make-instance 'RESOURCE
                     :name "Стеклопакет"
                     :resource-type :material
                     :unit "шт"))


;; 0 - supplier-resource-prcie for supplier1
(setf (gethash (hash-table-count *SUPPLIER-RESOURCE-PRICE*) *SUPPLIER-RESOURCE-PRICE*)
      (make-instance 'SUPPLIER-RESOURCE-PRICE
                     :owner (gethash 3 *USER*)
                     :resource  (make-instance 'RESOURCE
                                               :name "Стеклопакет"
                                               :resource-type :material
                                               :unit "шт")
                     :price 10000))

;; 1 - supplier-resource-prcie for supplier1
(setf (gethash (hash-table-count *SUPPLIER-RESOURCE-PRICE*) *SUPPLIER-RESOURCE-PRICE*)
      (make-instance 'SUPPLIER-RESOURCE-PRICE
                     :owner (gethash 3 *USER*)
                     :resource  (make-instance 'RESOURCE
                                               :name "Утеплитель"
                                               :resource-type :material
                                               :unit "шт")
                     :price 10000))


;; 2 - supplier-resource-prcie for supplier2
(setf (gethash (hash-table-count *SUPPLIER-RESOURCE-PRICE*) *SUPPLIER-RESOURCE-PRICE*)
      (make-instance 'SUPPLIER-RESOURCE-PRICE
                     :owner (gethash 4 *USER*)
                     :resource  (make-instance 'RESOURCE
                                               :name "Стеклопакет"
                                               :resource-type :material
                                               :unit "шт")
                     :price 10000))


;; tender 0 (builder 1)
(let* ((id (hash-table-count *TENDER*))
       (tender (make-instance 'TENDER
                              :name                "Первый тендер"
                              :status              :active
                              :owner               (gethash 6 *USER*)
                              :active-date         "15.12.2012"
                              :all                 "15.12.2012-21.01.2013"
                              :claim               "15.12.2012-21.01.2013"
                              :analize             "15.12.2012-21.01.2013"
                              :interview           "15.12.2012-21.01.2013"
                              :result              "15.12.2012-21.01.2013"
                              ;; :winner              ""
                              ;; :price               "Рекомендуемая стоимость"    (:num) ;; вычисляется автоматически на основании заявленных ресурсов
                              ;; :resources           "Ресурсы"                    (:list-of-links resource)
                              ;; :documents           "Документы"                  (:list-of-links document) ;; закачка и удаление файлов
                              ;; :suppliers           "Поставщики"                 (:list-of-links supplier) ;; строится по ресурсам автоматически
                              ;; :offerts             "Откликнувшиеся поставщики"  (:list-of-links supplier)
                              )))
  (setf (gethash (hash-table-count *TENDER*) *TENDER*)
        tender)
  (push tender (a-tenders (gethash 6 *USER*))))


;; dbg out
(maphash #'(lambda (k v)
             (print (list k v (a-login v) (a-password v))))
         *USER*)

(maphash #'(lambda (k v)
             (print (list k v (a-name v) (a-resources v))))
         *CATEGORY*)

(maphash #'(lambda (k v)
             (print (list k v (a-name v) (a-category v))))
         *RESOURCE*)


