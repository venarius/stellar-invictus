$( document ).on('turbolinks:load', function() {
  
  //  Plot Route Btn
  $('#app-container').on('click', '.plot-route-btn', function() {
    var id = $(this).data('id');
    var button = $(this);
    
    loading_animation(button);
    $.post('system/route', {id: id}, function(data) {
      reload_players_card();
      reload_locations_card();
      
      if (button.closest('.modal').length) {
        button.closest('.modal').modal('hide');
      }
    });
  });
  
});