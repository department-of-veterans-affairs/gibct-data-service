$(function() {
    formatInputFields = function (field) {
        let field_id = $(field).attr("id");
        if (field_id === "FISCALYEAR") {
            $(field).val(parseInt($(field).val()));
        } else {
            formatFloatInputToCurrency(field);
        }
    };

    const formatFloatInputToCurrency = function (field) {
        if (!$(field).val()) {
            $(field).val(0);
        }
        $(field).val(parseFloat($(field).val()).toFixed(2));
    };

    const calculator_constant_fields  = $(':input[type="number"]');

    calculator_constant_fields.each( function () {
        formatInputFields(this);
    });

    calculator_constant_fields.change( function () {
        formatInputFields(this);
    });

});