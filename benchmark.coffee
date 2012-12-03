Bus = require "./bus"
bus = new Bus
foo = bus.scope()
bar = foo.scope()
  
count = 0
repeat = 10000

bar._events.setMaxListeners 80

for i in [1..80]
  bar.on "baz", ->

handler = ->
  count++
  unless count is repeat
    foo.once "baz", -> handler()
    bar.send "baz"
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"


start = Date.now()
handler()