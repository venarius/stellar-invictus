$(document).on "turbolinks:load", ->
  if (logged_in && !App.player)
    App.player = App.cable.subscriptions.create "PlayerChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
     
      # Called when the WebSocket connection is closed.
      disconnected:->
      
      # On message received
      received: (data)->
        if (data.method == 'received_mail')
          received_mail()
        else if (data.method == 'refresh_target_info')
          refresh_target_info()
        else if (data.method == 'getting_targeted' && data.name)
          getting_targeted(data.name)
        else if (data.method == 'getting_attacked' && data.name)
          getting_attacked(data.name)
        else if (data.method == 'reload_page')
          Turbolinks.visit(window.location);
        else if (data.method == 'update_health' && data.hp)
          update_health(data.hp)
        else if (data.method == 'update_target_health' && data.hp)
          update_target_health(data.hp)
        else if (data.method == 'update_asteroid_resources' && data.resources)
          update_asteroid_resources(data.resources)
        else if (data.method == 'asteroid_depleted')
          remove_target()
          reload_players_card()