Testify = require "testify"
assert = require "assert"

Bus = require "./bus"

Testify.test "A pattern with no wildcards matches", (test) ->
  pattern = new Bus.Pattern "foo.bar"
  assert.ok pattern.match "foo.bar"
  test.pass()


Testify.test "A pattern with a trailing wildcard matches", (test) ->
  pattern = new Bus.Pattern "foo.*"
  assert.ok pattern.match "foo.bar"
  test.pass()

Testify.test "A pattern with a leading wildcard matches", (test) ->
  pattern = new Bus.Pattern "*.bar"
  assert.ok pattern.match "foo.bar"
  test.pass()

Testify.test "A pattern consisting of a single wild-card matches", (test) ->
  pattern = new Bus.Pattern "*"
  assert.ok pattern.match "foo.bar"
  test.pass()

Testify.test "A mismatched pattern with no wildcards doesn't match", (test) ->
  pattern = new Bus.Pattern "bar.foo"
  assert.ok !pattern.match "foo.bar"
  test.pass()

Testify.test "A mismatched pattern with a trailing wildcard doesn't match", (test) ->
  pattern = new Bus.Pattern "bar.*"
  assert.ok !pattern.match "foo.bar"
  test.pass()

Testify.test "A mismatched pattern with a leading wildcard doesn't match", (test) ->
  pattern = new Bus.Pattern "*.foo"
  assert.ok !pattern.match "foo.bar"
  test.pass()

Testify.test "A long pattern with no wildcards matches", (test) ->
  pattern = new Bus.Pattern "foo.bar.baz"
  assert.ok pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long pattern with a leading wildcard matches", (test) ->
  pattern = new Bus.Pattern "*.bar.baz"
  assert.ok pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long pattern with a leading wildcard matches multiple elements", (test) ->
  pattern = new Bus.Pattern "*.baz"
  assert.ok pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long pattern with a middle wildcard matches", (test) ->
  pattern = new Bus.Pattern "foo.*.baz"
  assert.ok pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long mismatched pattern with a trailing wildcard doesn't match", (test) ->
  pattern = new Bus.Pattern "bar.foo.*"
  assert.ok !pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long mismatched pattern with a leading wildcard doesn't match", (test) ->
  pattern = new Bus.Pattern "*.foo"
  assert.ok !pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A long mismatched pattern with a middle wildcard doesn't match", (test) ->
  pattern = new Bus.Pattern "foo.*.bar"
  assert.ok !pattern.match "foo.bar.baz"
  test.pass()

Testify.test "A bus with an event handler fires the event", (test) ->
  bus = new Bus
  bus.on "foo.bar", -> 
    assert.ok true
    test.pass()
  bus.send "foo.bar"
  
Testify.test "A bus with a wild-card event handler fires the event", (test) ->
  bus = new Bus
  bus.on "foo.*", -> 
    assert.ok true
    test.pass()
  bus.send "foo.bar"
  
Testify.test "A bus with a one-time event handler doesn't fire twice", (test) ->
  bus = new Bus
  count = 0
  bus.once "foo.*", -> 
    count++
  bus.send "foo.bar"
  bus.send "foo.bar"
  process.nextTick ->
    assert.ok count is 1
    test.pass()
  
Testify.test "A bus with an event handler that has been removed doesn't fire", (test) ->
  bus = new Bus
  count = 0
  increment = -> count++
  bus.once "foo.*", increment
  bus.remove "foo.*", increment
  bus.send "foo.bar"
  assert.ok count is 0
  test.pass()
  
Testify.test "A bus with cascading events fires them all", (test) ->
  bus = new Bus
  flag = false
  bus.on "foo", -> 
    bus.event "bar"
    process.nextTick ->
      assert.ok flag
      test.pass()
  bus.on "foo", -> 
    bus.on "bar", ->  flag = true
  bus.event "foo"
