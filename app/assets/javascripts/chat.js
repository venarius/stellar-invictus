$( document ).on('turbolinks:load', function() {
    // Scroll to bottom
    scrollChats();
    
    // Send actioncable on button press
    $('#chat_send').on('click', function(e) {
      e.preventDefault();
      var value = $('#chat_msg').val();
      if (value.length > 0) {
        App[$('.chat-card').find('.tab-pane.active').attr('id')].send_message(value);
        $('#chat_msg').val('');
      }
    })
    
    // Can also send by pressing Enter
    $('#chat_msg').keypress(function(event){
      if(event.keyCode == 13){
        $('#chat_send').click();
      }
    });
});

// Scroll to bottom of each chat
function scrollChats() {
  if ($('.chat-card').length) {
    $('.chat-card .tab-content').children('.tab-pane').each(function() {
      $(this).find('tbody').scrollTop($(this).find('tbody').get(0).scrollHeight);
    })
  }
}