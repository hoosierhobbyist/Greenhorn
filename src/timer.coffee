###
timer.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Timer
    #helper function (closed over)
    now = -> (new Date()).getTime()

    @defaults:
        startNow: true

    constructor: (config = {}) ->
        for own key, value of Timer.defaults
            config[key] ?= value

        @_elapsedTime = 0
        @_startTime = if config.startNow then now() else null

    #getters
    isRunning: ->
        @_startTime?
    getElapsedTime: ->
        unless @_startTime
            @_elapsedTime
        else
            @_elapsedTime + now() - @_startTime

    #timer control
    start: ->
        unless @_startTime
            @_startTime = now()
    pause: ->
        if @_startTime
            @_elapsedTime += now() - @_startTime
            @_startTime = null
    restart: ->
        @_elapsedTime = 0
        @_startTime = now()
    stop: ->
        @_elapsedTime = 0
        @_startTime = null

#add to namespace object
gh.Timer = Timer
