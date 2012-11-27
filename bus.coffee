{Catalog,error,Attributes} = require "fairmont"

Catalog.add "invalid-pattern", (pattern) ->
  "#{pattern} is not a valid pattern"

class Bus
  
  constructor: ->
    @_patterns = new PatternSet()
    @_handlers = {}
    @_receivers = []
    
  on: (specification,handler) ->
    @_patterns.add(specification)
    @_handlers[specification] ?= []
    @_handlers[specification].push handler
    
  once: (specification,handler) ->
    handler.once = true
    @on specification, handler

  remove: (specification,handler) ->
    handlers = @_handlers[specification]
    # Array::indexOf returns -1 if the element doesn't exist in the array
    # or the index of the element if it does ...
    while (index = handlers.indexOf handler) != -1
      handlers[index..index] = []
      
  reset: ->
    @_handlers = {}
    
  send: (qualifiedName, args...) ->
    process.nextTick =>
      @_patterns.match qualifiedName, (specification) =>
        handlers = @_handlers[specification].slice(0)
        @_handlers[specification] = keepers = []
        for handler in handlers
          unless handler.once
            keepers.push(handler)
          handler args...
        if keepers.length == 0
          delete @_handlers[specification]
          @_patterns.remove(specification)
      for receiver in @_receivers
        receiver qualifiedName, args...
            
  # alias for 'send'
  event: (args...) -> @send args...
  
  receive: (handler) -> @_receivers.push handler
    
empty = (array) -> array.length is 0

_parse = (string) ->
  try
    string.split "."
  catch error
    throw ((error "invalid-pattern")(string))
  
class PatternSet

  constructor: ->
    @_patterns = {}

  add: (specification) ->
    @_patterns[specification] ?= new Pattern(specification)

  remove: (specification) ->
    delete @_patterns[specification]

  match: (qualifiedName, callback) ->
    sequence = _parse(qualifiedName)
    for specification, pattern of @_patterns
      if pattern.match sequence
        callback(specification)

class Pattern
  
  constructor: (pattern) ->
    @_pattern = _parse pattern
    
  match: (target) ->
    pattern = @_pattern
    while true
      pl = pattern.length
      tl = target.length
      if tl is pl is 0
        return true
      else
        [p,px...] = pattern
        [t,target...] = target
        if p is "*"
          [q,qx...] = px
          if q is t
            pattern = qx
        else if p is t
          pattern = px
        else
          return false

Bus.PatternSet = PatternSet
Bus.Pattern = Pattern
      
module.exports = Bus
