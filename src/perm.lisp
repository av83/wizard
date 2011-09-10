(in-package #:WIZARD)


(defun auth (login password)
  (loop :for obj :being the :hash-values :in *USER* :using (hash-key key) :do
     (when (and (equal (a-login obj) login)
                (equal (a-password obj) password))
       (return-from auth
         (progn
           (setf (hunchentoot:session-value 'userid) key)
           (hunchentoot:redirect (hunchentoot:request-uri*))))))
  (hunchentoot:redirect (hunchentoot:request-uri*)))


(defun perm-check (perm subj obj)
  (cond ((consp    perm)
         (loop :for item :in perm :collect (perm-check item subj obj)))
        ((keywordp perm)
         (ecase perm
           (:all         t)   ;; "Все пользователи"
           (:nobody      nil) ;; "Никто"
           (:system      nil) ;; "Система (загрузка данных на старте и изменение статуса поставщиков, когда время добросовестности истеклл)"
           (:notlogged   nil) ;; "Незалогиненный пользователь (может зарегистрироваться как поставщик)"
           (:logged      nil) ;; "Залогиненный пользователь"
           (:admin       nil) ;; "Администратор"
           (:expert      nil) ;; "Незалогиненный пользователь"
           (:builder     nil) ;; "Пользователь-Застройщик"
           (:supplier    nil) ;; "Пользователь-Поставщик"
           ;; Objects
           (:fair        nil) ;; "Обьект является добросовестным поставщиком"
           (:unfair      nil) ;; "Объект является недобросовестным поставщиком"
           (:active      nil) ;; "Объект является активным тендером, т.е. время подачи заявок не истекло"
           (:unacitve    nil) ;; "Объект является неакивным тендером, т.е. время подачи заявок не наступило"
           (:fresh       nil) ;; "Объект является свежим тендером, т.е. недавно стал активным"
           (:stale       nil) ;; "Объект является тендером, который давно стал активным"
           (:finished    nil) ;; "Объект является завершенным тендером"
           (:cancelled   nil) ;; "Объект является отмененным тендером"
           ;; Mixed
           (:self        nil) ;; "Объект олицетворяет пользователя, который совершает над ним действие"
           (:owner       nil) ;; "Объект, над которым совершается действие имеет поле owner содержащее ссылку на объект текущего пользователя"
           ))
        (t perm)))

(defun check-perm (perm subj obj)
  "TODO: logging"
  (eval (perm-check perm subj obj))
  ;; t
  )

;; (perm-check '(or :admin (and :all :nobody)) 1 2)
;; (check-perm '(or :admin (or :all :nobody)) 1 2)
;; (check-perm ':nobody 1 2)
;; (perm-check ':nobody 1 2)
