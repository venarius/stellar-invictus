$(document).on "turbolinks:load", ->
  if (logged_in && !App.appearance)
    App.appearance = App.cable.subscriptions.create "AppearanceChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
        if ($('#got-disconnected-modal').hasClass('show'))
          location.reload();
      # Called when the WebSocket connection is closed.
      disconnected:->
        $('#got-disconnected-modal').modal('show')
        
      # On message received
      received: (data)->
        if (data.method == 'server_message' && data.text)
          server_message(data.text)