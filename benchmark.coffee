Bus = require "./bus"
bus = new Bus
  
repeat = 1000
start = Date.now()

for i in [0..repeat]
  bus.once "foo.*.baz", -> 
  bus.event "foo.bar.baz"

finish = Date.now()
duration = finish - start

console.log "#{duration/repeat} ms per iteration"