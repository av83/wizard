;; Загрузчик системы
;; Не забыть скачать в текущую директорию quicklisp
;; $ curl -O http://beta.quicklisp.org/quicklisp.lisp
;; (load "quicklisp.lisp")
;; (quicklisp-quickstart:install)
;; (ql:quickload "restas-directory-publisher")

(load "lib.lisp")
(load "ent.lisp")
(load "gen.lisp")
(load "grid.lisp")
(load "fld.lisp")
(load "perm.lisp")
(load "defmodule.lisp")
(restas:start '#:wizard :port 8081)
(restas:debug-mode-on)


