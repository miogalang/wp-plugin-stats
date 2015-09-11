class Dashing.Downloads extends Dashing.Widget

  ready: ->
    console.log 'I can log'
  # send_event('downloads', { value:  })
    # This is fired when the widget is done being rendered

  onData: (data) ->
    console.log 'updated'
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
