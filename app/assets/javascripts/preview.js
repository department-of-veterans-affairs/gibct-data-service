var generatingPreviewIcon = '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> Generating new preview version ';

$(function() {
    $('#version_build').on('confirm:complete', function(e, confirmed) {
        if (confirmed) {
            $('#preview_versions tbody').html('<tr>' +
                '<td colspan="5">' +
                generatingPreviewIcon +
                '</td>' +
                '</tr>');
        }
    });

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
        resizable: false,
        draggable: false,
        hide: {
            effect: "explode",
            duration: 1000
        }
    });

    $( "#preview_opener" ).on( "click", function() {
        $( "#preview_dialog" ).dialog( "open" );
    });
    $( "#version_build" ).on( "click", function() {
        $('#preview_dialog_div').html(generatingPreviewIcon);
        $('.ui-dialog-titlebar-close').prop('disabled', true);
    });
});