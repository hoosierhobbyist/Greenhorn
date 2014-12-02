###
skeletonAnimation.coffee

a simple example of the AniSprite class
###

#name the document
document.title = 'Mr. Bones\' Crystal Pickup'

#setup the environment
env.IMAGE_PATH = '../images/'
env.SOUND_PATH = '../sounds/'
env.ANISPRITE_DEFAULT_CONFIG.frameRate = 10
env.ENGINE_BOTTOM_PANEL = 'Use the arrow keys to control bones and collect the crystals'
env.ENGINE_RIGHT_PANEL =
    '''
    <ul>
    <li id="blue">blue: </li>
    <li id="green">green: </li>
    <li id="grey">grey: </li>
    <li id="orange">orange: </li>
    <li id="pink">pink: </li>
    <li id="yellow">yellow: </li>
    '''

#declare global variables
bones = null
pickup = null
crystals = {}

#define init() to be called by body.onload
init = ->
    #initialize variables
    pickup = new Sound({
        url: 'jalastram/SFX_Pickup_20.wav'
    })
    
    colors = ['blue', 'green', 'grey', 'orange', 'pink', 'yellow']
    for color in colors
        crystals[color] = new AniSprite({
            imageFile: "#{color}Crystal.png"
            x: Math.random() * 400 - 200
            y: Math.random() * 300 - 150
            width: 32
            height: 32
            cycleSPIN:
                row: 1
        })
    
    bones = new AniSprite({
        imageFile: 'skeleton.png'
        boundAction: 'STOP'
        cellWidth: 64
        cellHeight: 64
        cycleUP:
            row: 9
            numFrames: 9
        cycleLEFT:
            row: 10
            numFrames: 9
        cycleDOWN:
            row: 11
            numFrames: 9
        cycleRIGHT:
            row: 12
            numFrames: 9
    })
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if keysDown[KEYS.UP]
        bones.change 'y', 50
        bones.set 'current', 'UP'
        bones.play()
    else if keysDown[KEYS.DOWN]
        bones.change 'y', -50
        bones.set 'current', 'DOWN'
        bones.play()
    else if keysDown[KEYS.RIGHT]
        bones.change 'x', 50
        bones.set 'current', 'RIGHT'
        bones.play()
    else if keysDown[KEYS.LEFT]
        bones.change 'x', -50
        bones.set 'current', 'LEFT'
        bones.play()
    else
        bones.set 'current', 'DOWN'
        bones.pause()
    
    for color, crystal of crystals
        if bones.collidesWith crystal
            pickup.play()
            crystal.set 'visible', off
            document.getElementById(color).innerHTML = "#{color}: FOUND!"
    
    Greenhorn.set 'leftPanel', 'innerHTML', bones.report()
#end update