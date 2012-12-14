Emitter = require "./emitter"
{include,Attributes,merge,toError} = require "fairmont"

class Bus extends Emitter
  
  include @, Attributes
  
  constructor: (@options={}) ->
    {@parent, @name} = @options
    super options
    
  # We override emit because we need to propagate this
  # event to the parent ...
  emit: (event,args...) ->
    super event, args...
    if @parent?
      event = if @name then "#{@name}.#{event}" else event
      @parent.emit event, args...

  # Create a new bus, with this one as the parent.
  channel: (name=null) -> 
    new Bus (merge @options, parent: @, name: name)
  
  # A callback function for this bus
  @reader "callback", ->
    (error,results...) =>
      unless error?
        @emit "success", results...
      else
        @emit "error", (toError error)
     
  # Generate a new channel and a function that uses that 
  # channel to generate events.
  wrap: (fn,name) ->
    (args...) =>
      ch = @channel name
      fn args..., ch.callback
      ch

  # Bind an event emitter so that any events it fires will
  # become bus events. 
  emitter: (emitter) -> 
    self = @
    emit = emitter.emit
    emitter.emit = (event,args...) ->
      emit.call @, event, args...
      self.send event, args...
    emitter
    
  # Wrap a function in a try-catch and convert errors to 
  # events.
  safely: (fn) ->
    try
      @send "success", fn()
    catch error
      @send "error", (toError error)
      
module.exports = Bus