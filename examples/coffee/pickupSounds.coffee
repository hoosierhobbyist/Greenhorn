###
pickupSounds.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Pickup Sounds'

#setup the environment
env.SOUND_PATH = './sounds/'
env.USE_AUDIO_TAG = true
env.ENGINE.rightHeader = 'BUTTONS'
env.ENGINE.leftHeader = 'INFORMATION'

#declare global variables
sndFx = new Array(50)

#define init() to set up the document
init = ->
    #start the engine
    Greenhorn.start()

    #create the sounds and add buttons
    for snd, i in sndFx
        sndFx[i] = new Sound({url: "SFX_Pickup_#{i + 1}.wav"})
        Greenhorn.addButton({label: "Play ##{i + 1}", onclick: ->
            sndFx[i].play()
        })#end Play button

    #set leftPanel content
    information =
        '''
        <div>
        <h4>Instructions</h4>
        <p style='margin: 0'>
        Use the buttons on the left to play
        a collection of 8-bit pickup sounds
        freely available on
        <a href='http://opengameart.org'>OpenGameArt.org</a>.
        </p>
        <h4>Acknowledgement</h4>
        <p style='margin: 0'>
        Full credit for these sound effects goes to
        opengameart user
        <a href="http://opengameart.org/users/jalastram">jalastram</a>
        </p>
        </div>
        '''
    $('#gh-left-panel').append(information)
#end init
