###
skeletonAnimation.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Bonehead\'s Crystal Pickup'

#setup the environment
env.IMAGE_PATH = '../images/'
env.SOUND_PATH = '../sounds/jalastram/'
env.USE_AUDIO_TAG = true
env.ENGINE.leftHeader = 'REPORT'
env.ENGINE.rightHeader = 'CRYSTALS'
env.SPRITE_DEFAULT_CONFIG.boundAction = 'STOP'
env.ANICYCLE_DEFAULT_CONFIG.name = 'SPIN'

#declare global variables
bonehead= null
pickupSnd = null
crystals = {}

#define init() to setup document
@init = ->
    #start the engine
    Greenhorn.start()
    
    #initialize variables
    pickupSnd = new Sound url: 'SFX_Pickup_20.wav'
    
    canvasWidth = $('#gh-canvas')[0].width
    canvasHeight = $('#gh-canvas')[0].height
    colors = ['blue', 'green', 'grey', 'orange', 'pink', 'yellow']
    
    for color in colors
        crystals[color] = new AniSprite
            imageFile: "crystals/#{color}Crystal.png"
            x: Math.random() * canvasWidth - canvasWidth / 2
            y: Math.random() * canvasHeight - canvasHeight / 2
            width: 32
            height: 32
            cycle: {}
    
    bonehead = new AniSprite
        imageFile: 'bonehead.png'
        cellWidth: 64
        cellHeight: 64
        frameRate: 23
        current: 'STAND_DOWN'
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
    
    #document specific setup
    $('#gh-left-panel').append('<pre></pre>')
    $('#gh-right-panel').append(
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

#define update() to be called once per frame
@update = ->
    #handle any game specific events here
    if Greenhorn.isDown[KEYS.UP]
        bonehead
            .change 'y', 50
            .set 'animation', 'WALK_UP'
    else if Greenhorn.isDown[KEYS.DOWN]
        bonehead
            .change 'y', -50
            .set 'animation', 'WALK_DOWN'
    else if Greenhorn.isDown[KEYS.RIGHT]
        bonehead
            .change 'x', 50
            .set 'animation', 'WALK_RIGHT'
    else if Greenhorn.isDown[KEYS.LEFT]
        bonehead
            .change 'x', -50
            .set 'animation', 'WALK_LEFT'
    else
        direction = bonehead.get('current').match(/(UP|LEFT|DOWN|RIGHT)/)[0]
        bonehead.set 'animation', "STAND_#{direction}"
    
    for color, crystal of crystals
        if bonehead.collidesWith crystal
            pickupSnd.play()
            crystal.set 'visible', off
            $("##{color}").html "#{color.toUpperCase()}: FOUND!"
    
    $('#gh-left-panel pre').html bonehead.report()