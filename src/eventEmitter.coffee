###
eventEmitter.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class EventEmitter
    on: (event, listener, options = {}) ->
        @_events ?= {}
        unless @_events[event]
            @emit 'event:added', event
            @_events[event] = []
        @emit 'listener:added', event, listener
        @_events[event].push listener
        for own key, value of options
            @_events[event][key] = value
        return this
    once: (event, listener, options = {}) ->
        listener.once = true
        @on event, listener, options
    emit: (event, args...) ->
        @_events ?= {}
        if @_events[event]?
            for listener in @_events[event]
                listener.apply this, args
                if listener.once?
                    i = @_events[event].indexOf listener
                    @_events[event].splice i, 1
                    if @_events[event].length is 0
                        delete @_events[event]
            return true
        return false
    remove: (event, listener) ->
        @_events ?= {}
        if @_events[event]?
            if listener?
                for cb, i in @_events[event] when cb is listener
                    @emit 'listener:removed', event, listener
                    @_events[event].splice i, 1
                    if @_events[event].length is 0
                        @emit 'event:removed', event
                        delete @_events[event]
            else
                @emit 'event:removed', event
                delete @_events[event]
        return this
    listeners: (event) ->
        if event? then @_events[event]
        else @_events ?= {}

#conditionally add to namespace object
gh.EventEmitter = EventEmitter if GH_INCLUDE_PRIVATE_API
