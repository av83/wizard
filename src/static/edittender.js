    function EditField(ctlInput)
    {
        var theEditURL = $('#editurl').val();
        theEditURL += '&tenderid=' + $('#tenderid').val();
        theEditURL += '&field=' + ctlInput.id;
        theEditURL += '&value=' + ctlInput.value;

        // Через AJAX редкатируем тендер
        $.ajax(
        {
            async: false,
            url:theEditURL,
            success: function(data) {if (fieldName=='name') $('#tendercaption').html(data);}
        });
    }

    $(function()
    {
        var clsFormat = {
                            dateFormat: 'dd-mm-yy',
                            dayNamesMin: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
                            monthNames: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь']
                        };
        $('.editdatefield').datepicker(clsFormat);

        $('.editfield').change(function(){EditField(this);});
        $('.editfield').blur(function(){EditField(this);});
        $('.editdatefield').change(function(){EditField(this);});
        //$('.editdatefield').blur(function(){EditField(this);});
    });
