var scaninterval;
$( document ).on('turbolinks:load', function() {
  
  // Scan System Btn AJAX
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
          button.closest('tr').hide().appendTo('.overview-card .card-body table tbody').fadeIn();
        }
      });
      button.html(text);
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(text); });
  });
  
  // Abandoned Ship Btn AJAX
  $('#app-container').on('click', '.open-abandoned-ship-btn', function(e) {
    var id = $(this).data('id');
    
    $.post('structure/abandoned_ship', {id: id}, function(data) {
        var element = $(data)
        $('#app-container').append(element);
        element.modal('show');
        element.find('.abandoned-ship-submit-btn').data('id', id);
    });
  });
  
  // Remove on Modal Close
  $('#abandoned-ship-modal').on('hidden.bs.modal', function() { $(this).remove(); })
  
  // Submit Riddle Btn
  $('#app-container').on('click', '.abandoned-ship-submit-btn', function(e) {
    var text = $(this).closest('.modal').find('input').val();
    var id = $(this).data('id');
    var button = $(this)
    
    $.post('structure/abandoned_ship', {text: text, id: id}, function(data) {
      button.closest('.modal').modal('hide');
      reload_players_card();
    }).error(function() { button.closest('.modal').find('input').css('border', '1px solid red').css('box-shadow', '0 0 5px red'); });
  });
});