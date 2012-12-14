{EventEmitter2} = require "eventemitter2"
{delegate,merge,toError} = require "fairmont"

class Bus extends EventEmitter2
  
  constructor: (@options={}) ->
    {@parent, @name} = options
    super options
    
  # We override emit because we need to propagate this
  # event to the parent ...
  emit: (event,args...) ->
    super event, args...
    event = if @name then "#{@name}.#{event}" else event
    @parent.emit event, args... if @parent?

  # Triggering an event with ::send fires it on next tick.
  # This preserves the meaning of ::emit, while allowing 
  # us to provide a uniform interface for events if we
  # want, even if an event is synchronous
  send: (event,args...) ->
    process.nextTick =>
      @emit event, args...

  # Create a new bus, with this one as the parent.
  channel: (name=null) -> 
    new Bus (merge @options, parent: @, name: name)
  
  # Generate a callback function that will translate the
  # callback into a success or error event.
  callback: ->
    (args...) =>
      channel = @channel()
      fn args..., (error,results...) =>
        unless error?
          channel.emit "success", results...
        else
          channel.emit "error", (toError error)
      channel
     
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
      fn()
    catch error
      @send "error", (toError error)
      
module.exports = Bus