$( document ).on('turbolinks:load', function() {
  
  //  Plot Route Btn
  $('#app-container').on('click', '.plot-route-btn', function() {
    var id = $(this).data('id');
    
    $.post('system/route', {id: id}, function(data) {
      reload_players_card();
      reload_locations_card();
    });
  });
  
});