###
eventEmitter.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class EventEmitter
    on: (event, listener, options = {}) ->
        @_events ?= {}
        @_events[event] ?= []
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
            return true
        return false
    remove: (event, listener) ->
        @_events ?= {}
        if event?
            if @_events[event]?
                if listener?
                    for fn, i in @_events[event] when fn is listener
                        @_events[event].splice i, 1
                else
                    delete @_events[event]
        else
            @_events = {}
        return this
    listeners: (event) ->
        if event? then @_events[event]
        else @_events

_mixin = (dest, source) ->
    for own key, value of source
        dest[key] = value
    return dest