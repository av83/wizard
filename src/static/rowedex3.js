
function(){
      var ids = jQuery("#rowed2").jqGrid('getDataIDs');
      for(var i=0; i < ids.length;i++) {
        var cl = ids[i];
        be = "<input style='height:22px;width:20px;' type='button' value='E' onclick=\"jQuery('#rowed2').jqGrid('editRow','"+cl+"');\"  />";
        se = "<input style='height:22px;width:20px;' type='button' value='S' onclick=\"jQuery('#rowed2').jqGrid('saveRow','"+cl+"');\"  />";
        ce = "<input style='height:22px;width:20px;' type='button' value='C' onclick=\"jQuery('#rowed2').jqGrid('restoreRow','"+cl+"');\" />";
        my = "<input style='height:22px;width:30px;' type='button' value='my' onclick=\"location.href='http://ya.ru';\" />";
        jQuery("#rowed2").jqGrid('setRowData',ids[i],{act:be+se+ce+my});
      }
    },
