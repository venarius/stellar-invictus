$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.station-dock-btn', function(e) {
    e.preventDefault();
    $.get("/stations/dock", function(data) {
      Turbolinks.visit("/station");  
    });
  });
  
  $('#app-container').on('click', '.station-undock-btn', function(e) {
    e.preventDefault();
    $.get("/stations/undock", function(data) {
      Turbolinks.visit("/game");  
    });
  });
});