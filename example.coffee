Bus = require "./bus"
bus = new Bus
bus.on "*.error", (error) -> 
  {name,message} = error
  console.log "#{name}: #{message}"
bus.emit "foo.bar.error", new Error "Ruh-roh!"