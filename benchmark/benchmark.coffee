Bus = require "../src/bus"
bus = new Bus
foo = bus.channel "foo"
bar = foo.channel "bar"
  
count = 0
repeat = 10000

for i in [1..1000]
  bar.on "baz", ->

handler = ->
  count++
  unless count is repeat
    foo.once "*.baz", handler
    bar.send "baz"
  else
    finish = Date.now()
    duration = finish - start
    console.log "#{duration/repeat} ms per iteration"


start = Date.now()
handler()