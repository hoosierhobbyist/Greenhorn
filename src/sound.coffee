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
    constructor: (url = env.SOUND_DEFAULT_URL) ->
        #instance variables
        @_url = env.SOUND_PATH.concat url
        @_source = _audioContext.createBufferSource()
        
        #request setup
        request = new XMLHttpRequest()
        request.responseType = 'arraybuffer'
        request.open 'GET', @_url, true
        
        #request event handlers
        request.successCallback = (buffer) =>
            @_source.buffer = buffer
            @_source.connect _audioContext.destination
        request.errorCallback = ->
            throw new Error "AudioContext Error"
        request.onload = ->
            _audioContext.decodeAudioData @response, @successCallback, @errorCallback
        
        #send request
        request.send()
    
    #sound control
    play: (opt = {}) ->
        @_source.loop = opt.loop ? false
        @_source.start 0
    stop: ->
        @_source.stop 0
#end class Sound
