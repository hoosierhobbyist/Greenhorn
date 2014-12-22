###
skeletonAnimation.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Bonehead\'s Crystal Pickup'

#setup the environment
env.IMAGE_PATH = '../images/'
env.SOUND_PATH = '../sounds/'
env.USE_AUDIO_TAG = true
env.ENGINE.leftHeader = 'Bonehead Report'
env.ENGINE.rightHeader = 'Crystals'
env.SPRITE_DEFAULT_CONFIG.boundAction = 'STOP'
env.ANICYCLE_DEFAULT_CONFIG.name = 'SPIN'

#declare global variables
bonehead= null
pickup = null
crystals = {}

#define init() to setup document
init = ->
    #start the engine
    Greenhorn.start()
    
    #initialize variables
    pickup = new Sound({
        url: 'jalastram/SFX_Pickup_20.wav'
    })#end pickup construction
    
    colors = ['blue', 'green', 'grey', 'orange', 'pink', 'yellow']
    for color in colors
        crystals[color] = new AniSprite(
            imageFile: "crystals/#{color}Crystal.png"
            x: Math.random() * env.ENGINE.canvasWidth - env.ENGINE.canvasWidth / 2
            y: Math.random() * env.ENGINE.canvasHeight - env.ENGINE.canvasHeight / 2
            width: 32
            height: 32
            cycle1:
                index: 1
        )#end cyrstal construction
    
    bonehead = new AniSprite(
        imageFile: 'bonehead.png'
        cellWidth: 64
        cellHeight: 64
        frameRate: 23
        cycleSTAND_UP:
            index: 9
            start: 1
            stop: 1
        cycleSTAND_LEFT:
            index: 10
            start: 1
            stop: 1
        cycleSTAND_DOWN:
            index: 11
            start: 1
            stop: 1
        cycleSTAND_RIGHT:
            index: 12
            start: 1
            stop: 1
        cycleWALK_UP:
            index: 9
            start: 2
        cycleWALK_LEFT:
            index: 10
            start: 2
        cycleWALK_DOWN:
            index: 11
            start: 2
        cycleWALK_RIGHT:
            index: 12
            start: 2
    )#end bonehead construction
    
    #document specific setup
    $('#gh-left-panel').append('<pre></pre>')
    $('#gh-right-panel').append('<p></p>')
    $('#gh-right-panel p').html(
        '''
        <ul>
        <li id="blue">BLUE: </li>
        <li id="green">GREEN: </li>
        <li id="grey">GREY: </li>
        <li id="orange">ORANGE: </li>
        <li id="pink">PIND: </li>
        <li id="yellow">YELLOW: </li>
        </ul>
        '''
    )#end rightPanel setup
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if Greenhorn.isDown[KEYS.UP]
        bonehead
            .set 'animation', 'WALK_UP'
            .change 'y', 50
    else if Greenhorn.isDown[KEYS.DOWN]
        bonehead
            .set 'animation', 'WALK_DOWN'
            .change 'y', -50
    else if Greenhorn.isDown[KEYS.RIGHT]
        bonehead
            .set 'animation', 'WALK_RIGHT'
            .change 'x', 50
    else if Greenhorn.isDown[KEYS.LEFT]
        bonehead
            .set 'animation', 'WALK_LEFT'
            .change 'x', -50
    else
        direction = bonehead.get('cycle').match(/(UP|LEFT|DOWN|RIGHT)/)[0];
        bonehead.set('animation', 'STAND_' + direction);
    
    for color, crystal of crystals
        if bonehead.collidesWith crystal
            pickup.play()
            crystal.set 'visible', off
            document.getElementById(color).innerHTML = "#{color.toUpperCase()}: FOUND!"
    
    $('#gh-left-panel pre').html(bonehead.report())
#end update