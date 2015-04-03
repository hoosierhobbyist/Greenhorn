###
eventEmitter.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class EventEmitter
    constructor: ->
        @_events = {}

    on: (event, listener, options = {}) ->
        unless @_events[event]
            @_events[event] = []
            unless event is 'event:added'
                @emit 'event:added', event
        @_events[event].push listener
        unless event is 'listener:added' or event is 'event:added'
            @emit 'listener:added', event, listener
        for own key, value of options
            @_events[event][key] = value
        return this

    once: (event, listener, options = {}) ->
        wrapper = (args...) ->
            listener.apply this, args
            @remove event, wrapper

        @on event, wrapper, options

    emit: (event, args...) ->
        if @_events[event]?
            for listener in @_events[event]
                listener.apply this, args
            if @_events[event].length is 0
                delete @_events[event]
            return true
        return false

    remove: (event, listener) ->
        if @_events[event]?
            if listener?
                i = @_events[event].indexOf listener
                if i isnt -1
                    @_events[event].splice i, 1
                    @emit 'listener:removed', event, listener
                    if @_events[event].length is 0
                        @emit 'event:removed', event
                        delete @_events[event]
                    return true
                else
                    return false
            else
                listeners = @_events[event].slice 0
                delete @_events[event]
                @emit 'event:removed', event, listeners
                return true
        return false

    listeners: (event) ->
        if event?
            @_events[event] ? false
        else
            @_events

#conditionally add to namespace object
gh.EventEmitter = EventEmitter if GH_INCLUDE_PRIVATE_API
