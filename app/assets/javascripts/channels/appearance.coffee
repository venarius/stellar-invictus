$(document).on "turbolinks:load", ->
  if (logged_in && !App.appearance)
    App.appearance = App.cable.subscriptions.create "AppearanceChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
        if ($('#got-disconnected-modal').hasClass('show'))
          Turbolinks.visit(window.location)
      # Called when the WebSocket connection is closed.
      disconnected:->
        $('#got-disconnected-modal').modal('show')