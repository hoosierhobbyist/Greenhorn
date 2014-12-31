###
eventEmitter.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class EventEmitter
    on: (event, listener) ->
        @_once ?= {}
        @_events ?= {}
        @_events[event] ?= []
        @_events[event].push listener
        return this
    once: (event, listener) ->
        @_once ?= {}
        @_events ?= {}
        @_once[event] = listener
        return this
    emit: (event, args...) ->
        @_once ?= {}
        @_events ?= {}
        if @_once[event]?
            @_once[event].apply this, args
            delete @_once[event]
            return true
        else if @_events[event]?
            for listener in @_events[event]
                listener.apply this, args
            return true
        return false
    remove: (event, listener) ->
        @_once ?= {}
        @_events ?= {}
        if event?
            if @_once[event]?
                delete @_once[event]
            else if @_events[event]?
                if listener?
                    for fn, i in @_events[event] when fn is listener
                        @_events[event].splice i, 1
                else
                    delete @_events[event]
        else
            @_once = {}
            @_events = {}
        return this
    listeners: (event) ->
        lstnrs = []
        if @_once[event]
            lstnrs.push @_once[event]
        if @_events[event]
            lstnrs = lstnrs.concat @_events[event]
        return lstnrs

_mixin = (dest, source) ->
    for own key, value of source
        dest[key] = value
    return dest