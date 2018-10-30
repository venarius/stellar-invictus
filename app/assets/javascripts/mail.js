$( document ).on('turbolinks:load', function() {
  // Load dynamic mail if click on show button
  $('.show-mail-btn').on('click', function() {
    $.get('/mails/' + parseInt($(this).data('id')), function(data) {
      if ($('#mail-show-card').length) {
       $('#mail-show-card').remove(); 
      }
      $('.mails-card').after(data);
    });
  });
  
  // Remove badge if current location is mails
  if (window.location == "/mails" && $('#mails-alert').length) {
    $('#mails-alert').remove();
  }
});

// Reload mails or display badge in navbar if actioncable received mail
function received_mail() {
  if ($('.mails-card').length) {
    $.get("/mails/inbox", function(data) {
      $('#inbox').empty().append(data);
    });
  } else if ($('#navbarColor02').length && !$('#mails-alert').length) {
    $('#navbarColor02 .nav-item').each(function() {
      if ($(this).find('a').attr('href') == "/mails") {
        $(this).find('a').append("<span class='badge badge-danger' id='mails-alert'><i class='fa fa-exclamation'></i></span>")
      }
    });
  }
}