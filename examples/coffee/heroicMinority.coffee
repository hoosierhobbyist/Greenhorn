###
startup.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Heroic Minority'

#setup the environment
env.ENGINE.leftHeader = 'INFORMATION'
env.ENGINE.rightHeader = 'BUTTONS'
env.SOUND_PATH = '../sounds/'
env.USE_AUDIO_TAG = true

#globals
bgMusic = null

#define init() to set up document
@init = ->
    #start the engine
    Greenhorn.start()

    #initialize background music
    bgMusic = new Sound url: 'heroic_minority.mp3'
    
    #add buttons
    Greenhorn.addButton label: 'PLAY MUSIC', onclick: ->
        bgMusic.play()
    Greenhorn.addButton label: 'PAUSE MUSIC', onclick: ->
        bgMusic.pause()
    Greenhorn.addButton label: 'STOP MUSIC', onclick: ->
        bgMusic.stop()
    
    #add info
    information = 
        '''
        <h4 class='gh-panel-sub-header'>Instructions</h4>
        <p class='gh-p'>
        Use the buttons on the right-hand side to test the
        three primary Sound functions: play, pause, and stop.
        </p>
        <h4 class='gh-panel-sub-header'>Acknowledgements</h4>
        <p class='gh-p'>
        This track you're listening to is titled <em>Heroic Minority</em>.
        I found it, along with many other great resources on 
        <a class='gh-a' href='http://opengameart.org'>OpenGameArt.org</a>.
        The author's name is <a class='gh-a' href='http://opengameart.org/content/heroic-minority'>
        Alexandr Zhelanov</a>. You can check out some of his other work 
        <a class='gh-a' href='https://soundcloud.com/alexandr-zhelanov'>here</a>.
        </p>
        '''
    $('#gh-left-panel').append information