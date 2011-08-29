 function(){
   var ids = jQuery("#@:id:@").jqGrid('getDataIDs');
   for(var i=0;i < ids.length;i++){
     var cl = ids[i];
     be = "<input style='height:22px;width:20px;' type='button' value='E' onclick=\"jQuery('#@:id:@').editRow('"+cl+"');\" />";
     se = "<input style='height:22px;width:20px;' type='button' value='S' onclick=\"jQuery('#@:id:@').saveRow('"+cl+"');\" />";
     ce = "<input style='height:22px;width:20px;' type='button' value='C' onclick=\"jQuery('#@:id:@').restoreRow('"+cl+"');\" />";
     jQuery("#@:id:@").jqGrid('setRowData',ids[i],{btns:be+se+ce});
   }
 }

