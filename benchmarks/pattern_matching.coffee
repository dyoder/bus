Bus = require "../bus"
matcher = new Bus.PatternSet

for i in [1..80]
  matcher.add "foo.#{i}.baz"

iterations = 40000
start = Date.now()
for i in [1..iterations]
  matcher.match "foo.#{i % 240}.baz", (spec) ->

finish = Date.now()
duration = finish - start
console.log "#{duration/iterations} ms per iteration"
