###
sound.coffee

Greenhorn Gaming Engine Sound class
###

#determine what kind of AudioContext is avaliable
if @AudioContext? or @webkitAudioContext?
    AudioContext = @AudioContext ? @webkitAudioContext
    _audioContext = new AudioContext()
else
    env.USE_AUDIO_TAG = true

#simple sound class
class @Sound
    #constructor
    constructor: (config = {}) ->
        #assign default values if they have been omitted
        for own key, value of env.SOUND_DEFAULT_CONFIG
            config[key] ?= value
        
        #prefix the environment sound path
        config.url = env.SOUND_PATH.concat config.url
        
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
            if config.url.indexOf('.mp3') isnt -1
                mp3_src.src = config.url
                ogg_src.src = config.url.replace '.mp3', '.ogg'
                wav_src.src = config.url.replace '.mp3', '.wav'
            else if config.url.indexOf('.ogg') isnt -1
                ogg_src.src = config.url
                mp3_src.src = config.url.replace '.ogg', '.mp3'
                wav_src.src = config.url.replace '.ogg', '.wav'
            else if config.url.indexOf('.wav') isnt -1
                wav_src.src = config.url
                mp3_src.src = config.url.replace '.wav', '.mp3'
                ogg_src.src = config.url.replace '.wav', '.ogg'
            else
                throw new Error "Only .mp3, .ogg, and .wav file extensions are supported by the audio tag"
            
            #append sources to this._audio
            @_audio.appendChild mp3_src
            @_audio.appendChild ogg_src
            @_audio.appendChild wav_src
            
            if config.playOnLoad then @_audio.autoplay = true
        
        else
            #instance variables
            @_buffer = null
            @_source = null
            @_isEnded = true
            
            #request setup
            request = new XMLHttpRequest()
            request.open 'GET', config.url, true
            request.responseType = 'arraybuffer'
            
            #request event handlers
            request.successCallback = (buffer) =>
                @_buffer = buffer
                if config.playOnLoad then @play()
            request.errorCallback = ->
                throw new Error "Web Audio API Error"
            request.onload = ->
                _audioContext.decodeAudioData @response, @successCallback, @errorCallback
            
            #send request
            request.send()
    
    #sound control
    play: (opt = {}) ->
        if env.USE_AUDIO_TAG
            @_audio.loop = opt.loop ? false
            @_audio.volume = opt.volume ? 1.0
            @_audio.play()
        else
            if @_isEnded
                gainNode = _audioContext.createGain()
                gainNode.gain.value = opt.volume ? 1.0
                
                @_isEnded = false
                @_source = _audioContext.createBufferSource()
                @_source.buffer = @_buffer
                @_source.onended = =>
                    @_isEnded = true
                
                @_source.loop = opt.loop ? false
                @_source.connect gainNode
                gainNode.connect _audioContext.destination
                @_source.start()
    stop: ->
        if env.USE_AUDIO_TAG
            @_audio.pause()
            @_audio.currentTime = 0
        else
            @_source.stop()
#end class Sound
