###
bouncingLogos.coffee

the classic bouncing ball
demonstration using the ubuntu logo
###

#name the document
document.title = 'Bouncing Logos'

#setup the environment
env.IMAGE_PATH = '../images/'
env.ENGINE_BOTTOM_PANEL = 'Press Space to add more logos'
env.SPRITE_DEFAULT_CONFIG.imageFile = 'logo.png'
env.SPRITE_DEFAULT_CONFIG.boundAction = 'BOUNCE'

#declare global variables

#helper function to randomize Sprites
randomConfig = ->
    size = Math.round(Math.random() * 64 + 32)
    {
        x: Math.random() * 400 - 200
        y: Math.random() * 300 - 150
        dx: Math.random() * 50 - 25
        da: Math.random() * 2 - 1
        width: size
        height: size
    }

#define init() to be called by body.onload
init = ->
    #initialize variables
    i = Math.round(Math.random() * 9 + 1)
    while i > 0
        i -= 1
        new Sprite(randomConfig())
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if keysDown[KEYS.SPACE] then new Sprite(randomConfig())
    
    Sprites.changeAll 'dy', -50
#end update