$( document ).on('turbolinks:load', function() {
  // Edit Corporation Btn
  $('#edit-corporation-motd-btn').on('click', function() {
    var button = $(this);
    
    if ($('#corporation-motd').find('textarea').length) {
      
      // Save Mode
      var text = $('#corporation-motd-editarea').val();
      $.post('corporation/update_motd', {text: text}, function(data) {
        $('#corporation-motd').css('padding', '1.25rem');
        $('#corporation-motd').html(data.text);
        button.html(data.button_text);
      });
      
    } else {
      
      // Edit Mode
      if ($('#corporation-motd').find('.no-motd-pl').length) {
        $('#corporation-motd').html('...');
      }
      var old = $('#corporation-motd').html();
      $('#corporation-motd').html("<textarea class='form-control' id='corporation-motd-editarea'>"+old+"</textarea>");
      $('#corporation-motd').css('padding', '0');
      $('#corporation-motd-editarea').css('height', '100%');
      button.html("<i class='fa fa-save'></i>") 
      
    }
    
  });
});