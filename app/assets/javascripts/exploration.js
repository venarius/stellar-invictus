$( document ).on('turbolinks:load', function() {
  $('.overview-card').on('click', '.scan-system-btn', function() {
    var text = $(this).text();
    var button = $(this).button();
    
    loading_animation($(this));
    $.post('system/scan', function(data) {
      $(data).find('.warp-btn').each(function() {
        var id = $(this).data('id');
        var button = $(this);
        var found = 0;
        
        $('.overview-card').find('.warp-btn').each(function() {
          if ($(this).data('id') == id) { found = 1; }
        });
        
        if (found == 0) {
          $('.overview-card .card-body table tbody').append(button.closest('tr'));
        }
      });
      button.html(text);
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(text); });
  });
});