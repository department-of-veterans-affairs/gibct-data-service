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
        let selector = "#"+ field_id + "-description";
        let description = CONSTANT_DESCRIPTIONS[field_id];
        $(selector).append("<span class=\"fa fa-info-circle\"></span> " + description);
    });
});