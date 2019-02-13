$( document ).on('turbolinks:load', function() {
  
  // Load Tab
  if (window.location.pathname == "/station") {
    if ($('.station-card a.nav-link.active').data('target') == '#overview') {
      load_station_tab($('.station-card a.nav-link.active').data('target')); 
    }
  }
  
  // Cookie Setter and Lazy Load
  $('.station-card a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
    Cookies.set('station_tab', $(this).data('target'));
    
    // Lazy Load
    $('.station-card a[data-toggle="pill"]').each(function() {
      $($(this).data('target')).empty();
    });
    load_station_tab($(this).data('target'));
  });
  
  // Reload storage on active ship if active
  $('.station-card').on('shown.bs.tab', 'a[data-target="#ship-inventory"]', function (e) {
    load_station_tab("#active_ship"); 
  });
  
  // Send dockrequest AJAX
  $('#app-container').on('click', '.station-dock-btn', function(e) {
    e.preventDefault();
    var html = $(this).html();
    var button = $(this);
    loading_animation($(this))
    
    $.post("/stations/dock", function(data) {
      Turbolinks.visit("/station");  
    }).error(function(data) { $.notify(data.responseJSON.error_message, {style: 'alert'}); button.html(html); });
  });
  
  // Send undockrequest AJAX
  $('#app-container').on('click', '.station-undock-btn', function(e) {
    e.preventDefault();
    var html = $(this).html();
    var button = $(this);
    loading_animation($(this))
    
    $.post("/stations/undock", function(data) {
      Turbolinks.visit("/game");  
    }).error(function(data) { $.notify(data.responseJSON.error_message, {style: 'alert'}); button.html(html); });
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
    var button = $(this)
    
    if (id) {
      $.post("/ship/activate", {id: id}, function() {
        load_station_tab("#my_ships");
      }); 
    }
  });
  
  // Pay insurance for ship AJAX
  $('#app-container').on('click', '.insure-ship-btn', function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    var button = $(this)
    
    if (id) {
      $.post("/ship/insure", {id: id}, function() {
        refresh_player_info();
        button.closest('.modal').modal('hide');
        setTimeout(function() {load_station_tab("#my_ships");}, 250);
      }); 
    }
  }).error(function(data) { $.notify(data.responseJSON.error_message, {style: 'alert'}); });
  
  // Store items from ship on station
  $('.station-card').on('click', '.store-btn', function(e) {
    $('#store-modal').find('.item-name').text($(this).parent().parent().find('.item-name').html());
    $('#store-modal').find('.store-confirm-btn').data("loader", $(this).data("loader"));
    $('#store-modal').find('.max-btn').data("amount", $(this).data("amount"));
    $("#store-modal").modal("show");
  });
  
  // Store all from ship on station AJAX
  $('.station-card').on('click', '.store-all-btn', function(e) {
    var button = $(this)
    
    var jqxhr = $.post("/stations/store", {loader: $(this).data('loader'), amount: $(this).data('amount')}, function() {
      button.tooltip('dispose');
      
      if (button.closest('tbody').find('tr').length == 1) {
        button.closest('table').replaceWith("<h2 class='text-center'>...</h2>")
      } else {
        button.parent().parent().remove();
      }
      
      refresh_player_info();
    });
  });
  
  // Store Max Button click
  $('.station-card').on('click', '#store-modal .max-btn', function(e) {
    e.preventDefault();
     $('#store-modal').find('input').val($(this).data("amount"));
  });
  
  // Store items from ship on station CONFIRM
  $('.station-card').on('click', '#store-modal .store-confirm-btn', function(e) {
    var button = $(this);
    
    var jqxhr = $.post("/stations/store", {loader: $(this).data('loader'), amount: $('#store-modal').find('input').val()}, function() {
      button.closest('.modal').modal('hide');
      refresh_player_info();
      setTimeout(function() {load_station_tab("#active_ship");}, 250);
    });
    jqxhr.error(function(data) {
      $('#store-modal').find('input').addClass("outline-danger");
     })
  });
  
  // Unred input on modal close
  $('.station-card').on('hidden.bs.modal', '#store-modal', function () {
    $('#store-modal').find('input').removeClass("outline-danger");
  })
  
  // Load items from station to ship
  $('.station-card').on('click', '.load-btn', function(e) {
    $('#load-modal').find('.item-name').text($(this).parent().parent().find('.item-name').html());
    $('#load-modal').find('.load-confirm-btn').data("loader", $(this).data("loader"));
    $('#load-modal').find('.max-btn').data("amount", $(this).data("amount"));
    $("#load-modal").modal("show");
  });
  
  // Load all from station to ship AJAX
  $('.station-card').on('click', '.load-all-btn', function(e) {
    var button = $(this)
    
    var jqxhr = $.post("/stations/load", {loader: $(this).data('loader')}, function(data) {
      button.tooltip('dispose');
      
      if (data.amount) {
        button.closest('tr').find('td:first-child').html(data.amount + "x");
        button.closest('td').children('.btn').each(function() { $(this).data('amount', data.amount); });
      } else {
        if (button.closest('tbody').find('tr').length == 1) {
          button.closest('table').replaceWith("<h2 class='text-center'>...</h2>")
        } else {
          button.parent().parent().remove();
        }
      }
      
      refresh_player_info();
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Load Max Button click
  $('.station-card').on('click', '#load-modal .max-btn', function(e) {
    e.preventDefault();
     $('#load-modal').find('input').val($(this).data("amount"));
  });
  
  // Load items from station to ship CONFIRM
  $('.station-card').on('click', '#load-modal .load-confirm-btn', function(e) {
    var button = $(this);
    
    var jqxhr = $.post("/stations/load", {loader: $(this).data('loader'), amount: $('#load-modal').find('input').val()}, function() {
      button.closest('.modal').modal('hide');
      refresh_player_info();
      setTimeout(function() {load_station_tab("#storage");}, 250);
    });
    jqxhr.error(function(data) {
      $('#load-modal').find('input').addClass("outline-danger");
      $('#load-modal').find('span.text-center.color-red').remove();
      $('#load-modal').find('.input-group').after("<span class='text-center color-red'>"+data.responseJSON.error_message+"</span>");
     })
  });
  
  // Unred input on modal close
  $('.station-card').on('hidden.bs.modal', '#load-modal', function () {
    $('#load-modal').find('input').removeClass("outline-danger");
    $('#load-modal').find('span.color-red').remove();
  })
  
  // Cookie getter
  if ($('.station-card').length) {
    var type = Cookies.get('station_tab');
    if (type) {
      $('.station-card .nav-pills a').each(function() {
        if ($(this).data('target') == type) { 
          $(this).tab('show'); 
          load_station_tab($('.station-card a.nav-link.active').data('target'));
        }
      });
    }
  }
  
  // Craft Btn AJAX
  $('.station-card').on('click', '.craft-btn', function() {
    var button = $(this)
    var loader = $(this).data('loader')
    var amount = $(this).closest('.modal-footer').find('.crafting-amount').val();
    var type = $(this).data('type');
    var html = $(this).html();
    
    loading_animation($(this));
    $.post('factory/craft', {loader: loader, type: type, amount: amount}, function() {
      button.closest('.modal').modal('hide');
      setTimeout(function() {load_station_tab("#factory");}, 250);
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(html); });
  });
  
  // Show modal Crafting Btn AJAX
  $('#factory').on('click', '.factory-modal-btn', function() {
    var loader = $(this).data('loader');
    var type = $(this).data('type');
    var button = $(this);
    var html = $(this).html();
    
    if (loader && type) {
      loading_animation($(this));
      $.get('factory/modal', {loader: loader, type: type}, function(data) {
        $(data).appendTo('#factory').modal('show');
        button.html(html);
      }).error(function(data) { if (data && data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(html); });
    }
  });
});

function load_station_tab(href) {
  element = $(href);
  element.empty().append("<div class='text-center mt-5px'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
  $.get('?tab=' + href.substring(1), function(data) {
    element.empty().append(data);
    sort_equipment_card()
  });
}