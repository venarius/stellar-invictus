var scaninterval;
$( document ).on('turbolinks:load', function() {
  
  // Scan System Btn AJAX
  $('#app-container').on('click', '.scan-system-btn', function() {
    var html = $(this).html();
    var button = $(this);
    
    loading_animation($(this));
    
    $('.overview-card').find('tr.hidden-site').each(function() {
      $(this).remove();
    });
    
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
      button.html(html);
    }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } button.html(html); });
  });
  
  // Directional Scan Btn AJAX
  $('#app-container').on('click', '.directional-scan-btn', function() {
    $('.directional-scan').remove();
    $.post('/system/directional_scan', function(data) {
      $('.overview-card').find('tr').each(function() {
        $(this).find('.name').append(" <span class='directional-scan'>(" + data.locations[$(this).find('.warp-btn').data('id')] + ")<span>");
      });
    });
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
      button.closest('.modal').find('input').css('border', '1px solid green').css('box-shadow', '0 0 5px green');
      setTimeout(function() {
        button.closest('.modal').modal('hide');
        reload_players_card();
      }, 1000)
    }).fail(function() { 
      button.closest('.modal').find('input').css('border', '1px solid red').css('box-shadow', '0 0 5px red'); 
      setTimeout(function() {button.closest('.modal').modal('hide');}, 1000)
    });
  });
});