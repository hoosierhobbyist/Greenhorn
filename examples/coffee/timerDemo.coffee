###
textBoxTimer.coffee

a demonstration of two classes at once
###

#name the document
document.title = 'Timer Demo'

#setup the environment
env.ENGINE.rightHeader = 'CONTROLS'

#declare global variables
timer = null
display = null

#define init() to be called by body.onload
@init = ->
    #start the engine
    Greenhorn.start()
    
    #initialize variables
    timer = new Timer(false)
    display = new TextBox
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
#end init

#define update() to be called once per frame
@update = ->
    #update TextBox
    display.set 'text', (timer.getElapsedTime() / 1000).toFixed(2)
#end update