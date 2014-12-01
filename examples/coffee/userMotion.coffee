###
userMotion.coffee

user controls the motion of
a sprite with the keyboard
###

#name the document
document.title = 'User Controlled Motion'

#setup the environment
env.IMAGE_PATH = '../images/'
env.ENGINE_BOTTOM_PANEL =
    '''
    Use the arrow keys to move
    and the space bar to spin
    '''

#declare global variables
logo = null

#define init() to be called by body.onload
init = ->
    #initialize variables
    logo = new Sprite {imageFile: 'logo.png'}
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if keysDown[KEYS.UP] then logo.change 'y', 50
    if keysDown[KEYS.DOWN] then logo.change 'y', -50
    if keysDown[KEYS.RIGHT] then logo.change 'x', 50
    if keysDown[KEYS.LEFT] then logo.change 'x', -50
    if keysDown[KEYS.SPACE] then logo.change 'a', 2
    
    Greenhorn.set 'leftPanel', 'innerHTML', logo.report()
#end update