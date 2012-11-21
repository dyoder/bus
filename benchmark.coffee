Bus = require "./bus"
bus = new Bus
  
count = 0
repeat = 10000

for i in [1..80]
  bus.on "foo.bar#{i}.baz", ->

handler = ->
  count++
  unless count is repeat
    bus.once "foo.*.baz", -> handler()
    bus.event "foo.#{count}.baz"
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"


start = Date.now()
handler()
