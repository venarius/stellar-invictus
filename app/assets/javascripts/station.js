$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.station-dock-btn', function(e) {
    e.preventDefault();
    $.post("/stations/dock", function(data) {
      Turbolinks.visit("/station");  
    });
  });
  
  $('#app-container').on('click', '.station-undock-btn', function(e) {
    e.preventDefault();
    $.post("/stations/undock", function(data) {
      Turbolinks.visit("/game");  
    });
  });
  
  $('#app-container').on('click', '.buy-ship-btn', function(e) {
    e.preventDefault();
    var name = $(this).data("name");
    if (name && name != "") {
      $.post("/stations/buy", {type: 'ship', name: name}, function(data) {
        Turbolinks.visit("/station");  
      }); 
    }
  });
  
  $('#app-container').on('click', '.activate-ship-btn', function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    if (id) {
      $.post("/ships/activate", {id: id}, function(data) {
        if (data && $('#myships').length) {
          $('#myships').empty().append(data);
        }
      }); 
    }
  });
});