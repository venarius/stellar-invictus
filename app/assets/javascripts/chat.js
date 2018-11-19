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
    
    // Join chatroom AJAX
    $('#join-chatroom-modal').on('click', '#join-chatroom-modal-join-btn', function(e) {
      e.preventDefault();
      var id = $('#join-chatroom-modal-join-input').val()
      if (id) {
        $.post('chat/join', {id: id}, function(data) {
          Turbolinks.visit(window.location);
        }).error(function(data) {
          $('#join-chatroom-modal-join-input').removeClass("outline-danger").addClass("outline-danger");
        });
      } else {
        $('#join-chatroom-modal-join-input').removeClass("outline-danger").addClass("outline-danger");
      }
    });
    
    // Close Chat AJAX
    $('.chat-card').on('click', '.close-chat-btn', function(e) {
      e.preventDefault();
      var button = $(this)
      var id = $(this).data('id')
      $.post('chat/leave', {id: id}, function(data) {
        App['chatroom-' + id].unsubscribe();
        $(button.parent().attr('href')).remove();
        button.parent().parent().remove();
        $('.chat-card .nav-tabs a[href="#local-chat"]').tab('show')
      });
    });
    
    // Create chatroom AJAX
    $('#join-chatroom-modal').on('click', '#join-chatroom-modal-create-btn', function(e) {
      e.preventDefault();
      var title = $('#join-chatroom-modal-create-input').val()
      if (title) {
        $.post('chat/create', {title: title}, function(data) {
          Turbolinks.visit(window.location);
        });
      } else {
        $('#join-chatroom-modal-create-input').removeClass("outline-danger").addClass("outline-danger");
      }
    });
    
    // Clear on hidden modal
    $('#join-chatroom-modal').on('hidden.bs.modal', function(e) {
      $('#join-chatroom-modal-create-input').val("").removeClass("outline-danger");
      $('#join-chatroom-modal-join-input').val("").removeClass("outline-danger");
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

// Update players in system
function update_players_in_custom_chat(id, names) {
  if ($('#' + id).length) {
    $('#' + id + '-players').empty();
    names = names.sort();
    $.each(names, function(index, tag) {  
      $('#' + id + '-players').append("<div>"+tag+"</div>")
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