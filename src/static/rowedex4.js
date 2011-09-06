jQuery("#rowed2").jqGrid({
 url:'server.php?q=3',
 datatype: "json",
 colNames:['Actions','Inv No','Date', 'Client', 'Amount','Tax','Total','Notes'],
 colModel:[
  {name:'act',index:'act', width:75,sortable:false},
  {name:'id',index:'id', width:55},
  {name:'invdate',index:'invdate', width:90, editable:true},
  {name:'name',index:'name', width:100,editable:true},
  {name:'amount',index:'amount', width:80, align:"right",editable:true},
  {name:'tax',index:'tax', width:80, align:"right",editable:true},
  {name:'total',index:'total', width:80,align:"right",editable:true},
  {name:'note',index:'note', width:150, sortable:false,editable:true}
 ],
 rowNum:10,
 rowList:[10,20,30],
 pager: '#prowed2',
 sortname: 'id',
 viewrecords: true,
 sortorder: "desc",
 gridComplete:  function(){
  var ids = jQuery("#rowed2").jqGrid('getDataIDs');
  for(var i=0;i < ids.length;i++){
   var cl = ids[i];
   be = "<input style='height:22px;width:20px;' type='button' value='E' onclick=\"jQuery('#rowed2').editRow('"+cl+"');\" />";
   se = "<input style='height:22px;width:20px;' type='button' value='S' onclick=\"jQuery('#rowed2').saveRow('"+cl+"');\" />";
   ce = "<input style='height:22px;width:20px;' type='button' value='C' onclick=\"jQuery('#rowed2').restoreRow('"+cl+"');\" />";
   jQuery("#rowed2").jqGrid('setRowData',ids[i],{act:be+se+ce});
  }
 },
 editurl: "server.php",
 caption:"Custom edit " });
jQuery("#rowed2").jqGrid('navGrid',"#prowed2",{edit:false,add:false,del:false});


             ;; `(("be" . ,(format nil "\"<input type='button' value='E' onclick=\\\" jQuery('#~A').editRow('\"+cl+\"'); \\\" />\";" grid-id))
             ;;   ("se" . ,(format nil "\"<input type='button' value='S' onclick=\\\" jQuery('#~A').saveRow('\"+cl+\"'); \\\" />\";" grid-id))
             ;;   ("ce" . ,(format nil "\"<input type='button' value='C' onclick=\\\" jQuery('#~A').restoreRow('\"+cl+\"'); \\\" />\";" grid-id))))

                   ,(format nil "\"<input type='button' value='~A' onclick=\\\" jQuery('#~A').editRow('\"+cl+\"'); \\\" />\";"

(defun jqgen ()
  (format nil "<table id=\"rowed2\"></table><div id=\"prowed2\"></div><br />
               <script type=\"text/javascript\">
               jQuery('#~A').jqGrid(~A)~%~A
               </script>"
          "rowed2"
          (replace-all
           (json:encode-json-to-string
            '(("url"      . "/rowed")
              ("datatype" . "json")
              ("colNames" . ("Actions" "Inv No" "Date"  "Client" "Amount" "Tax" "Total" "Notes"))
              ("colModel" . ((("name" . "act")      ("index" . "act")       ("width" . "100")  ("sortable" . nil)  ("editable" . nil))
                             (("name" . "id")       ("index" . "id")        ("width" . "55")   ("sortable" . nil)  ("editable" . t))
                             (("name" . "invdate")  ("index" . "invdate")   ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "name")     ("index" . "name")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))
                             (("name" . "amount")   ("index" . "amount")    ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "tax")      ("index" . "tax")       ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "total")    ("index" . "total")     ("width" . "100")  ("sortable" . nil)  ("editable" . t) ("align" . "right"))
                             (("name" . "note")     ("index" . "note")      ("width" . "100")  ("sortable" . nil)  ("editable" . t))))
              ("rowNum"   . 10)
              ("rowList"  . (10 20 30))
              ("pager"    . "#prowed2")
              ("sortname" . "id")
              ("viewrecords" . t)
              ("sortorder" . "desc")
              ("gridComplete" . "-=|=-")
              ("editurl"  . "/rowed")
              ("caption" . "Testttttt")))
           "\"-=|=-\","
           (alexandria:read-file-into-string (path "src/static/rowedex3.js")))
          "jQuery('#rowed2').jqGrid('navGrid','#prowed2',{edit:false,add:false,del:false});"
          ))
