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
    @_patterns[specification] ?= new Pattern _parse specification

  remove: (specification) ->
    delete @_patterns[specification]

  match: (qualifiedName, callback) ->
    sequence = _parse(qualifiedName)
    for specification, pattern of @_patterns
      if pattern.match sequence
        callback(specification)

_match = (pattern,target) ->
  pl = pattern.length
  tl = target.length
  if pl is tl is 0
    return true
  else if pl is 0 or tl is 0
    return false
  else
    [p,px...] = pattern
    [t,tx...] = target
    if p is "*"
      if _match px, tx
        return true
      else
        _match pattern, tx
    else if p is t
      _match px, tx
    else
      return false
  
class Pattern
  
  constructor: (@_pattern) ->
    
  match: (target) ->
    _match(@_pattern,target)
        
    
    
Bus.PatternSet = PatternSet
Bus.Pattern = Pattern
      
module.exports = Bus
