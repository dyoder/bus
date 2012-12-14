Testify = require "testify"
assert = require "assert"

# w = (string) ->
#   string.split(".")

w = (string) -> string
  
Emitter = require "../src/emitter"


# Tests must be asynchronous
Testify.test "An Emitter", (context) ->

  context.test "with an event handler", (context) ->
    emitter = new Emitter
    flag = false
    
    emitter.on "foo.bar", -> flag = true
    emitter.send "foo.bar"
    process.nextTick -> 
      context.test "fires the event", -> 
        assert.ok flag

  context.test "with a wild-card event handler", (context) ->
    emitter = new Emitter
    flag = false
    emitter.on "foo.*", -> flag = true
    emitter.send "foo.bar"
    process.nextTick ->
      context.test "fires the event", ->
        assert.ok flag
    
  context.test "with a one-time event handler", (context) ->
    emitter = new Emitter
    count = 0
    emitter.once "foo.*", ->
      count++
    emitter.send "foo.bar"
    emitter.send "foo.bar"

    process.nextTick ->
      context.test "does not fire twice", ->
        assert.ok count is 1
    
  context.test "with an event handler that has been removed", (context) ->
    emitter = new Emitter
    count = 0
    increment = -> count++
    emitter.once "foo.*", increment
    emitter.remove "foo.*", increment
    emitter.send "foo.bar"
    process.nextTick ->
      context.test "does not fire", ->
        assert.ok count is 0
    
  context.test "with cascading events", (context) ->
    emitter = new Emitter
    flag = false

    emitter.on "foo", ->
      emitter.send "bar"
      
      process.nextTick ->
        context.test "fires them all", ->
          assert.ok flag

    emitter.on "foo", ->
      emitter.on "bar", ->  flag = true
    
    emitter.send "foo"