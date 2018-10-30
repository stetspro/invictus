$(document).on "turbolinks:load", ->
  if (logged_in)
    App.player = App.cable.subscriptions.create "PlayerChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
     
      # Called when the WebSocket connection is closed.
      disconnected:->
      
      # On message received
      received: (data)->
        if (data.method == 'received_mail')
          received_mail()