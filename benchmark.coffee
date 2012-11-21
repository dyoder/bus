Bus = require "./bus"
bus = new Bus
  
count = 0
repeat = 100000

handler = ->
  count++
  unless count is repeat 
    for i in [1..20]
      bus.once "foo.*.baz", ->
    bus.once "foo.*.baz", -> handler()
    bus.event "foo.#{count}.baz"
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"


start = Date.now()
handler()
