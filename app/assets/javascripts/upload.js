$(function() {
    $( "[id^=api_fetch_]" ).on( "click", function() {
      this.parentElement.parentElement.innerHTML = (
        '<td colspan="7" class="text-center">' +
        '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> Fetching ' +
        '</td>'
      );
    });
});
