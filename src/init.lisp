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


;; 0 - admin
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'ADMIN
                     :login "admin"
                     :password "admin"))

;; 1 - expert1
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'EXPERT
                     :name "Эксперт-1"
                     :login "exp1"
                     :password "exp1"))

;; 2 - expert2
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'EXPERT
                     :name "Эксперт-2"
                     :login "exp2"
                     :password "exp2"))

;; 3 - supplier1
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :fair
                     :name "Поставщик-1"
                     :login "supp1"
                     :password "supp1"))

;; 4 - supplier2
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :unfair
                     :name "Поставщик-2"
                     :login "supp2"
                     :password "supp2"))

;; 5 - supplier3
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'SUPPLIER
                     :status :request
                     :name "Поставщик-3"
                     :login "supp3"
                     :password "supp3"))

;; 6 - builder1
(setf (gethash (hash-table-count *USER*) *USER*)
      (make-instance 'BUILDER
                     :name "Застройщик-1"
                     :login "builder1"
                     :password "builder1"))


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

