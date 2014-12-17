###
bouncingLogos.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Bouncing Ubuntu Logos'

#setup the environment
env.IMAGE_PATH = '../images/'
env.ENGINE.leftHeader = 'INFORMATION'
env.ENGINE.rightHeader = 'BUTTONS'
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

    #add control buttons
    Greenhorn.addButton({label: 'Start', onclick: ->
        Greenhorn.start()
    })#end Start
    Greenhorn.addButton({label: 'Stop', onclick: ->
        Greenhorn.stop()
    })#end Stop
    Greenhorn.addButton({label: 'Add One', onclick: ->
        new Sprite(randomConfig())
    })#end Add One
    Greenhorn.addButton({label: 'Add Five', onclick: ->
        i = 5
        while i > 0
            i -= 1
            new Sprite(randomConfig())
    })#end Add Five
    Greenhorn.addButton({label: 'Add Ten', onclick: ->
        i = 10
        while i > 0
            i -= 1
            new Sprite(randomConfig())
    })#end Add Ten
    Greenhorn.addButton({label: 'Add Fifty', onclick: ->
        i = 50
        while i > 0
            i -= 1
            new Sprite(randomConfig())
    })#end Add Fifty
    Greenhorn.addButton({label: 'Remove All', onclick: ->
        Sprites.removeAll()
    })#end Remove All

    #add content to gh-left-panel
    information =
        '''
        <div>
        <h4>Instructions</h4>
        <p style='margin:0'>
        Use the Buttons on the left hand side
        to start and stop the engine, or add
        and remove Ubuntu Logos.
        </p>
        <h4>Trademark</h4>
        <p style='margin:0'>
        Please note that the logo used in this
        example, which is known as
        The Circle of Friends,
        is a registered trademark of
        Canonical Ltd.
        </p>
        </div>
        '''
    $('#gh-left-panel').append(information)

    #create random number of logos to start
    i = Math.round(Math.random() * 9 + 1)
    while i > 0
        i -= 1
        new Sprite(randomConfig())

#define update() to be called once per frame
update = ->
    #report current number of Sprites
    $('#gh-title').html("#{document.title}: #{Sprites.howMany()}")
