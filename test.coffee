Testify = require "testify"
assert = require "assert"

w = (string) ->
  string.split(".")
  
Bus = require "./bus"

Testify.test "A Pattern", (context) ->

  context.test "with no wildcards matches", ->
    pattern = new Bus.Pattern w "foo.bar"
    assert.ok pattern.match w "foo.bar"


  context.test "with a trailing wildcard matches", ->
    pattern = new Bus.Pattern w "foo.*"
    assert.ok pattern.match w "foo.bar"

  context.test "with a leading wildcard matches", ->
    pattern = new Bus.Pattern w "*.bar"
    assert.ok pattern.match w "foo.bar"

  context.test "consisting of a single wild-card matches", ->
    pattern = new Bus.Pattern w "*"
    assert.ok pattern.match w "foo.bar"

Testify.test "A mismatched Pattern", (context) ->

  context.test "with no wildcards doesn't match", ->
    pattern = new Bus.Pattern w "bar.foo"
    assert.ok !pattern.match w "foo.bar"

  context.test "with a trailing wildcard doesn't match", ->
    pattern = new Bus.Pattern w "bar.*"
    assert.ok !pattern.match w "foo.bar"

  context.test "with a leading wildcard doesn't match", ->
    pattern = new Bus.Pattern w "*.foo"
    assert.ok !pattern.match  w "foo.bar"

Testify.test "A long Pattern", (context) ->

  context.test "with no wildcards matches", ->
    pattern = new Bus.Pattern w "foo.bar.baz"
    assert.ok pattern.match  w "foo.bar.baz"

  context.test "with a leading wildcard matches", ->
    pattern = new Bus.Pattern w "*.bar.baz"
    assert.ok pattern.match  w "foo.bar.baz"

  context.test "with a leading wildcard matches multiple elements", ->
    pattern = new Bus.Pattern w "*.baz"
    assert.ok pattern.match  w "foo.bar.baz"

  context.test "with a middle wildcard matches", ->
    pattern = new Bus.Pattern w "foo.*.baz"
    assert.ok pattern.match  w "foo.bar.baz"

  context.test "with a middle wildcard matches multiple elements", ->
    pattern = new Bus.Pattern w "foo.*.baz"
    assert.ok pattern.match  w "foo.bar-1.bar-2.baz"



Testify.test "A long mismatched Pattern", (context) ->

  context.test "with a trailing wildcard doesn't match", ->
    pattern = new Bus.Pattern w "bar.foo.*"
    assert.ok !pattern.match  w "foo.bar.baz"

  context.test "with a leading wildcard doesn't match", ->
    pattern = new Bus.Pattern w "*.foo"
    assert.ok !pattern.match  w "foo.bar.baz"

  context.test "with a leading wildcard doesn't match (no common elements)", ->
    pattern = new Bus.Pattern w "*.foo"
    assert.ok !pattern.match  w "blurg.bar.baz"

  context.test "with a middle wildcard doesn't match", ->
    pattern = new Bus.Pattern w "foo.*.bar"
    assert.ok !pattern.match  w "foo.bar.baz"
    
  context.test "with zero wildcard matches doesn't match", ->
    pattern = new Bus.Pattern w "*.foo.bar.baz"
    assert.ok !pattern.match w "foo.bar.baz"


# Tests must be asynchronous
Testify.test "A Bus", (context) ->

  context.test "with an event handler", (context) ->
    bus = new Bus
    flag = false
    
    bus.on "foo.bar", -> flag = true
    bus.send "foo.bar"
    process.nextTick -> 
      context.test "fires the event", -> 
        assert.ok flag

  context.test "with a wild-card event handler", (context) ->
    bus = new Bus
    flag = false
    bus.on "foo.*", -> flag = true
    bus.send "foo.bar"
    process.nextTick ->
      context.test "fires the event", ->
        assert.ok flag
    
  context.test "with a one-time event handler", (context) ->
    bus = new Bus
    count = 0
    bus.once "foo.*", ->
      count++
    bus.send "foo.bar"
    bus.send "foo.bar"

    process.nextTick ->
      context.test "does not fire twice", ->
        assert.ok count is 1
    
  context.test "with an event handler that has been removed", (context) ->
    bus = new Bus
    count = 0
    increment = -> count++
    bus.once "foo.*", increment
    bus.remove "foo.*", increment
    bus.send "foo.bar"
    process.nextTick ->
      context.test "does not fire", ->
        assert.ok count is 0
    
  context.test "with cascading events", (context) ->
    bus = new Bus
    flag = false

    bus.on "foo", ->
      bus.event "bar"
      
      process.nextTick ->
        context.test "fires them all", ->
          assert.ok flag

    bus.on "foo", ->
      bus.on "bar", ->  flag = true
    
    bus.event "foo"
