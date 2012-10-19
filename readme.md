# Get On The Bus

Bus is like Event Emitter, except with wildcard matching. The purpose is to allow co-operating components to share a single event bus by effectively making it possible to namespace the events on the bus and for client code to subscribe to "families" of events.

    Bus = require "./bus"
    bus = new Bus
    bus.on "*.error", (error) -> 
      {name,message} = error
      console.log "#{name}: #{message}"
    bus.emit "foo.bar.error", new Error "Ruh-roh!"
    
# Installation

Just use npm:

    npm install bus
    
# Status

Early development. Currently, the package is set up for use with CoffeeScript.