$( document ).on('turbolinks:load', function() {
    // Scroll to bottom
    setTimeout(function() {scrollChats();}, 250);
    
    // Get flash Chats
    getFlashChats();
    
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
      Cookies.set('chat_tab', $(this).data('target'));
      removeChatFlash($(this).data('target'));
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
          if ($(this).data('target') == type) { $(this).tab('show'); }
        });
      }
    }
    
    // Join chatroom AJAX
    $('#join-chatroom-modal').on('click', '#join-chatroom-modal-join-btn', function(e) {
      e.preventDefault();
      var id = $('#join-chatroom-modal-join-input').val()
      var button = $(this);
      
      if (id) {
        $.post('chat/join', {id: id}, function(data) {
          Cookies.set('chat_tab', '#chatroom-' + data.id)
          Turbolinks.visit(window.location);
        }).error(function(data) {
          $('#join-chatroom-modal-join-input').removeClass("outline-danger").addClass("outline-danger");
          if (!button.closest('.modal').find('.error').length) {
            button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
            setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 2000) 
          }
        });
      } else {
        $('#join-chatroom-modal-join-input').removeClass("outline-danger").addClass("outline-danger");
      }
    });
    
    // Fast Join Enter Btn
    $("#join-chatroom-modal-join-input").on('keyup', function (e) {
      if (e.keyCode == 13) {
        $('#join-chatroom-modal-join-btn').click();
      }
    })
    
    // Close Chat AJAX
    $('.chat-card').on('click', '.close-chat-btn', function(e) {
      e.preventDefault();
      var button = $(this)
      var id = $(this).data('id')
      $.post('chat/leave', {id: id}, function(data) {
        App['chatroom-' + id].unsubscribe();
        $(button.parent().attr('href')).remove();
        button.parent().parent().remove();
        $('.chat-card .nav-tabs a[data-target="#local-chat"]').tab('show')
      });
    });
    
    // Create chatroom AJAX
    $('#join-chatroom-modal').on('click', '#join-chatroom-modal-create-btn', function(e) {
      e.preventDefault();
      var title = $('#join-chatroom-modal-create-input').val()
      var button = $(this);
      
      if (title) {
        $.post('chat/create', {title: title}, function(data) {
          Cookies.set('chat_tab', '#chatroom-' + data.id)
          Turbolinks.visit(window.location);
        }).error(function(data) {
          $('#join-chatroom-modal-create-input').removeClass("outline-danger").addClass("outline-danger");
          if (!button.closest('.modal').find('.error').length) {
            button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
            setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 2000) 
          }
        });
      } else {
        $('#join-chatroom-modal-create-input').removeClass("outline-danger").addClass("outline-danger");
      }
    });
    
    // Fast Create Enter Btn
    $("#join-chatroom-modal-create-input").on('keyup', function (e) {
      if (e.keyCode == 13) {
        $('#join-chatroom-modal-create-btn').click();
      }
    })
    
    // Clear on hidden modal
    $('#join-chatroom-modal').on('hidden.bs.modal', function(e) {
      $('#join-chatroom-modal-create-input').val("").removeClass("outline-danger");
      $('#join-chatroom-modal-join-input').val("").removeClass("outline-danger");
    });
    
    // Chat Player Button AJAX
    $('body').on('click', '.chat-player-btn', function(e) {
      e.preventDefault();
      var id = $(this).data('id');
      $.post('chat/start_conversation', {id: id}, function(data) {
        Cookies.set('chat_tab', '#chatroom-' + data.id)
        Cookies.set('collapse-chat', 'shown')
        Turbolinks.visit(window.location);
      });
    });
    
    // Chat Invite Accept Button AJAX
    $('#app-container').on('click', '.accept-chat-invite-btn', function(e) {
      var id = $(this).data('id');
      $.post('chat/join', {id: id}, function(data) {
        Cookies.set('chat_tab', '#chatroom-' + id)
        Cookies.set('collapse-chat', 'shown')
        Turbolinks.visit(window.location);
      })
    });
    
    // On Invite Modal Close
    $('#app-container').on('hidden.bs.modal', '.invited-to-conversation-modal', function(e) {
      $(this).remove();
    });
    
    // Invite to ChatRoom Btn
    $('.chat-card').on('click', '.invite-to-chatroom-btn', function() {
      var identifier = $(this).data('identifier');
      $('#add-to-chat-modal-search-btn').data('identifier', identifier);
      $('#add-to-chat-modal').find('.modal-title').append(" '" + identifier + "'");
    });
    
    // Search for Users AJAX
    $('#add-to-chat-modal').on('click', '#add-to-chat-modal-search-btn', function(e) {
      if ($('#add-to-chat-modal-input').val()) {
          $('#add-to-chat-modal-input').css("border", "1px solid grey");
          $('#add-to-chat-modal-result').empty().append("<div class='text-center spinner-modal'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
        $.post('chat/search', {name: $('#add-to-chat-modal-input').val(), identifier: $(this).data('identifier')}, function(data) {
          $('#add-to-chat-modal-body').find('.spinner-modal').remove();
          $('#add-to-chat-modal-result').empty().append(data);
        })
      } else {
        $('#add-to-chat-modal-input').css("border", "1px solid red");
      }
    });
    
    // Search invite User Btn AJAX
    $('#add-to-chat-modal').on('click', '.search-invite-to-chat-btn', function() {
      var id = $(this).data('id');
      var identifier = $(this).data('identifier');
      var button = $(this);
      
      $.post('chat/start_conversation', {id: id, identifier: identifier}, function() {
        button.closest('.modal').modal('hide');
      });
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

// Set flash Chats
function setFlashChats() {
  if ($('.chat-card').length) {
    var flashes = []
    $('.chat-card a.nav-link').each(function() {
      if ($(this).hasClass('chat-flash')) {
        flashes.push($(this).data('target')) 
      }
    }); 
    Cookies.set('chat_flash', flashes);
  }
}

// Get flash Chats
function getFlashChats() {
  if ($('.chat-card').length) {
    var flashes = Cookies.get('chat_flash');
    if (flashes) {
      $.each(JSON.parse(flashes), function(index, value) {
        $('a[data-target="'+value+'"]').addClass('chat-flash');
      }); 
    }
  }
}

// Remove from flash Chats
function removeChatFlash(target) {
  if (target && Cookies.get('chat_flash')) {
    $('a[data-target="'+target+'"]').removeClass('chat-flash');
    var flashes = jQuery.grep(JSON.parse(Cookies.get('chat_flash')), function(value) {
      return value != target;
    });
    Cookies.set('chat_flash', flashes);
  }
}

// Update players in system
function update_players_in_system(count, names) {
  if ($('#system-player-count').length) {
    $('#system-player-count').text(count);
    $('#system-players').empty();
    $.each(names, function(key, value) {  
      $('#system-players').append("<div><a class='player-modal' href='#' data-id='"+value+"'>"+key+"</a></div>")
    });
  }
}

// Update players in system
function update_players_in_custom_chat(id, names, fleet) {
  if ($('#' + id).length) {
    $('#' + id + '-players').empty();
    $.each(names, function(key, value) {
      if (fleet == true) {
        $('#' + id + '-players').append("<div><a class='player-modal' href='#' data-id='"+value+"'>"+key+"</a> <a class='btn btn-outline-primary btn-xs warp-btn float-right text-primary p-0-5' data-uid='"+value+"'><i class='fa fa-angle-double-right'></i></a></div>") 
      } else {
        $('#' + id + '-players').append("<div><a class='player-modal' href='#' data-id='"+value+"'>"+key+"</a>")
      }
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

// Invited to Conversation Modal
function invited_to_conversation(data) {
  var modal = data
  $(modal).appendTo('#app-container').modal('show');
}