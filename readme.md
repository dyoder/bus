# Get On The Bus

You can think of Bus like `EventEmitter` except that you can create hierarchies of event handlers and events "bubble" up the hierarchy.

    {readFile} = require "fs"
    Bus = require "node-bus"

    # First, we'll set up a root events channel. All events will 
    # bubble up to this channel. We'll use that to provide a general
    # purpose error-handler.
    root = new Bus
    root.on "*.error", (error) -> console.log "General error"

    # Next, we'll create a channel for file-related events. We'll
    # also set up an error handler that's more specific to file errors.
    file = bus.channel "file"
    file.on "*.error", (error) -> console.log "File error"

    # Next, let's wrap the readFile method using the file channel. Now
    # we can call it and it will generate events for us.
    read = file.wrap readFile, "read"

    # This one will print 'File read'
    ch = read "readme.md"
    ch.on "success", (file) ->
      console.log "File read"
  
    # This one will print 'File error' and 'General error'
    ch = read "readme.mdx"
    ch.on "success", (file) ->
      console.log "File read"

    # This one will print 'General error'. Note that channels can be 
    # anonymous.
    bad = bus.channel()
    bad.send "error", new Error "mhmm"

# Installation

Just use npm:

    npm install bus
    
# Status

Early development. Currently, the package is set up for use with CoffeeScript.