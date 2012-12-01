{readFile} = require "fs"
Bus = require "./bus"

bus = new Bus
bus.on "error", (error) -> console.log error

file = bus.scope()
file.on "error", (error) -> console.log "File Error:", error

readFile = file.callback readFile
channel = readFile "readme.mdx"
channel.on "success", (file) ->
  console.log "File read"