$( document ).on('turbolinks:load', function() {
  // Buy Blueprint Btn AJAX
  $('#blueprints').on('click', '.buy-blueprint-btn', function() {
    var loader = $(this).data('loader');
    var type = $(this).data('type');
    var button = $(this);
    
    if (loader && type) {
      $.post('blueprint/buy', {loader: loader, type: type}, function() {
        button.closest('.modal').modal('hide');
        refresh_player_info();
        setTimeout(function() {load_station_tab('#blueprints');}, 250);
      }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
    }
  });
  
  // Show modal Blueprint Btn AJAX
  $('#blueprints').on('click', '.blueprint-modal-btn', function() {
    var loader = $(this).data('loader');
    var type = $(this).data('type');
    var button = $(this);
    var html = $(this).html();
    
    if (loader && type) {
      loading_animation($(this));
      $.get('blueprint/modal', {loader: loader, type: type}, function(data) {
        $(data).appendTo('#blueprints').modal('show');
        button.html(html);
      }).fail(function(data) { if (data && data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(html); });
    }
  });
});