###
startup.coffee

The absolute minimum that needs to
be done in order to create a Greenhorn page
###

#name the document
document.title = 'Startup Page'

#setup the environment

#declare global variables

#define init() to be called by body.onload
init = ->
    #initialize variables
    
    #document specific setup
    
    #start the engine
    Greenhorn.start()
#end init

#define update() to be called once per frame
update = ->
    #handle any game specific events here