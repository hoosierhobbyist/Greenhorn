###
sound.coffee

Greenhorn Gaming Engine Sound class
###

#determine what kind of AudioContext is avaliable
if window.AudioContext? or window.webkitAudioContext?
    AudioContext = window.AudioContext ? window.webkitAudioContext
    _audioContext = new AudioContext()
else
    env.USE_AUDIO_TAG = true

#simple sound class
class @Sound
    #<---CLASS LEVEL--->
    #used to track all Sound instances
    _list = []
    
    #Sound class methods
    @_playAll = ->
        for snd in _list
            if snd._config.playOnLoad
                if env.USE_AUDIO_TAG
                    snd._audio.autoplay = true
                else 
                    snd.play()
            else
                snd.play {volume: 0, loop: false}
                setTimeout snd.stop, 50
    @_stopAll = ->
        snd.stop() for snd in _list
        return
    
    #<---INSTANCE LEVEL--->
    #constructor
    constructor: (@_config = {}) ->
        #assign default values if they have been omitted
        for own key, value of env.SOUND_DEFAULT_CONFIG
            @_config[key] ?= value
        
        #prefix the environment sound path
        @_config.url = env.SOUND_PATH.concat @_config.url
        
        #if the user has chosen to use the audio tag
        #or the current browser doesn't support the web audio api (IE)
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
            if Greenhorn.isRunning() and @_config.playOnLoad
                @_audio.autoplay = true
        
        #web audio API is supported
        else
            #instance variables
            @_source = null
            @_buffer = null
            @_isEnded = true
            
            #request setup
            request = new XMLHttpRequest()
            request.open 'GET', @_config.url, true
            request.responseType = 'arraybuffer'
            
            #request event handlers
            request.successCallback = (buffer) =>
                @_buffer = buffer
                if Greenhorn.isRunning() and @_config.playOnLoad
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
    play: (opt = {}) ->
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
                
                #set value on gain node
                gainNode.gain.value = opt.volume ? @_config.volume
                
                #connect nodes
                @_source.connect gainNode
                gainNode.connect _audioContext.destination
                
                #start playing
                @_source.start()
    stop: ->
        if env.USE_AUDIO_TAG
            @_audio.pause()
            @_audio.currentTime = 0
        else
            @_source.stop()
#end class Sound

#more natural alias for calling class methods
@Sounds = @Sound
