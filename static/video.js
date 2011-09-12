$(document).ready(function()
{
    jQuery('.ytvideo').each(function()
    {
        var elem = jQuery(this);
        elem.html('<iframe width="320px" height="240px" src="' + elem.attr('id') + '"></iframe>');
    });

});