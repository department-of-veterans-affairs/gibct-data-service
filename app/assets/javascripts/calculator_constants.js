$(function() {
    $(':input[type="number"]').each( function () {
        //FISCALYEAR is the only non-dollar amount field
        let field_id = $(this).attr("id");
        if (field_id === "FISCALYEAR") {
            $(this).val(parseFloat($(this).val()).toFixed(0));
            $(this).change(function() {
                $(this).val(parseFloat($(this).val()).toFixed(0));
            });
        } else {
            $(this).val(parseFloat($(this).val()).toFixed(2));
            $(this).change(function() {
                if (!$(this).val()) {
                    $(this).val(0);
                }
                $(this).val(parseFloat($(this).val()).toFixed(2));
            });
        }
    });

    $('.constant_btn').on('click', function () {
        $('.constant_btn').each(function () {
            $(this).css('color', '#555');
            $(this).css('background-color', 'white');
        });
        $('.constant-form').each(function () {
           $(this).hide();
        });
        $(this).css('background-color', '#007bff');
        $(this).css('color', 'white');
        var formToShow = $(this).val();
        $("#"+formToShow).show();


    });




});