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
});