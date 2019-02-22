$(document).on "turbolinks:load", ->
  check_chats()
    
window.check_chats = ->
  if (logged_in && !App['local-chat'])
    App['local-chat'] = App.cable.subscriptions.create({channel: 'ChatChannel', room: 'local_chat'},
      received: (data) ->
        if ($('#local-chat').length > 0)
          $('#local-chat table tbody').append(data.message)
          if (!$('a[data-target="#local-chat"]').hasClass('active'))
            $('a[data-target="#local-chat"]').addClass('chat-flash')
            setFlashChats()
          addToMobileChatNotification()
          scrollChats()
          
      send_message: (message) ->
        @perform 'send_message', message: message, room: 'local'
    )
        
  if (logged_in && !App['global-chat'])
    App['global-chat'] = App.cable.subscriptions.create({channel: 'ChatChannel', room: 'global_chat'},
      received: (data) ->
        if ($('#global-chat').length > 0)
          $('#global-chat table tbody').append(data.message)
          if (!$('a[data-target="#global-chat"]').hasClass('active'))
            $('a[data-target="#global-chat"]').addClass('chat-flash')
            setFlashChats()
          addToMobileChatNotification()
          scrollChats()
          
      send_message: (message) ->
        @perform 'send_message', message: message, room: 'global'
    )