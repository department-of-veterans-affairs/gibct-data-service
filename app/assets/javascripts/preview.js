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
        resizable: false,
        close: function( event, ui ) {
            $('#preview_opener').prop('disabled', true);
            $('#preview_versions tbody').html(
                '<tr>' +
                '<td style="text-align: center; " colspan="5">' +
                '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> Generating new preview version ' +
                '</td>' +
                '</tr>');
        }
    });

    $( "#preview_opener" ).on( "click", function() {
        $( "#preview_dialog" ).dialog( "open" );
    });
    $( "#version_build" ).on( "click", function() {
        $('#preview_dialog').dialog( "close" );
    });
});