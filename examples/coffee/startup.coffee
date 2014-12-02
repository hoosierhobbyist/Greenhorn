###
startup.coffee

The absolute minimum that needs to
be done in order to create a Greenhorn page
###

#name the document
document.title = 'Startup Page'

#setup the environment
env.SOUND_PATH = '../sounds/'
env.USE_AUDIO_TAG = true
env.ENGINE_BOTTOM_PANEL = 'I found this background track <a href="http://opengameart.org/content/heroic-minority">here</a>.'

#declare global variables

#define init() to be called by body.onload
init = ->
    #initialize variables
    new Sound({
        url: 'heroic_minority.mp3'
        playOnLoad: true
    })
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    
#end update