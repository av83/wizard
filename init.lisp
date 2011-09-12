(in-package #:wizard)

;;
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
                          :resource-type (nth (* 2 (random (floor (length *resource-types*) 2)))
                                              *resource-types*)
                          :unit "шт."
                          ;; :suppliers
                          )))
          (push resource (a-resources category))))))

;; ADMIN
(push-hash *USER* 'ADMIN :login "admin" :password "admin")

;; EXPERTS
(loop :for i :from 1 :to 9 :do
   (push-hash *USER* 'EXPERT
     :name (format nil "Эксперт-~A" i)
     :login (format nil "exp~A" i)
     :password (format nil "exp~A" i)))

;; BUILDERS
(loop :for i :from 0 :to 9 :do
   (push-hash *USER* 'BUILDER
     :name (format nil "Застройщик-~A" i)
     :login (format nil "buil~A" i)
     :password (format nil "buil~A" i)))

;; TENDERS
(let ((builders (mapcar #'cdr
                        (remove-if-not #'(lambda (x)
                                           (equal (type-of (cdr x)) 'BUILDER))
                                       (cons-hash-list *USER*)))))
  (loop :for builder :in builders :do
     (loop :for i :from 0 :to 5 :do
        (let ((tender (push-hash *TENDER* 'TENDER
                        :name        (format nil "Тендер-~A от ~A" i (a-name builder))
                        :status      (nth (* 2 (random (floor (length *supplier-status*) 2)))
                                          *tender-status*)
                        :owner       builder
                        ;; :active-date ;; Дата, когда тендер стал активным (первые сутки новые тендеры видят только добростовестные поставщики)
                        ;; :all                 "Срок проведения"
                        ;; :claim               "Срок подачи заявок"
                        ;; :analize             "Срок рассмотрения заявок"
                        ;; :interview           "Срок проведения интервью"
                        ;; :result              "Срок подведения итогов"
                        ;; :winner              "Победитель тендера"
                        ;; :price               "Рекомендуемая стоимость" ;; вычисляется автоматически на основании заявленных ресурсов
                        :resources   (let ((resource-count (hash-table-count *RESOURCE*))
                                           (all-resources  (cons-hash-list *RESOURCE*)))
                                       (remove-duplicates
                                        (loop :for r :from 0 :to (+ 3 (random 4)) :collect
                                           (cdr (nth (random resource-count) all-resources)))))
                        ;; :suppliers           "Поставщики"                 (:list-of-links supplier) ;; строится по ресурсам автоматически
                        ;; :offers              "Заявки"                     (:list-of-links supplier)
                        )))
          (setf (a-documents tender)
                (loop :for d :from 0 :to (+ 3 (random 4)) :collect
                   (let ((doc (push-hash *DOCUMENT* 'DOCUMENT
                                :name (format nil "Документ-~A из тендера ~A" d i)
                                :filename (format nil "~A-~A.doc" d i)
                                :tender tender)))
                     doc)))
          (push tender (a-tenders builder))))))


;; SUPPLIERS
(loop :for i :from 0 :to 9 :do
   (let ((supplier (push-hash *USER* 'SUPPLIER
                     :status (nth (* 2 (random (floor (length *supplier-status*) 2)))
                                  *supplier-status*)
                     :name (format nil "Поставщик-~A" i)
                     :login (format nil "supp~A" i)
                     :password (format nil "supp~A" i))))
     (setf (a-resources supplier)
           (let* ((all-resources   (cons-hash-list *RESOURCE*))
                  (sel-resources   (loop :for r :from 0 :to (+ 3 (random 4)) :collect
                                      (nth (random (length all-resources)) all-resources))))
             (loop :for cons-res :in sel-resources :collect
                (push-hash *SUPPLIER-RESOURCE-PRICE* 'SUPPLIER-RESOURCE-PRICE
                  :owner     supplier
                  :resource  (cdr cons-res)
                  :price     (random 1000)))))
     (setf (a-offers supplier)
           (let* ((all-tenders    (cons-hash-list *TENDER*))
                  (sel-tenders    (loop :for tnd :from 0 :to (+ 3 (random 4)) :collect
                                     (cdr (nth (random (length all-tenders)) all-tenders)))))
             (loop :for tender :in sel-tenders :collect
                (let ((offer (push-hash *OFFER* 'OFFER
                               :owner     supplier
                               :tender    tender)))
                  (setf (a-resources offer)
                        (let* ((tender-resources (a-resources tender))
                               (sel-tender-resources (loop :for tr :from 0 :to (random (length tender-resources)) :collect
                                                        (nth tr tender-resources))))
                          (loop :for sel-res :in sel-tender-resources :collect
                             (push-hash *OFFER-RESOURCE* 'OFFER-RESOURCE
                               :owner     supplier
                               :offer     offer
                               :resource  sel-res
                               :price     (random 1000)))))
                  (push offer (a-offers tender))
                  offer))))
     (setf (a-sales supplier)
           (let ((supp-resources (mapcar #'a-resource (a-resources supplier))))
             (loop :for sale :from 0 :to (random (length supp-resources)) :collect
                (push-hash *SALE* 'SALE
                  :name      (format nil "Распродажа-~A" sale)
                  :owner     supplier
                  :resource  (nth sale supp-resources)
                  :procent   (random 100)
                  :price     (random 1000)))))
     ))


;; (loop :for ten :in (cons-hash-list *TENDER*) :do
;;    (print
;;     (list (car ten) (a-offers (cdr ten)))))
;; (a-name (gethash 60 *tender*))
