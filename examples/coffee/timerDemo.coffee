###
timerDemon.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Timer Demo'

#bring in needed classes
{env, Greenhorn, Timer, TextSprite} = gh

#setup the environment
env.ENGINE.rightHeader = 'BUTTONS'
env.ENGINE.leftHeader = 'INFORMATION'

#declare global variables
timer = null
display = null

#define init() to setup the document
gh.init = ->
    #start the engine
    Greenhorn.start()
    
    #initialize variables
    timer = new Timer(off)
    display = new TextSprite
        fontSize: 60
        borderVisible: false
        text: (timer.getElapsedTime() / 1000).toFixed(2)
    
    #add buttons
    Greenhorn.addButton label: 'START', onclick: ->
        timer.start()
    Greenhorn.addButton label: 'PAUSE', onclick: ->
        timer.pause()
    Greenhorn.addButton label: 'RESTART', onclick: ->
        timer.restart()
    Greenhorn.addButton label: 'STOP', onclick: ->
        timer.stop()
    
    #include information
    $('#gh-left-panel').append(
        '''
        <h4 class='gh-sub-h'>Instructions</h4>
        <p class='gh-p'>
        Use the buttons on the right-hand side to experiment
        with the four primary timer functions: play, pause,
        restart, and stop. The elapsed time is displayed
        on the canvas using a Greenhorn TextSprite.
        </p>
        <h4 class='gh-sub-h'>Discussion</h4>
        <p class='gh-p'>
        The timer class is used internally by the Greenhorn AniSprite
        to determine when to change frames. It could also be used to
        offset particular events, measure and compare a player's performance
        to others, or set a time limit on a particular game.
        </p>
        ''')

#define update() to be called once per frame
gh.update = ->
    #update the displayed time
    display.set 'text', (timer.getElapsedTime() / 1000).toFixed(2)