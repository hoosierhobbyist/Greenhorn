###
timer.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#simple timer class
class @Timer
    #constructor
    constructor: (start_now = env.TIMER_START_ON_CONSTRUCTION) ->
        @_elapsedTime = 0
        @_startTime = if start_now then @getCurrentTime() else null
        return this
    
    #getters
    getStartTime: -> @_startTime
    getCurrentTime: -> (new Date()).getTime()
    getElapsedTime: ->
        unless @_startTime
            @_elapsedTime
        else
            @_elapsedTime + @getCurrentTime() - @_startTime
    
    #timer control
    start: ->
        unless @_startTime
            @_startTime = @getCurrentTime()
            return
    pause: ->
        if @_startTime
            @_elapsedTime += @getCurrentTime() - @getStartTime()
            @_startTime = null
            return
    restart: ->
        @_elapsedTime = 0
        @_startTime = @getCurrentTime()
        return
    stop: ->
        @_elapsedTime = 0
        @_startTime = null
        return
#end class Timer