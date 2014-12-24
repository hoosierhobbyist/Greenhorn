###
circleOfFriends.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Circle of Friends'

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
    canvasWidth = $('#gh-canvas')[0].width
    canvasHeight = $('#gh-canvas')[0].height
    return {
        width: size
        height: size
        da: Math.random() * 2 - 1
        dx: Math.random() * 50 - 25
        x: Math.random() * canvasWidth - canvasWidth / 2
        y: Math.random() * canvasHeight - canvasHeight / 2
    }#end randomConfig

#define init() to set up the document
@init = ->
    #start the engine
    Greenhorn.start()

    #add control buttons and labels
    $('#gh-right-panel').append(
        '<h4 class="gh-panel-sub-header">ENGINE CONTROL</h4>')
    
    Greenhorn.addButton label: 'START', onclick: ->
        Greenhorn.start()
    
    Greenhorn.addButton label: 'PAUSE', onclick: ->
        Greenhorn.stop()
    
    $('#gh-right-panel').append(
        '<h4 class="gh-panel-sub-header">BOUND ACTIONS</h4>')
    
    Greenhorn.addButton label: 'BOUNCE', onclick: ->
        env.SPRITE_DEFAULT_CONFIG.boundAction = 'BOUNCE'
        Sprites.setAll 'boundAction', 'BOUNCE'
    
    Greenhorn.addButton label: 'SPRING', onclick: ->
        env.SPRITE_DEFAULT_CONFIG.boundAction = 'SPRING'
        Sprites.setAll 'boundAction', 'SPRING'
    
    Greenhorn.addButton label: 'WRAP', onclick: ->
        env.SPRITE_DEFAULT_CONFIG.boundAction = 'WRAP'
        Sprites.setAll 'boundAction', 'WRAP'
    
    Greenhorn.addButton label: 'STOP', onclick: ->
        env.SPRITE_DEFAULT_CONFIG.boundAction = 'STOP'
        Sprites.setAll 'boundAction', 'STOP'
    
    Greenhorn.addButton label: 'DIE', onclick: ->
        env.SPRITE_DEFAULT_CONFIG.boundAction = 'DIE'
        Sprites.setAll 'boundAction', 'DIE'
    
    $('#gh-right-panel').append(
        '<h4 class="gh-panel-sub-header">ADD/REMOVE SPRITES</h4>')
    
    Greenhorn.addButton label: 'ADD ONE', onclick: ->
        new Sprite randomConfig()
    
    Greenhorn.addButton label: 'ADD FIVE', onclick: ->
        i = 5
        while i > 0
            i -= 1
            new Sprite randomConfig()
        return
    
    Greenhorn.addButton label: 'ADD TEN', onclick: ->
        i = 10
        while i > 0
            i -= 1
            new Sprite randomConfig()
        return
    
    Greenhorn.addButton label: 'ADD FIFTY', onclick: ->
        i = 50
        while i > 0
            i -= 1
            new Sprite randomConfig()
        return
    
    Greenhorn.addButton label: 'REMOVE ALL', onclick: ->
        Sprites.removeAll()

    #add content to gh-left-panel
    $('#gh-left-panel').append(
        '''
        <h4 class='gh-panel-sub-header'>Instructions</h4>
        <p class='gh-p'>
        Use the Buttons on the left hand side
        to start and stop the engine, change the
        default boundary action, or add
        and remove Circles of Friends.
        </p>
        <h4 class='gh-panel-sub-header'>Trademark</h4>
        <p class='gh-p'>
        Please note that the logo used in this
        example, which is known as
        The Circle of Friends,
        is a registered trademark of
        Canonical Ltd.
        </p>
        <h4 class='gh-panel-sub-header'>Discussion</h4>
        <p class='gh-p'>
        Try this if you're not sure where to start. 
        Create about 150 Sprites, then change the 
        boundary action from BOUNCE to WRAP to BOUNCE
        to STOP to DIE, with about 5-10 seconds inbetween. Have fun!
        </p>
        ''')

    #create random number of logos to start
    i = Math.round Math.random() * 9 + 1
    while i > 0
        i -= 1
        new Sprite randomConfig()
    return

#define update() to be called once per frame
@update = ->
    #report current number of Sprites
    $('#gh-title').html "#{document.title}: #{Sprites.howMany()}"
    
    #highlight current boundAction
    $('.gh-button').each ->
        if this.innerHTML is env.SPRITE_DEFAULT_CONFIG.boundAction
            this.style.color = '#006400'
        else
            this.style.color = '#C0C0C0'
    
    return