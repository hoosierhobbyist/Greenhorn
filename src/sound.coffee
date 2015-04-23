###
sound.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Sound
    #closures
    _list = []
    _play = (opt) ->
        #create audio nodes
        gainNode = audioContext.createGain()
        @_source = audioContext.createBufferSource()

        #set values on source node
        @_source.buffer = @_buffer
        @_source.loop = opt.loop ? @_config.loop
        @_source.onended = =>
            @_isEnded = true
            @_elapsedTime += audioContext.currentTime - @_startTime
            if @_elapsedTime >= @_buffer.duration
                @_elapsedTime = 0

        #set value on gain node
        gainNode.gain.value = opt.volume ? @_config.volume

        #connect nodes
        @_source.connect gainNode
        gainNode.connect audioContext.destination

        #record start time
        @_startTime = audioContext.currentTime

        #start playing
        @_source.start @_startTime, @_elapsedTime

    #class level objects
    @config:
        path: './'
        useAudioTag: false
    @defaults:
        url: ""
        loop: false
        volume: 1.0
        autoplay: false

    #determine what kind of AudioContext is avaliable
    if window.AudioContext? or window.webkitAudioContext?
        AudioContext = window.AudioContext ? window.webkitAudioContext
        audioContext = new AudioContext()
    else
        Sound.config.useAudioTag = true

    #Sound class methods
    @_playAll = ->
        for snd in _list
            if snd._config.autoplay
                snd.play()
            else
                snd.play volume: 0, loop: false
                setTimeout (-> snd.stop()), 50 #FIX: closure issue?
        return
    @_pauseAll = ->
        snd.pause() for snd in _list
        return
    @_stopAll = ->
        snd.stop() for snd in _list
        return

    constructor: (@_config = {}) ->
        #assign default values if they have been omitted
        for own key, value of Sound.defaults
            @_config[key] ?= value

        #prefix the sound path
        unless /(^\w+:\/\/|^\/)/.test @_config.url
            if /\/$/.test Sound.config.path
                @_config.url = Sound.config.path + @_config.url
            else if Sound.config.path
                Sound.config.path += '/'
                @_config.url = Sound.config.path + @_config.url

        #not using web audio api
        if Sound.config.useAudioTag
            #instance variable
            @_audio = document.createElement 'audio'
            #source elements for this._audio
            mp3_src = document.createElement 'source'
            ogg_src = document.createElement 'source'
            wav_src = document.createElement 'source'

            #assign proper types
            mp3_src.type = 'audio/mpeg'
            ogg_src.type = 'audio/ogg'
            wav_src.type = 'audio/wav'

            #assign proper srcs
            if /\.mp3$/.test @_config.url
                mp3_src.src = @_config.url
                ogg_src.src = @_config.url.replace '.mp3', '.ogg'
                wav_src.src = @_config.url.replace '.mp3', '.wav'
            else if /\.ogg$/.test @_config.url
                ogg_src.src = @_config.url
                mp3_src.src = @_config.url.replace '.ogg', '.mp3'
                wav_src.src = @_config.url.replace '.ogg', '.wav'
            else if /\.wav$/.test @_config.url
                wav_src.src = @_config.url
                mp3_src.src = @_config.url.replace '.wav', '.mp3'
                ogg_src.src = @_config.url.replace '.wav', '.ogg'
            else
                throw new Error "Only .mp3, .ogg, and .wav file extensions are supported by the audio tag"

            #append sources to this._audio
            @_audio.appendChild mp3_src
            @_audio.appendChild ogg_src
            @_audio.appendChild wav_src

            #set autoplay if approprite
            if Greenhorn.isRunning() and @_config.autoplay
                @_audio.autoplay = true

        #using web audio API
        else
            #instance variables
            @_source = null
            @_buffer = null
            @_isEnded = true
            @_startTime = 0
            @_elapsedTime = 0

            #request setup
            request = new XMLHttpRequest()
            request.open 'GET', @_config.url, true
            request.responseType = 'arraybuffer'

            #request event handlers
            request.successCallback = (@_buffer) =>
                if Greenhorn.isRunning() and @_config.autoplay then @play()
            request.errorCallback = ->
                console.log "could not load sound file at url: #{@_config.url}"
            request.onload = ->
                audioContext.decodeAudioData @response, @successCallback, @errorCallback

            #send request
            request.send()

        #add this to Sound list
        _list.push this

    #sound status
    isPlaying: ->
        if @_audio?
            !(@_audio.paused or @_audio.ended)
        else
            !@_isEnded
    elapsedTime: ->
        if @_audio?
            @_audio.currentTime * 1000
        else
            @_elapsedTime + audioContext.currentTime - @_startTime

    #sound control
    play: (opt = {}) ->
        if Greenhorn.isRunning()
            if @_audio?
                @_audio.loop = opt.loop ? @_config.loop
                @_audio.volume = opt.volume ? @_config.volume
                @_audio.play()
            else
                if @_isEnded
                    #set isEnded to false
                    @_isEnded = false
                    _play.call this, opt

    restart: (opt = {}) ->
        if Greenhorn.isRunning()
            if @_audio?
                @_audio.pause()
                @_audio.currentTime = 0
                @_audio.loop = opt.loop ? @_config.loop
                @_audio.volume = opt.volume ? @_config.volume
                @_audio.play()
            else
                #stop source
                @_source.stop()
                @_elapsedTime = 0
                _play.call this, opt

    pause: ->
        if Greenhorn.isRunning()
            if @_audio?
                @_audio.pause()
            else
                @_source.stop()

    stop: ->
        if Greenhorn.isRunning()
            if @_audio?
                @_audio.pause()
                @_audio.currentTime = 0
            else
                @_source.stop()
                @_elapsedTime = 0

#add to namespace object
gh.Sound = Sound
