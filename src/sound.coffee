###
sound.coffee

Greenhorn Gaming Engine Sound class
###

#anything attached to game
#is a part of the public API
game = exports ? this

#bring in dependancies
{env} = require './environment'
{Greenhorn} = require './greenhorn'

#audio context for webkit browsers
_webkitAudioContext = new webkitAudioContext?()

#simple sound class
class game.Sound
    #constructor
    constructor: (url = env.SOUND_DEFAULT_URL) ->
        #instance variable
        @_url = env.SOUND_PATH.concat url
        
        if webkitAudioContext?
            #webkit instance variables
            @_source = _webkitAudioContext.createBufferSource()
            @_gainNode = _webkitAudioContext.createGainNode()
            
            #request setup
            request = new XMLHttpRequest()
            request.responseType = 'arraybuffer'
            request.open 'GET', @_url, true
            
            #request event handlers
            request.successCallback = (buffer) =>
                @_source.buffer = buffer
                @_source.connect @_gainNode
                @_gainNode.connect _webkitAudioContext.destination
                return
            request.failureCallback = ->
                throw new Error "Webkit Sound Error"
            request.onload = ->
                _webkitAudioContext.decodeAudioData @response, @successCallback, @failureCallback
            
            #send request
            request.send()
        
        else
            #non-webkit instance variable
            @_audio = document.createElement 'audio'
            @_audio.setAttribute 'controls', 'none'
            @_audio.style.display = 'none'
            
            #_audio sources
            mp3_src = document.createElement 'source'
            ogg_src = document.createElement 'source'
            wav_src = document.createElement 'source'
            
            mp3_src.type = 'audio/mpeg'
            ogg_src.type = 'audio/ogg'
            wav_src.type = 'audio/wav'
            
            #determine source extension
            if @_url.indexOf('.mp3') isnt -1
                mp3_src.src = @_url
                ogg_src.src = @_url.replace '.mp3', '.ogg'
                wav_src.src = @_url.replace '.mp3', '.wav'
            else if @_url.indexOf('.ogg') isnt -1
                ogg_src.src = @_url
                mp3_src.src = @_url.replace '.ogg', '.mp3'
                wav_src.src = @_url.replace '.ogg', '.wav'
            else if @_url.indexOf('.wav') isnt -1
                wav_src.src = @_url
                mp3_src.src = @_url.replace '.wav', '.mp3'
                ogg_src.src = @_url.replace '.wav', '.ogg'
            else throw new Error "Sound url must be .mp3, .ogg, or .wav extension"
            
            #append sources to audio tag
            @_audio.appendChild mp3_src
            @_audio.appendChild ogg_src
            @_audio.appendChild wav_src
            
            #append audio tag to document body
            Greenhorn._elmnts.canvas.appendChild @_audio
        return
    
    #sound control
    play: (opt = {}) ->
        if webkitAudioContext?
            @_gainNode.gain.value = opt.gainValue if opt.gainValue?
            @_source.loop = opt.loop if opt.loop?
            @_source.start 0
        else
            @_audio.loop = opt.loop if opt.loop?
            @_audio.play()
        return
    stop: ->
        if webkitAudioContext?
            @_source.stop 0
        else
            @_audio.pause()
            @_audio.currentTime = 0
        return
#end class Sound