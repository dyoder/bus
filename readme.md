# Get On The Bus

You can think of Bus like `EventEmitter` except that you can create hierarchies of event handlers and unhandled events "bubble" up the hierarchy.

    {readFile} = require "fs"
    Bus = require "./bus"

    bus = new Bus
    bus.on "error", (error) -> console.log "General error"

    file = bus.scope()
    file.on "error", (error) -> console.log "File error"
    readFile = file.callback readFile

    # This one will print 'File read'
    channel = readFile "readme.md"
    channel.on "success", (file) ->
      console.log "File read"
  
    # This one will print 'File error'
    channel = readFile "readme.mdx"
    channel.on "success", (file) ->
      console.log "File read"

    # This one will print 'General error'
    bad = bus.scope()
    bad.send "error", new Error "mhmm"    

# Installation

Just use npm:

    npm install bus
    
# Status

Early development. Currently, the package is set up for use with CoffeeScript.