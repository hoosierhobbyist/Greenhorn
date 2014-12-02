###
textBoxTimer.coffee

a demonstration of two classes at once
###

#name the document
document.title = 'TextBox Timer'

#setup the environment
env.ENGINE_RIGHT_PANEL =
    '''
    CONTROLS:
        S-start
        P-pause
        R-restart
        T-stop
    '''

#declare global variables
timer = null
display = null

#define init() to be called by body.onload
init = ->
    #initialize variables
    timer = new Timer(false)
    display = new TextBox({
        x: Math.random() * 400 - 200
        y: Math.random() * 300 - 150
        dx: Math.random() * 100 - 50
        dy: Math.random() * 100 - 50
        text: (timer.getElapsedTime() / 1000).toFixed(2)
        boundAction: 'BOUNCE'
    })
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here
    if keysDown[KEYS.S] then timer.start()
    else if keysDown[KEYS.P] then timer.pause()
    else if keysDown[KEYS.R] then timer.restart()
    else if keysDown[KEYS.T] then timer.stop()
    
    Greenhorn.set 'leftPanel', 'innerHTML', display.report()
    display.set 'text', (timer.getElapsedTime() / 1000).toFixed(2)
#end update