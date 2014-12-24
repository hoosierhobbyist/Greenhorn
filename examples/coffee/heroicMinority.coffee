###
heroicMinority.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Heroic Minority'

#setup the environment
env.USE_AUDIO_TAG = true
env.SOUND_PATH = '../sounds/'
env.ENGINE.leftHeader = 'INFORMATION'
env.ENGINE.rightHeader = 'BUTTONS'

#define init() to set up document
@init = ->
    #start the engine
    Greenhorn.start()

    #initialize background music
    bgMusic = new Sound url: 'heroic_minority.mp3'
    
    #add buttons
    Greenhorn.addButton label: 'PLAY MUSIC', onclick: ->
        bgMusic.play()
    Greenhorn.addButton label: 'RESTART MUSIC', onclick: ->
        bgMusic.restart()
    Greenhorn.addButton label: 'PAUSE MUSIC', onclick: ->
        bgMusic.pause()
    Greenhorn.addButton label: 'STOP MUSIC', onclick: ->
        bgMusic.stop()
    
    #add info
    $('#gh-left-panel').append( 
        '''
        <h4 class='gh-sub-h'>Instructions</h4>
        <p class='gh-p'>
        Use the buttons on the right-hand side to test the
        four primary Sound functions: play, restart, pause, and stop.
        </p>
        <h4 class='gh-sub-h'>Acknowledgements</h4>
        <p class='gh-p'>
        This track you're listening to is titled <em>Heroic Minority</em>.
        I found it, along with many other great resources on 
        <a class='gh-a' href='http://opengameart.org'>OpenGameArt.org</a>.
        The author's name is 
        <a class='gh-a' href='http://opengameart.org/content/heroic-minority'>
        Alexandr Zhelanov</a>. You can check out some of his other work 
        <a class='gh-a' href='https://soundcloud.com/alexandr-zhelanov'>here</a>.
        </p>
        <h4 class='gh-sub-h'>Discussion</h4>
        <p class='gh-p'>
        Please note that the soundtrack will not start playing back
        until the engine has started.
        </p>
        ''')