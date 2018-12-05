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
  
  // Market Buy AJAX
  $('.station-card').on('click', '.market-buy-btn', function(e) {
    var id = $(this).data('id');
    var button = $(this)

    $.post('market/buy', {id: id}, function(data) {
      button.closest('.modal').modal('hide');
      $(".station-card").find(`[data-target='#`+button.closest('.modal').attr('id')+`']`).parent().parent().remove();
      refresh_player_info();
    });
  });
  
  // Appraisal AJAX
  $('.station-card').on('click', '.item-appraise-btn', function(e) {
    $('#market-sell').find('.max-btn').data("amount", $(this).data("amount"));
    $('#market-sell').find('.max-btn').data("loader", $(this).data("loader"));
    $('#market-sell').find('.market-sell-btn').data("loader", $(this).data("loader"));
    var loader = $(this).data('loader');
    
    $.post('market/appraisal', {loader: loader, type: 'item'}, function(data) {
      $('#selling-price').text(data.price + " Cr");
    });
  });
  
  // Sell Max Button click
  $('.station-card').on('click', '#market-sell .max-btn', function(e) {
    e.preventDefault();
    $('#market-sell').find('input').val($(this).data("amount"));
    var loader = $(this).data("loader")
    
    $.post('market/appraisal', {loader: loader, type: 'item', quantity: $(this).data("amount")}, function(data) {
      $('#selling-price').text(data.price + " Cr");
    });
  });
  
  // Change Input Sell AJAX
  $('.station-card').on('change', '#market-sell input', function(e) {
    if (parseInt($(this).val()) < 1) {
      $(this).val("1")
    }
    
    var amount = $(this).val();
    var loader = $(this).closest('.modal').find('.max-btn').data("loader");
    
    $.post('market/appraisal', {loader: loader, type: 'item', quantity: amount}, function(data) {
      $('#selling-price').text(data.price + " Cr");
    });
  });
  
  // Sell Button AJAX
  $('.station-card').on('click', '#market-sell .market-sell-btn', function(e) {
    var amount = $('#market-sell').find('input').val();
    var loader = $(this).data('loader');
    var button = $(this)
    
    $.post('market/sell', {loader: loader, type: 'item', quantity: amount}, function(data) {
      button.closest('.modal').modal('hide');
      Turbolinks.visit(window.location);
    }).error(function() { $('#market-sell').find('input').addClass("outline-danger"); });
  });
  
  // On Close Modal Sell
  $('.station-card').on('hidden.bs.modal', '#market-sell', function () {
    $('#market-sell').find('input').removeClass("outline-danger");
    $('#market-sell').find('input').val("1");
  })
});