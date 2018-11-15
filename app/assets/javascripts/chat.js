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
    
    // Cookie setter
    $('.chat-card a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      Cookies.set('chat_tab', $(this).attr("href"));
    });
    
     // Cookie getter Chat collapse
    if ($('#collapse-chat').length) {
      var type = Cookies.get('collapse-chat');
      if (type == 'hidden') {
        $('#collapse-chat').removeClass('show');
        $('#collapse-chat').prev('.card-header').find('.fa-arrow-down').removeClass('fa-arrow-down').addClass('fa-arrow-right');
      }
    }
    
    // Cookie getter Chat active tab
    if ($('.chat-card').length) {
      var type = Cookies.get('chat_tab');
      if (type) {
        $('.chat-card .nav .nav-item a').each(function() {
          if ($(this).attr('href') == type) { $(this).tab('show'); }
        });
      }
    }
});

// Scroll to bottom of each chat
function scrollChats() {
  if ($('.chat-card').length) {
    $('.chat-card .tab-content').children('.tab-pane').each(function() {
      $(this).find('tbody').scrollTop($(this).find('tbody').get(0).scrollHeight);
    })
  }
}

// Update players in system
function update_players_in_system(count, names) {
  if ($('#system-player-count').length) {
    $('#system-player-count').text(count);
    $('#system-players').empty();
    names = names.sort();
    $.each(names, function(index, tag) {  
      $('#system-players').append("<div>"+tag+"</div>")
    });
  }
}

// Logging
function log(text) {
  if ($('#log').length) {
    $('#log').find('tbody').append("<tr><td>"+text+"</td></tr>")
    scrollChats();
  }
}