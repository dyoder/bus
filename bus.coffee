{EventEmitter} = require "events"

class Channel
  
  constructor: (@parent=null) ->
    @_events = new EventEmitter

  send: (event,args...) ->
    process.nextTick =>
      @emit event, args...

  emit: (event,args...) ->

    if @_receiver?
      @_receiver event, args...

    @_events.emit event, args...
    @parent.emit event, args... if @parent?
    
    # if @_events.listeners(event).length is 0
    #   if @parent?
    #     @parent.send event, args...
    # else
    #   process.nextTick =>
    #     # we use 'emit' instead of just iterating
    #     # through the handlers because that way
    #     # we can re-use the EventEmitter logic
    #     @_events.emit event, args...

  receive: (fn) ->
    @_receiver = fn

  # For channels, an on handler is a once handler
  on: (event,handler) -> @once event,handler

  once: (event,handler) ->
    @_events.once event, handler


class Bus extends Channel
  
  scope: -> new Bus @
  
  channel: -> new Channel @
  
  # emitter: (emitter) -> 
  #   self = @
  #   emit = @emitter.emit
  #   @emitter.emit = (event,args...) ->
  #     self.send event, args...
  #     emit.apply @, [event,args...]
  #     
  callback: (fn) ->
    (args...) =>
      channel = @channel()
      fn args..., (error,results...) =>
        unless error?
          channel.emit "success", results...
        else
          channel.emit "error", error
      channel
    
  on: (event,handler) ->
    @_events.on event, handler

module.exports = Bus