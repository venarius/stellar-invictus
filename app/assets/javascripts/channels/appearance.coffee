if window.location.pathname is '/game'
    App.cable.subscriptions.create "AppearanceChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
     
      # Called when the WebSocket connection is closed.
      disconnected:->
     
      # Called when the subscription is rejected by the server.
      rejected:->