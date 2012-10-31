{Catalog,error,Attributes} = require "fairmont"

Catalog.add "invalid-pattern", (pattern) ->
  "#{pattern} is not a valid pattern"

class Bus
  
  constructor: ->
    @_patterns = {}
    @_handlers = {}
    @_receivers = []
    
  on: (specification,handler) ->
    @_patterns[specification] ?= new Pattern specification
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
    
  send: (qualifiedName,args...) ->
    for specification,pattern of @_patterns
      if pattern.match qualifiedName
        for handler in @_handlers[specification]
          handler args...
          if handler.once 
            @remove specification, handler
    for receiver in @_receivers
      receiver qualifiedName, args...
            
  # alias for 'send'
  event: (args...) -> @send args...
  
  receive: (handler) -> @_receivers.push handler
    
empty = (array) -> array.length is 0

_match = (spec,target) ->

  return true if ((empty spec) and (empty target))
  return false if (spec.length > target.length)
  
  [sfirst,srest...] = spec
  [tfirst,trest...] = target
  
  if sfirst is tfirst 
    _match srest, trest
  else if sfirst is "*"
    if _match srest, trest
      true
    else
      _match spec, trest
  else
    false
  
_parse = (string) ->
  try
    string.split "."
  catch error
    throw ((error "invalid-pattern")(string))
  
class Pattern
  
  constructor: (pattern) ->
    @_pattern = _parse pattern
    
  match: (qualifiedName) ->
    target = _parse qualifiedName
    result = _match @_pattern, target
    result
  

Bus.Pattern = Pattern
      
module.exports = Bus