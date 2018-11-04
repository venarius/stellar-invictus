$(document).on "turbolinks:load", ->
  if (logged_in && !App.local)
    App.local = App.cable.subscriptions.create "LocalChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
     
      # Called when the WebSocket connection is closed.
      disconnected:->
      
      # On message received
      received: (data)->
        if (data.method == 'player_warp_out' && data.name)
          player_warp_out(data.name)
        if (data.method == 'player_appeared' && ('.players-card').length)
          reload_players_card()
          
      reload:->
        @perform("reload")