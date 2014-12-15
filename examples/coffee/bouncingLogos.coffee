###
bouncingLogos.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Bouncing Logos'

#setup the environment
env.IMAGE_PATH = '../images/'
env.ENGINE.footer = '\\/ Check out the source code below \\/'
env.SPRITE_DEFAULT_CONFIG.ddy = -50
env.SPRITE_DEFAULT_CONFIG.imageFile = 'logo.png'
env.SPRITE_DEFAULT_CONFIG.boundAction = 'BOUNCE'

#helper function to randomize Sprite config objects
randomConfig = ->
    size = Math.round(Math.random() * 64 + 32)
    {
        width: size
        height: size
        da: Math.random() * 2 - 1
        dx: Math.random() * 50 - 25
        x: Math.random() * env.ENGINE.canvasWidth - env.ENGINE.canvasWidth / 2
        y: Math.random() * env.ENGINE.canvasHeight - env.ENGINE.canvasHeight / 2
    }

#define init() to set up the document
init = ->
    #start the engine
    Greenhorn.start()

    #create random number of logos to start
    i = Math.round(Math.random() * 9 + 1)
    while i > 0
        i -= 1
        new Sprite(randomConfig())

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if Greenhorn.isDown[KEYS.SPACE] then new Sprite(randomConfig())
