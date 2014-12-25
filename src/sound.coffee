###
sound.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#determine what kind of AudioContext is avaliable
if window.AudioContext? or window.webkitAudioContext?
    AudioContext = window.AudioContext ? window.webkitAudioContext
    _audioContext = new AudioContext()
else
    env.USE_AUDIO_TAG = true

class Sound
    #closure
    _list = []

    #Sound class methods
    @_playAll = ->
        for snd in _list
            if snd._config.autoplay
                snd.play()
            else
                snd.play volume: 0, loop: false
                setTimeout snd.stop, 50
        return
    @_pauseAll = ->
        snd.pause() for snd in _list
        return
    @_stopAll = ->
        snd.stop() for snd in _list
        return

    #<---INSTANCE LEVEL--->
    constructor: (@_config = {}) ->
        #assign default values if they have been omitted
        for own key, value of env.SOUND_DEFAULT_CONFIG
            @_config[key] ?= value

        #prefix the environment sound path
        if env.SOUND_PATH.match /\/$/
            @_config.url = env.SOUND_PATH.concat @_config.url
        else
            if env.SOUND_PATH
                env.SOUND_PATH += '/'
                @_config.url = env.SOUND_PATH.concat @_config.url

        #not using web audio api
        if env.USE_AUDIO_TAG
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
            if @_config.url.match /.mp3$/
                mp3_src.src = @_config.url
                ogg_src.src = @_config.url.replace '.mp3', '.ogg'
                wav_src.src = @_config.url.replace '.mp3', '.wav'
            else if @_config.url.match /.ogg$/
                ogg_src.src = @_config.url
                mp3_src.src = @_config.url.replace '.ogg', '.mp3'
                wav_src.src = @_config.url.replace '.ogg', '.wav'
            else if @_config.url.match /.wav$/
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
            request.successCallback = (buffer) =>
                @_buffer = buffer
                if Greenhorn.isRunning() and @_config.autoplay
                    @play()
            request.errorCallback = ->
                throw new Error "AJAX request Error"
            request.onload = ->
                _audioContext.decodeAudioData @response, @successCallback, @errorCallback

            #send request
            request.send()

        #add this to Sound list
        _list.push this

    #sound control
    play: (opt = {}) =>
        if Greenhorn.isRunning()
            if env.USE_AUDIO_TAG
                @_audio.loop = opt.loop ? @_config.loop
                @_audio.volume = opt.volume ? @_config.volume
                @_audio.play()
            else
                if @_isEnded
                    #set isEnded to false
                    @_isEnded = false

                    #create audio nodes
                    gainNode = _audioContext.createGain()
                    @_source = _audioContext.createBufferSource()

                    #set values on source node
                    @_source.buffer = @_buffer
                    @_source.loop = opt.loop ? @_config.loop
                    @_source.onended = =>
                        @_isEnded = true
                        @_elapsedTime = 0

                    #set value on gain node
                    gainNode.gain.value = opt.volume ? @_config.volume

                    #connect nodes
                    @_source.connect gainNode
                    gainNode.connect _audioContext.destination
                    
                    #record start time
                    @_startTime = _audioContext.currentTime

                    #start playing
                    @_source.start @_startTime, @_elapsedTime
    restart: (opt = {}) =>
        if Greenhorn.isRunning()
            if env.USE_AUDIO_TAG
                @_audio.currentTime = 0
                @_audio.loop = opt.loop ? @_config.loop
                @_audio.volume = opt.volume ? @_config.volume
                @_audio.play()
            else
                #stop source
                @_source.stop()
                @_elapsedTime = 0
                
                #create audio nodes
                gainNode = _audioContext.createGain()
                @_source = _audioContext.createBufferSource()

                #set values on source node
                @_source.buffer = @_buffer
                @_source.loop = opt.loop ? @_config.loop
                @_source.onended = =>
                    @_isEnded = true
                    @_elapsedTime = 0

                #set value on gain node
                gainNode.gain.value = opt.volume ? @_config.volume

                #connect nodes
                @_source.connect gainNode
                gainNode.connect _audioContext.destination
                
                #record start time
                @_startTime = _audioContext.currentTime

                #start playing
                @_source.start @_startTime, @_elapsedTime
    pause: =>
        if Greenhorn.isRunning()
            if env.USE_AUDIO_TAG
                @_audio.pause()
            else
                @_source.stop()
                @_elapsedTime += _audioContext.currentTime - @_startTime
    stop: =>
        if Greenhorn.isRunning()
            if env.USE_AUDIO_TAG
                @_audio.pause()
                @_audio.currentTime = 0
            else
                @_source.stop()
                @_elapsedTime = 0

#add to namespace object
gh.Sound = Sound
