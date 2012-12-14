{readFile} = require "fs"
Bus = require "../src/bus"

bus = new Bus
bus.on "*.error", (error) -> console.log "General error"

file = bus.channel "file"
file.on "*.error", (error) -> console.log "File error"

# Next, let's wrap the readFile method using the file channel
read = file.wrap readFile, "read"

# This one will print 'File read'
ch = read "readme.md"
ch.on "success", (file) ->
  console.log "File read"
  
# This one will print 'File error'
ch = read "readme.mdx"
ch.on "success", (file) ->
  console.log "File read"

# This one will print 'General error'
bad = bus.channel "bad"
bad.send "error", new Error "mhmm"