Bus = require "./bus"
bus = new Bus
  
count = 0
repeat = 1000

handler = ->
  count++
  unless count is repeat 
    bus.once "foo.*.baz", -> handler()
    bus.event "foo.bar.baz"
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"


start = Date.now()
handler()
setTimeout (->), 3000
