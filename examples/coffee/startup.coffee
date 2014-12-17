###
startup.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Heroic Minority'

#setup the environment
env.SOUND_PATH = '../sounds/'
env.USE_AUDIO_TAG = true

#define init() to set up document
init = ->
    #start the engine
    Greenhorn.start()

    #initialize background music
    new Sound({
        url: 'heroic_minority.mp3'
        playOnLoad: true
    })
#end init
