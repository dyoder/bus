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
          # TODO: do we need to remove unused specifications from the
          # PatternMatcher? How to determine which specs are unused?
          # Maybe: at end of this function, see if keepers.length > 0.
          # If not, then we can remove both the handlers array
          # and the pattern-matching spec
          unless handler.once
            keepers.push(handler)
          handler args...
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
    
  _match: (wants, gots) ->
    for want, i in wants
      got = gots[i]
      unless want == got || want == "*"
        return false
    true

  match: (target) ->
    pl = @_pattern.length
    tl = target.length
    if tl == 0 && pl == 0
      true
    else if pl > tl
      false
    else if pl < tl
      if @_pattern[0] == "*"
        index = tl - pl
        @_match(@_pattern.slice(1), target.slice(-index))
      else
        false
    else
      @_match(@_pattern, target)
  

Bus.PatternSet = PatternSet
Bus.Pattern = Pattern
      
module.exports = Bus
