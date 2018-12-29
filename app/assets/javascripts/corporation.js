$( document ).on('turbolinks:load', function() {
  // Edit Corporation Motd Btn
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
  
  // Edit Coporation Btn
  $('#edit-corporation-btn').on('click', function(e) {
    var button = $(this)
    
    if ($('#corporation-form').find('.edit-view').is(":visible")) {
      
      // Save Mode
      var tax = $('#corporation-form').find('input').val();
      var about = $('#corporation-form').find('textarea').val();
      $.post('corporation/update_corporation', {tax: tax, about: about}, function(data) {
        $('#corporation-form').find('.edit-view').css('display', 'none');
        $('#corporation-form').find('.show-view').css('display', 'block');
        $('#corporation-form').find('.show-view-tax').html(data.tax.toFixed(1) + " %");
        $('#corporation-form').find('.show-view-bio').html(data.about);
        button.html(data.button_text);
      });
      
      
    } else {
      
      // Edit Mode
      $('#corporation-form').find('.edit-view').css('display', 'block');
      $('#corporation-form').find('.show-view').css('display', 'none');
      button.html("<i class='fa fa-save'></i>") 
      
    }
  });
});