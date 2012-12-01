{EventEmitter} = require "events"

class Bus
  
  constructor: (@parent=null) ->
    @_events = new EventEmitter
    
  scope: -> new Bus @
  
  emitter: (emitter) -> 
    self = @
    emit = @emitter.emit
    @emitter.emit = (event,args...) ->
      self.send event, args...
      emit.apply @, [event,args...]
      
  callback: (fn) ->
    (args...) =>
      channel = @scope()
      fn args..., (error,results...) =>
        unless error?
          channel.send "success", results...
        else
          channel.send "error", error
      channel
    
  send: (event,args...) ->
    if @_receiver?
      process.nextTick =>
        @_receiver event, args...
      
    handlers = @_events.listeners(event)
    if handlers.length is 0
      @parent.send event, args...
    else
      process.nextTick =>
        handler args... for handler in handlers
    
  receive: (fn) ->
    @_receiver = fn
    
  on: (event,handler) ->
      @_events.on event, handler
      
module.exports = Bus