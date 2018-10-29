$( document ).on('turbolinks:load', function() {
  $('.show-mail-btn').on('click', function() {
    $.get('/mails/' + parseInt($(this).data('id')), function(data) {
      if ($('#mail-show-card').length) {
       $('#mail-show-card').remove(); 
      }
      $('.mails-card').after(data);
    });
  });
});