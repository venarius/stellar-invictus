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
        else if (data.method == 'refresh_player_info')
          refresh_player_info()
        else if (data.method == 'getting_targeted' && data.name)
          getting_targeted(data.name)
        else if (data.method == 'getting_attacked' && data.name)
          getting_attacked(data.name)
        else if (data.method == 'reload_page')
          clear_jump()
          Turbolinks.visit(window.location)
        else if (data.method == 'update_health' && data.hp)
          update_health(data.hp)
        else if (data.method == 'update_target_health' && data.hp)
          update_target_health(data.hp)
        else if (data.method == 'update_asteroid_resources' && data.resources)
          update_asteroid_resources(data.resources, true)
        else if (data.method == 'update_asteroid_resources_only' && data.resources)
          update_asteroid_resources(data.resources, false)
        else if (data.method == 'asteroid_depleted')
          remove_target()
          reload_players_card()
        else if (data.method == 'died_modal' && data.text)
          show_died_modal(data.text)
        else if (data.method == 'log' && data.text)
          log(data.text)