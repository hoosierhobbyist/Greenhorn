###
skeletonAnimation.coffee

a simple example of the AniSprite class
###

#name the document
document.title = 'Skeleton Animation'

#setup the environment
env.IMAGE_PATH = '../images/'
env.ANISPRITE_DEFAULT_CONFIG.numFrames = 9

#declare global variables
bones = null

#define init() to be called by body.onload
init = ->
    #initialize variables
    bones = new AniSprite({
        imageFile: 'skeleton.png'
        frameRate: 8
        sheetWidth: 576
        sheetHeight: 256
        cellWidth: 64
        cellHeight: 64
        cycleUP:
            row: 9
        cycleLEFT:
            row: 10
        cycleDOWN:
            row: 11
        cycleRIGHT:
            row: 12
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
    
    Greenhorn.set 'bottomPanel', 'innerHTML', bones._dis.timer.getElapsedTime()
#end update