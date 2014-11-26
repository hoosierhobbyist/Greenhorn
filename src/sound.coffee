###
sound.coffee

Greenhorn Gaming Engine Sound class
###

#determine what kind of AudioContext is avaliable
AudioContext = @AudioContext ? @webkitAudioContext

#instance of AudioContext
_audioContext = new AudioContext()

#simple sound class
class @Sound
    #constructor
    constructor: (url = env.SOUND_DEFAULT_URL, playOnLoad = false) ->
        #instance variables
        @_buffer = null
        @_source = null
        @_url = env.SOUND_PATH.concat url
        
        #request setup
        request = new XMLHttpRequest()
        request.open 'GET', @_url, true
        request.responseType = 'arraybuffer'
        
        #request event handlers
        request.successCallback = (buffer) =>
            @_buffer = buffer
            @play() if playOnLoad
        request.errorCallback = ->
            throw new Error "AudioContext Error"
        request.onload = ->
            _audioContext.decodeAudioData @response, @successCallback, @errorCallback
        
        #send request
        request.send()
    
    #sound control
    play: (opt = {}) ->
        @_source = _audioContext.createBufferSource()
        @_source.buffer = @_buffer
        @_source.loop = opt.loop ? false
        @_source.connect _audioContext.destination
        @_source.start 0
    stop: ->
        @_source.stop 0
#end class Sound
