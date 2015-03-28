###
timer.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Timer
    constructor: (start_now = env.TIMER_START_ON_CONSTRUCTION) ->
        @_elapsedTime = 0
        @_startTime = if start_now then @getCurrentTime() else null
    
    #getters
    getStartTime: ->
        @_startTime
    getCurrentTime: ->
        (new Date()).getTime()
    getElapsedTime: ->
        unless @_startTime
            @_elapsedTime
        else
            @_elapsedTime + @getCurrentTime() - @_startTime
    
    #timer control
    start: ->
        unless @_startTime
            @_startTime = @getCurrentTime()
    pause: ->
        if @_startTime
            @_elapsedTime += @getCurrentTime() - @getStartTime()
            @_startTime = null
    restart: ->
        @_elapsedTime = 0
        @_startTime = @getCurrentTime()
    stop: ->
        @_elapsedTime = 0
        @_startTime = null

#add to namespace object
gh.Timer = Timer
