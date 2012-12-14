Testify = require "testify"
assert = require "assert"

# w = (string) ->
#   string.split(".")

w = (string) -> string
  
Bus = require "../src/bus"

Testify.test "A Bus", (context) ->

  context.test "with a channel", (context) ->

    flag = false
    root = new Bus
    root.on "foo", -> flag = true
    child = root.channel()
    child.send "foo"
    process.nextTick -> 
      context.test "will bubble events to the root", ->
        assert.ok flag
      
    