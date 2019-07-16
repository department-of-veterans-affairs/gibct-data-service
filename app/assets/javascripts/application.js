// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap.min
//= require_tree .

$(function() {
  $('#version_build').on('confirm:complete', (e) => {
    $('#preview_versions tbody').html(
      '<tr>' +
        '<td colspan="5" class="generating">' +
          '<i class="fa fa-gear fa-spin" style="font-size:24px"></i>  Generating new preview version ' +
        '</td>' +
      '</tr>');
  });
});