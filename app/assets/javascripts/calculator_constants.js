$(function() {
    const CONSTANT_DESCRIPTIONS = {
        TFCAP:'TBD',
        BSCAP: 'TBD',
        BSOJTMONTH: 'TBD',
        FLTTFCAP: 'TBD',
        CORRESPONDTFCAP: 'TBD',
        MGIB3YRRATE: 'TBD',
        MGIB2YRRATE: 'TBD',
        SRRATE: 'TBD',
        DEARATEOJT: 'TBD',
        VRE0DEPRATE: 'TBD',
        VRE1DEPRATE: 'TBD',
        VRE2DEPRATE: 'TBD',
        VREINCRATE: 'TBD',
        VRE0DEPRATEOJT: 'TBD',
        VRE1DEPRATEOJT: 'TBD',
        VREINCRATEOJT: 'TBD',
        AVERETENTIONRATE: 'TBD',
        AVEGRADRATE: 'TBD',
        AVESALARY: 'TBD',
        AVEREPAYMENTRATE: 'TBD',
        AVGVABAH: "The National Average for the VA Housing Rate.",
        AVGDODBAH: "The National Average for the DOD Housing Rate.",
        DEARATEFULLTIME: "The Full Time Rate for the Dependents Educational Assistance (DEA) Benefit.",
        DEARATETHREEQUARTERS: "The Three Quarters Time Rate for the Dependents Educational Assistance (DEA) Benefit.",
        DEARATEONEHALF: "The Half Time Rate for the Dependents Educational Assistance (DEA) Benefit.",
        DEARATEUPTOONEHALF: "The Rate for One Quarter to Half Time for the Dependents Educational Assistance (DEA) Benefit",
        DEARATEUPTOONEQUARTER: "The Rate for up to Quarter Time for the Dependents Educational Assistance (DEA) Benefit.",
        FISCALYEAR: "The current Fiscal Year."
    };



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
        console.log(description);
        $(selector).append("<span class=\"fa fa-info-circle\"></span> " + description);
    });
});