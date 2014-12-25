###
boneheadsCrystalPickup.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Bonehead\'s Crystal Pickup'

#bring in needed classes
{env, Greenhorn, AniSprite, Sound, KEYS} = gh

#setup the environment
env.IMAGE_PATH = '../images/'
env.SOUND_PATH = '../sounds/jalastram/'
env.ENGINE.leftHeader = 'INFORMATION'
env.ENGINE.rightHeader = 'CRYSTALS'
env.SPRITE_DEFAULT_CONFIG.boundAction = 'STOP'
env.ANICYCLE_DEFAULT_CONFIG.name = 'SPIN'

#declare global variables
bonehead= null
pickupSnd = null
crystals = {}

#define init() to setup document
gh.init = ->
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
    $('#gh-left-panel').append(
        '''
        <h4 class='gh-sub-h'>Instructions</h4>
        <p class='gh-p'>
        Use the arrow keys to move Bonehead and collect the
        colored crystals.
        </p>
        <h4 class='gh-sub-h'>Acknowledgements</h4>
        <p class='gh-p'>
        The 'bonehead.png' sprite sheet used for this example
        was generated using <a class='gh-a' 
        href='http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator'>
        this</a> tool. Which uses open-source resources that were created
        in what's know as the <a class='gh-a' 
        href='http://lpc.opengameart.org'>Liberated Pixel Cup</a>, which was sponsered
        by <a class='gh-a' href='http://opengameart.org'>OpenGameArt.org</a>.
        </p>
        <h4 class='gh-sub-h'>Discussion</h4>
        <p class='gh-p'>
        This example is a full demonstration of the Greenhorn AniSprite class.
        To better understand what's going on, check out the source code, or the
        documentation (coming soon).
        </p>
        ''')
    $('#gh-right-panel').append(
        '''
        <ul>
        <li id="blue">BLUE: </li>
        <li id="green">GREEN: </li>
        <li id="grey">GREY: </li>
        <li id="orange">ORANGE: </li>
        <li id="pink">PINK: </li>
        <li id="yellow">YELLOW: </li>
        </ul>
        ''')

#define update() to be called once per frame
gh.update = ->
    #move bonehead
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
    
    #check for collisions
    for color, crystal of crystals
        if bonehead.collidesWith crystal
            pickupSnd.play()
            crystal.set 'visible', off
            $("##{color}").html "#{color.toUpperCase()}: FOUND!"