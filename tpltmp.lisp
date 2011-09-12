
(defmacro gentpl (syms)
  `(progn
     (defpackage #:tpl
       (:use #:cl)
       (:export ,@(mapcar #'(lambda (x)
                              (intern (format nil "~A" x) :keyword))
                          syms)))
     ,@(loop :for sym :in syms :collect
          `(defun ,sym (&rest param)
             (format nil "~A" ,sym)))))


(PPRINT
 (macroexpand-1 '(gentpl (root loginform logoutform contentBlock navelt fld strview strupd selopt selres textupd pswdupd btn btnlin btncol popbtn frmobj frmtbl popup popuplogin col))))

(gentpl (root loginform logoutform contentBlock navelt fld strview strupd selopt selres textupd pswdupd btn btnlin btncol popbtn frmobj frmtbl popup popuplogin col))
