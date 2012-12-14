{type} = require "fairmont"
PatternSet = require "./pattern-set"

# This emitter is much like EventEmitter or EventEmitter2, with a few crucial
# and non-additive differences. First, the wildcard matches arbitrary levels
# of scope and is automatic. Put another way, an event specification of "*" is
# meaningful and you don't have to turn it on with a flag in the constructor.
# Second, there is no special treatment for error handling. No exception is
# thrown or warning logged if you don't handle an error event. Third, you can
# provide a flag for a handler to include the event name when calling the
# handler (listener) function. This is encapsulated in the ::receive method.
#
# In addition, there is a ::send method, which emits an event on the next
# tick. This makes it possible to uniformly deal with events regardless of
# whether they are synchronous or asynchronous. 
#
# The purpose of these differences is to allow a hierarchy of emitters to be
# used in a meaningful way. As events bubble up the tree, scope is added, thus
# the need for more flexible wild-card matching. You can do aspect-oriented
# programming tricks by using the ::receive method. And error-handling can be
# placed wherever it makes the most sense (possibly higher up in the emitter
# hierarchy). Special handling for "error" events can be layered in by
# consumers of this class if desired.
#
# Another nice feature of this implementation is the separation of concerns.
# The pattern matching is entirely encapsulated in the PatternSet class. That
# keeps the logic here very clear and focused on the event handling. We match
# against the PatternSet, and then use the matches to lookup handlers.
# Handlers are objects that include a handler function and possibly other
# attributes, like TTLs or other flags.

_toHandler = (handler) ->
  _type = type handler
  switch (type handler)
    when "function"
      function: handler 
    when "object"
      handler
    else 
      throw new Error "Invalid handler: #{handler}"
  
_copyArray = (array) -> [array...]

class Emitter
    
  constructor: -> @reset()
    
  handlers: (specification) ->
    @_handlers[specification] ?= []
    
  on: (specification,handler) ->
    @_patterns.add specification
    handler = (_toHandler handler)
    (@handlers specification).push handler
    if handler.ttl?
      @_setTimeout specification, handler
    
  once: (specification,handler) ->
    handler = (_toHandler handler)
    handler.once = true
    @on specification, handler

  receive: (specification, handler) ->
    handler = (_toHandler handler)
    handler.receiver = true
    @on specification, handler

  remove: (specification,handler) ->
    handlers = @_handlers[specification]
    keepers = []
    for _handler in handlers
      unless _handler.function is handler
        keepers.push _handler
    @_handlers[specification] = keepers
    
  removeAll: (specification) ->
    if specification?
      delete @_handlers[specification]
      @_patterns.remove specification
    else
      @reset()
      
  reset: -> 
    @_patterns = new PatternSet()
    @_handlers = {}
    
  emit: (event, args...) ->
    specifications = @_patterns.match event, (specification) =>
      handlers = _copyArray @_handlers[specification]
      keepers = []
      for handler in handlers
        unless handler.once
          keepers.push handler
        if handler.tid
          clearTimeout handler.tid
          unless handler.once
            @_setTimeout specification, handler
        if handler.receiver
          handler.function event, args...
        else
          handler.function args...
      if keepers.length is 0
        @removeAll specification

  send: (event,args...) ->
    process.nextTick => @emit event, args...

  
  _setTimeout: (specification,handler) ->
    handler.tid = setTimeout (=> @remove specification, handler.function), handler.ttl
    

module.exports = Emitter