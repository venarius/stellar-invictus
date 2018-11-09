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
    var jqxhr = $.post("/stations/store", {loader: $(this).data('loader'), amount: $('#store-modal').find('input').val()}, function() {
      Cookies.set("station_tab", '#activeship');
      Turbolinks.visit("/station");
    });
    jqxhr.fail(function() {
      $('#store-modal').find('input').addClass("outline-danger");
     })
  });
  
  // Unred input on modal close
  $('#store-modal').on('hidden.bs.modal', function () {
    $('#store-modal').find('input').removeClass("outline-danger");
  })
  
  // Load items from station to ship
  $('.station-storage-table').on('click', '.load-btn', function(e) {
    $('#load-modal').find('.item-name').text($(this).parent().parent().find('.item-name').html());
    $('#load-modal').find('.load-confirm-btn').data("loader", $(this).data("loader"));
    $("#load-modal").modal("show");
  });
  
  // Load items from station to ship CONFIRM
  $('#load-modal').on('click', '.load-confirm-btn', function(e) {
    var jqxhr = $.post("/stations/load", {loader: $(this).data('loader'), amount: $('#load-modal').find('input').val()}, function() {
      Cookies.set("station_tab", '#storage');
      Turbolinks.visit("/station");
    });
    jqxhr.fail(function() {
      $('#load-modal').find('input').addClass("outline-danger");
     })
  });
  
  // Unred input on modal close
  $('#load-modal').on('hidden.bs.modal', function () {
    $('#load-modal').find('input').removeClass("outline-danger");
  })
  
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