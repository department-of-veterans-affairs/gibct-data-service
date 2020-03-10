$(function() {
    const formatFloatInputToCurrency = function (field) {
        $(field).val(parseFloat($(field).val()).toFixed(2));
    };

    const floatInputOnChange = function (field) {
        if (!$(field).val()) {
            $(field).val(0);
        }
        formatFloatInputToCurrency(field);
    };

    const calculator_constant_fields  = $(':input[type="number"]');

    calculator_constant_fields.each( function () {
        let field_id = $(this).attr("id");
        if (field_id === "FISCALYEAR") {
            $(this).val(parseInt($(this).val()));
        } else {
            formatFloatInputToCurrency(this);
        }
    });

    calculator_constant_fields.change( function () {
        let field_id = $(this).attr("id");
        if (field_id === "FISCALYEAR") {
            $(this).val(parseInt($(this).val()));
        } else {
            floatInputOnChange(this)
        }
        $("#submit-button").prop("disabled", false);
    });

});