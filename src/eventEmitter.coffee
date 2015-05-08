###
eventEmitter.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#namespace object
@gh = Object.create null

class EventEmitter
    constructor: ->
        @_events = {}
        @_expired = []

    on: (event, listener, options = {}) ->
        @_events[event] ?= []
        @_events[event].push listener
        for own key, value of options
            @_events[event][key] = value
        return this

    once: (event, listener, options = {}) ->
        wrapper = ->
            listener.apply this, arguments
            index = @_events[event].indexOf wrapper
            @_expired.push index
        wrapper['gh-original'] = listener
        @on event, wrapper, options

    emit: (event, args...) ->
        if @_events[event]?
            for listener in @_events[event]
                listener.apply this, args
            if @_expired.length
                for index, i in @_expired
                    @_events[event].splice index, 1
                    for j in [i...@_expired.length]
                        @_expired[j] -= 1
                @_expired = []
            return true
        return false

    remove: (event, listener) ->
        if @_events[event]?
            if listener?
                i = @_events[event].indexOf listener
                if i > -1
                    @_events[event].splice i, 1
                    if @_events[event].length is 0
                        delete @_events[event]
                    return true
                else
                    for wrapper, index in @_events[event]
                        if wrapper['gh-original'] is listener
                            @_events[event].splice index, 1
                            if @_events[event].length is 0
                                delete @_events[event]
                            return true
                    return false
            else
                delete @_events[event]
                return true
        return false

    listeners: (event) ->
        if event? then @_events[event] ? false
        else @_events

#add to namespace object
gh.EventEmitter = EventEmitter
