$(function(){
  $("#list").jqGrid({
    url:'/grid',
    datatype: 'xml',
    mtype: 'GET',
    colNames:['Inv No','Date', 'Amount','Tax','Total','Notes'],
    colModel :[
      {name:'invid',   index:'invid', width:55},
      {name:'invdate', index:'invdate', width:90},
      {name:'amount',  index:'amount', width:80, align:'right'},
      {name:'tax',     index:'tax', width:80, align:'right'},
      {name:'total',   index:'total', width:80, align:'right'},
      {name:'note',    index:'note', width:150, sortable:false}
    ],
    pager: '#pager',
    rowNum:10,
    rowList:[10,20,30],
    sortname: 'invid',
    sortorder: 'desc',
    viewrecords: true,
    gridview: true,
    caption: 'test'
  });
});


jQuery("#rowed2").jqGrid({
    url:'/rowed',
    datatype: "json",
    colNames:['Actions','Inv No','Date', 'Client', 'Amount','Tax','Total','Notes'],
    colModel:[
        {name:'act',index:'act', width:100,sortable:false},
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
    gridComplete: function(){
        var ids = jQuery("#rowed2").jqGrid('getDataIDs');
        for(var i=0;i<ids.length;i++){
            var cl = ids[i];
            be = "<input style='height:22px;width:20px;' type='button' value='E' onclick=\"jQuery('#rowed2').jqGrid('editRow','"+cl+"');\"  />";
            se = "<input style='height:22px;width:20px;' type='button' value='S' onclick=\"jQuery('#rowed2').jqGrid('saveRow','"+cl+"');\"  />";
            ce = "<input style='height:22px;width:20px;' type='button' value='C' onclick=\"jQuery('#rowed2').jqGrid('restoreRow','"+cl+"');\" />";
            my = "<input style='height:22px;width:30px;' type='button' value='my' onclick=\"location.href='http://ya.ru';\" />";
            jQuery("#rowed2").jqGrid('setRowData',ids[i],{act:be+se+ce+my});
        }
    },
    editurl: "/rowed",
    caption:"Custom edit "
});
jQuery("#rowed2").jqGrid('navGrid',"#prowed2",{edit:false,add:false,del:false});



function ShowHide(id)
{
  if (document.getElementById(id).style.display == 'none') {
    document.getElementById(id).style.display = 'block';
  } else {
    document.getElementById(id).style.display = 'none';
  }
  return false;
}
