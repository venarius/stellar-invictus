$( document ).on('turbolinks:load', function() {
  // Listing Btn Click AJAX
  $('.station-card').on('click', '.market-loader-btn', function(e) {
    e.preventDefault();
    var loader = $(this).data('loader');
    
    $('.results').empty().append("<br><div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>");
    if (loader) {
      $.get('market/list?loader=' + loader, function(data) {
        $('.results').empty().append(data);
      });
    }
  });
  
  // Searching AJAX
  $('.station-card').on('click', '#market-search-btn', function(e) {
    e.preventDefault();
    var query = $('#market-search-input').val()
    
    if (query) {
      $('#market-search-input').val("");
      $('.results').empty().append("<br><div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>");
      $.get('market/search?search=' + query, function(data) {
        $('.results').empty().append(data);
      });
    }
  });
  
  // Get Own Listings AJAX
  $('.station-card').on('click', '.get-own-listings-btn', function(e) {
    e.preventDefault();
    $('.results').empty().append("<br><div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>");
    $.get('market/my_listings', function(data) {
      $('.results').empty().append(data);
    });
  });
  
  // Delete Listing AJAX
  $('.station-card').on('click', '.delete-market-listing-btn', function() {
    var id = $(this).data('id');
    var button = $(this);
    
    if (id) {
     $.post('/market/delete_listing', {id: id}, function() {
       button.closest('tr').remove();
     }); 
    }
  });
  
  // Market Buy AJAX
  $('.station-card').on('click', '.market-buy-btn', function(e) {
    var id = $(this).data('id');
    var button = $(this);
    var amount = $(this).closest('.modal').find('.market-buy-input').val();
    var html = button.html();

    loading_animation(button);
    $.post('market/buy', {id: id, amount: amount}, function(data) {
      button.closest('.modal').modal('hide');
      if (data.new_amount && data.new_amount != 0) {
        $(".station-card").find(`[data-target='#`+button.closest('.modal').attr('id')+`']`).parent().parent().children().first().text(data.new_amount + "×");
      } else {
        $(".station-card").find(`[data-target='#`+button.closest('.modal').attr('id')+`']`).parent().parent().remove();
      }
      refresh_player_info();
    }).error(function(data) {
      button.html(html);
      if (!button.closest('.modal').find('.error').length) {
        button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
        setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 1000) 
      }
    });
  });
  
  // Market Buy
  $('.station-card').on('click', '.max-buy-btn', function(e) {
    var amount = parseInt($(this).data('amount'));
    var price = parseInt($(this).data('price'));
    
    $(this).closest('input').val(amount);
    $(this).closest('.modal').find('.color-highgreen').text(amount * price + " Cr");
    $(this).closest('.modal').find('input').val(amount);
  });
  
  // On Buy Input Change
  $('.station-card').on('change', '.market-buy-input', function(e) {
    $(this).closest('.modal').find('.color-highgreen').text(parseInt($(this).val()) * parseInt($(this).closest('.modal').find('.max-buy-btn').data('price')) + " Cr");
  });
  
  // Appraisal AJAX
  $('.station-card').on('click', '.market-appraise-btn', function(e) {
    $('#market-sell').find('.max-btn').data("amount", $(this).data("amount"));
    $('#market-sell').find('.max-btn').data("loader", $(this).data("loader"));
    $('#market-sell').find('.max-btn').data("type", $(this).data("type"));
    $('#market-sell').find('.market-sell-btn').data("loader", $(this).data("loader"));
    $('#market-sell').find('.market-sell-btn').data("id", $(this).data("id"));
    $('#market-sell').find('.market-sell-btn').data("type", $(this).data("type"));
    $('#market-sell').find('.market-sell-btn').data("amount", "1");
    var loader = $(this).data('loader');
    var type = $(this).data('type');
    
    $.post('market/appraisal', {loader: loader, type: type, quantity: 1}, function(data) {
      $('#selling-price').text(data.price + " Cr");
      $('.custom-sell-price').val(data.price);
    });
  });
  
  // Sell Max Button click
  $('.station-card').on('click', '#market-sell .max-btn', function(e) {
    e.preventDefault();
    $('#market-sell').find('.custom-quantity').val($(this).data("amount"));
    $('#market-sell').find('.market-sell-btn').data("amount", $(this).data("amount"));
    var loader = $(this).data("loader")
    var type = $(this).data('type')
    
    $.post('market/appraisal', {loader: loader, type: type, quantity: $(this).data("amount")}, function(data) {
      $('#selling-price').text(data.price + " Cr");
    });
  });
  
  // Change Input Sell AJAX
  $('.station-card').on('change', '#market-sell .custom-quantity', function(e) {
    if (parseInt($(this).val()) < 1) {
      $(this).val("1")
    }
    
    var amount = $(this).val();
    var loader = $(this).closest('.modal').find('.max-btn').data("loader");
    var type = $(this).closest('.modal').find('.max-btn').data("type");
    
    $('#market-sell').find('.market-sell-btn').data("amount", amount);
    
    $.post('market/appraisal', {loader: loader, type: type, quantity: amount}, function(data) {
      $('#selling-price').text(data.price + " Cr");
    });
  });
  
  // Sell Button AJAX
  $('.station-card').on('click', '#market-sell .market-sell-btn', function(e) {
    var amount = $(this).data('amount');
    var loader = $(this).data('loader');
    var type = $(this).data('type')
    var id = $(this).data('id')
    var button = $(this)
    var html = button.html();
    
    if (button.closest('.modal').find('.custom-sell-price').length) {
      var price = button.closest('.modal').find('.custom-sell-price').val();
    } else {
      var price = 0;
    }
    
    loading_animation(button);
    $.post('market/sell', {loader: loader, type: type, quantity: amount, id: id, price: price}, function(data) {
      button.closest('.modal').modal('hide');
      button = $('#app-container').find('.market-appraise-btn[data-loader="'+loader+'"]');
      
      setTimeout(function() {
        var type = Cookies.get('station_tab');
        if (type) {
          $('.station-card .nav-pills a').each(function() {
            if ($(this).data('target') == type) { 
              $(this).tab('show'); 
              load_station_tab($('.station-card a.nav-link.active').data('target'));
            }
          });
        }
      }, 250);
      
      refresh_player_info();
      
    }).error(function(data) {
      button.html(html);
      $('#market-sell').find('input').addClass("outline-danger"); 
      if (!button.closest('.modal').find('.error').length) {
        button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
        setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 1000) 
      }
    });
  });
  
  // On Close Modal Sell
  $('.station-card').on('hidden.bs.modal', '#market-sell', function () {
    $('#market-sell').find('input').removeClass("outline-danger");
    $('#market-sell').find('input').val("1");
  })
});