$( document ).on('turbolinks:load', function() {
  // Send dockrequest AJAX
  $('#app-container').on('click', '.station-dock-btn', function(e) {
    e.preventDefault();
    $.post("/stations/dock", function(data) {
      Turbolinks.visit("/station");  
    });
  });
  
  // Send undockrequest AJAX
  $('#app-container').on('click', '.station-undock-btn', function(e) {
    e.preventDefault();
    $.post("/stations/undock", function(data) {
      Turbolinks.visit("/game");  
    });
  });
  
  // Send buy ship request AJAX
  $('#app-container').on('click', '.buy-ship-btn', function(e) {
    e.preventDefault();
    var name = $(this).data("name");
    if (name && name != "") {
      $.post("/stations/buy", {type: 'ship', name: name}, function(data) {
        Cookies.set("station_tab", '#ships');
        Turbolinks.visit("/station");  
      }); 
    }
  });
  
  // Activate other ship AJAX
  $('#app-container').on('click', '.activate-ship-btn', function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    if (id) {
      $.post("/ship/activate", {id: id}, function() {
        Cookies.set("station_tab", '#myships');
        Turbolinks.visit("/station");
      }); 
    }
  });
  
  // Store items from ship on station
  $('.station-ship-inventory-table').on('click', '.store-btn', function(e) {
    $('#store-modal').find('.item-name').text($(this).parent().parent().find('.item-name').html());
    $('#store-modal').find('.store-confirm-btn').data("loader", $(this).data("loader"));
    $("#store-modal").modal("show");
  });
  
  // Store items from ship on station CONFIRM
  $('#store-modal').on('click', '.store-confirm-btn', function(e) {
    $.post("/stations/store", {loader: $(this).data('loader'), amount: $('#store-modal').find('input').val()}, function() {
      Cookies.set("station_tab", '#activeship');
      Turbolinks.visit("/station");
    });
  });
  
  // Cookie getter
  if ($('.station-card').length) {
    var type = Cookies.get('station_tab');
    if (type) {
      $('.station-card .nav-pills a').each(function() {
        if ($(this).attr('href') == type) { $(this).tab('show'); }
      });
    }
  }
});