###
timer.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Timer
    #helper function (closed over)
    currentTime = -> (new Date()).getTime()

    @DEFAULTS:
        startImmediately: true

    constructor: (startImmediately = Timer.DEFAULTS.startImmediately) ->
        @_elapsedTime = 0
        @_startTime = if startImmediately then currentTime() else null

    #getters
    isRunning: ->
        @_startTime?
    getElapsedTime: ->
        unless @_startTime
            @_elapsedTime
        else
            @_elapsedTime + currentTime() - @_startTime

    #timer control
    start: ->
        unless @_startTime
            @_startTime = currentTime()
    pause: ->
        if @_startTime
            @_elapsedTime += currentTime() - @_startTime
            @_startTime = null
    restart: ->
        @_elapsedTime = 0
        @_startTime = currentTime()
    stop: ->
        @_elapsedTime = 0
        @_startTime = null

#add to namespace object
gh.Timer = Timer
