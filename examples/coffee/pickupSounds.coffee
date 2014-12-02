###
pickupSounds.coffee

plays a random sound file
when the space bar is pressed
###

#name the document
document.title = 'Pickup Sounds'

#setup the environment
env.SOUND_PATH = '../sounds/'
env.USE_AUDIO_TAG = true
env.ENGINE_BOTTOM_PANEL = 'Press the space bar to hear a random sound'
env.ENGINE_LEFT_PANEL =
    '''
    <p>
    Full credit for these
    sound effects goes to
    <a href="http://opengameart.org/users/jalastram">jalastram</a>
    </p>
    '''

#declare global variables

#define init() to be called by body.onload
init = ->
    #initialize variables
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if keysDown[KEYS.SPACE]
        new Sound({
            url: "jalastram/SFX_Pickup_#{Math.round(Math.random() * 50)}.wav"
            playOnLoad: true
        })
#end update