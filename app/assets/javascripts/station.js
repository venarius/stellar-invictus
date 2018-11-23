$( document ).on('turbolinks:load', function() {
  
  // Cookie Setter
  $('.station-card a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
    Cookies.set('station_tab', $(this).attr("href"));
  });
  
  // Send dockrequest AJAX
  $('#app-container').on('click', '.station-dock-btn', function(e) {
    e.preventDefault();
    loading_animation($(this))
    $.post("/stations/dock", function(data) {
      Turbolinks.visit("/station");  
    }).error(function(data) { show_error(data.responseJSON.error_message); });
  });
  
  // Send undockrequest AJAX
  $('#app-container').on('click', '.station-undock-btn', function(e) {
    e.preventDefault();
    loading_animation($(this))
    $.post("/stations/undock", function(data) {
      Turbolinks.visit("/game");  
    }).error(function(data) { show_error(data.responseJSON.error_message); });
  });
  
  // Send buy ship request AJAX
  $('#app-container').on('click', '.buy-ship-btn', function(e) {
    e.preventDefault();
    var name = $(this).data("name");
    if (name && name != "") {
      $.post("/stations/buy", {type: 'ship', name: name}, function(data) {
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
        Turbolinks.visit("/station");
      }); 
    }
  });
  
  // Store items from ship on station
  $('.station-ship-inventory-table').on('click', '.store-btn', function(e) {
    $('#store-modal').find('.item-name').text($(this).parent().parent().find('.item-name').html());
    $('#store-modal').find('.store-confirm-btn').data("loader", $(this).data("loader"));
    $('#store-modal').find('.max-btn').data("amount", $(this).data("amount"));
    $("#store-modal").modal("show");
  });
  
  // Store Max Button click
  $('#store-modal').on('click', '.max-btn', function(e) {
    e.preventDefault();
     $('#store-modal').find('input').val($(this).data("amount"));
  });
  
  // Store items from ship on station CONFIRM
  $('#store-modal').on('click', '.store-confirm-btn', function(e) {
    var jqxhr = $.post("/stations/store", {loader: $(this).data('loader'), amount: $('#store-modal').find('input').val()}, function() {
      Turbolinks.visit("/station");
    });
    jqxhr.error(function(data) {
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
    $('#load-modal').find('.max-btn').data("amount", $(this).data("amount"));
    $("#load-modal").modal("show");
  });
  
  // Load Max Button click
  $('#load-modal').on('click', '.max-btn', function(e) {
    e.preventDefault();
     $('#load-modal').find('input').val($(this).data("amount"));
  });
  
  // Load items from station to ship CONFIRM
  $('#load-modal').on('click', '.load-confirm-btn', function(e) {
    var jqxhr = $.post("/stations/load", {loader: $(this).data('loader'), amount: $('#load-modal').find('input').val()}, function() {
      Turbolinks.visit("/station");
    });
    jqxhr.error(function(data) {
      $('#load-modal').find('input').addClass("outline-danger");
      $('#load-modal').find('.input-group').after("<span><small>"+data.responseJSON.error_message+"</small></span>");
     })
  });
  
  // Unred input on modal close
  $('#load-modal').on('hidden.bs.modal', function () {
    $('#load-modal').find('input').removeClass("outline-danger");
    $('#load-modal').find('span').remove();
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