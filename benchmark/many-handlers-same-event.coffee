Bus = require "../src/bus"
bus = new Bus
  
for i in [1..1000]
  bus.on "baz", ->

handler = (count,repeat) ->
  unless count is repeat
    bus.once "foo", handler
    bus.send "foo", ++count, repeat
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"

start = Date.now()
handler 1, 10000