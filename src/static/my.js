
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



function ShowHide(id)
{
  if (document.getElementById(id).style.display == 'none') {
    document.getElementById(id).style.display = 'block';
  } else {
    document.getElementById(id).style.display = 'none';
  }
  return false;
}
