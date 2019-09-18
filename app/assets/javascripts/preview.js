$(function() {
    $('#version_publish').on('confirm:complete', function(e, confirmed) {
        if (confirmed) {
            $('#preview_versions tbody td:nth-child(5)').html(
                '<tr>' +
                '<td colspan="5">' +
                '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> Publishing ' +
                '</td>' +
                '</tr>');
        }
    });
    $( "#preview_dialog" ).dialog({
        autoOpen: false,
        modal: true,
        width: "auto",
        hide: {
            effect: "explode",
            duration: 500
        }
    });

    $( "#preview_opener" ).on( "click", function() {
        $( "#preview_dialog" ).dialog( "open" );
    });
    $( "#version_build" ).on( "click", function() {
        $('#preview_dialog_div').html('<i class="fa fa-gear fa-spin" style="font-size:24px"></i> Generating new preview version ');
        $('.ui-dialog-titlebar-close').prop('disabled', true);
    });
});