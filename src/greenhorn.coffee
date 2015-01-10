###
greenhorn.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#keyboard value mapping object
KEYS =
    ESC: 27, SPACE: 32, PGUP: 33
    PGDOWN: 34, END: 35, HOME: 36
    LEFT: 37, UP: 38, RIGHT: 39, DOWN: 40
    '0': 48, '1': 49, '2': 50, '3': 51, '4': 52
    '5': 53, '6': 54, '7': 55, '8': 56, '9': 57
    A: 65, B: 66, C: 67, D: 68, E: 69, F: 70
    G: 71, H: 72, I: 73, J: 74, K: 75, L: 76, M: 77
    N: 78, O: 79, P: 80, Q: 81, R: 82, S: 83
    T: 84, U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90
gh.KEYS = KEYS

#automatic initialization
document.onreadystatechange = ->
    if @readyState is 'interactive'
        (gh.init ? Greenhorn.start)()

#listen for key events
document.onkeydown = (e) ->
    e.preventDefault()
    Greenhorn.isDown[e.keyCode] = true
document.onkeyup = (e) ->
    e.preventDefault()
    Greenhorn.isDown[e.keyCode] = false

#asynchronous ID
_masterID = null

#draws on canvas once per frame
_masterUpdate = ->
    #clear previous frame
    Greenhorn.clear()

    #call custom update
    gh.update?()

    #draw all Sprites
    Sprite._drawAll()

#Engine class
class Greenhorn
    #keyboard input tracking array
    @isDown = new Array 256
    key = false for key in @isDown
    
    #name of the current state
    @currentState = 'STARTUP'

    #create Engine elements
    _elmnts =
        main: document.createElement 'div'
        title: document.createElement 'h1'
        leftPanel: document.createElement 'div'
        leftPanelHeader: document.createElement 'h3'
        canvas: document.createElement 'canvas'
        rightPanel: document.createElement 'div'
        rightPanelHeader: document.createElement 'h3'
        footer: document.createElement 'div'

    #give id's to primary children
    _elmnts.main.id = 'gh-main'
    _elmnts.title.id = 'gh-title'
    _elmnts.leftPanel.id = 'gh-left-panel'
    _elmnts.canvas.id = 'gh-canvas'
    _elmnts.rightPanel.id = 'gh-right-panel'
    _elmnts.footer.id = 'gh-footer'
    
    #assign gh-h class to panelHeaders
    _elmnts.leftPanelHeader.classList.add 'gh-h'
    _elmnts.rightPanelHeader.classList.add 'gh-h'

    #append all primary children to main div
    _elmnts.main.appendChild _elmnts.title
    _elmnts.main.appendChild _elmnts.leftPanel
    _elmnts.main.appendChild _elmnts.canvas
    _elmnts.main.appendChild _elmnts.rightPanel
    _elmnts.main.appendChild _elmnts.footer

    #append headers to panels
    _elmnts.leftPanel.appendChild _elmnts.leftPanelHeader
    _elmnts.rightPanel.appendChild _elmnts.rightPanelHeader
    
    #keep track of mouse events over canvas
    _elmnts.canvas.onmousemove = (e) ->
        @mouseX = e.pageX
        @mouseY = e.pageY
        Sprite.emitAll 'mouse:move'
    _elmnts.canvas.onmousedown = (e) ->
        Sprite.emitAll 'mouse:down'
    _elmnts.canvas.onmouseup = (e) ->
        Sprite.emitAll 'mouse:up'
    _elmnts.canvas.ondblclick = (e) ->
        Sprite.emitAll 'mouse:doubleClick'
    _elmnts.canvas.oncontextmenu = (e) ->
        e.preventDefault()
        Sprite.emitAll 'mouse:rightClick'

    #start all asynchronous functions
    _startEverything = ->
        _masterID = setInterval _masterUpdate, 1000 / env.FRAME_RATE
        Sprite._startAll()
        Sound._playAll()
        return

    #mouse position getters
    @getMouseX = ->
        _elmnts.canvas.mouseX - _elmnts.canvas.offsetLeft - _elmnts.canvas.width / 2
        
    @getMouseY = ->
        -(_elmnts.canvas.mouseY - _elmnts.canvas.offsetTop - _elmnts.canvas.height / 2)

    #add button to one of the panels
    @addButton = (config = {}) ->
        #add missing keys to config
        for own key, value of env.BUTTON_DEFAULT_CONFIG
            config[key] ?= value

        #create element
        button = document.createElement 'button'

        #set values
        button.type = config.type
        button.innerHTML = config.label
        button.onclick = config.onclick
        button.classList.add 'gh-button'

        #append to an element
        _elmnts[config.parent].appendChild button
    
    #change state
    @changeState = (stateName) ->
        @emit "state-change-from:#{@currentState}"
        @emit 'state-change', @currentState, stateName
        @emit "state-change-to:#{stateName}"
        @currentState = stateName
    
    #execute start-up logic only once
    _firstTime = true
    
    #game control
    @isRunning = ->
        _masterID?
    @stop = ->
        Sprite._stopAll()
        Sound._pauseAll()
        clearInterval _masterID
        _masterID = null
    @clear = ->
        _elmnts.canvas
        .getContext('2d')
        .clearRect(
            -_elmnts.canvas.width / 2,
            -_elmnts.canvas.height / 2,
            _elmnts.canvas.width,
            _elmnts.canvas.height)
    @start = (stateName) =>
        #prevent starting without properly stopping first
        unless @isRunning()
            if _firstTime
                #add engine to a user defined '.gh' div or the document body
                (document.querySelector('.gh') ? document.body).appendChild _elmnts.main
                if _elmnts.main.parentNode is document.body
                    document.body.classList.add 'gh'
                
                #set the innerHTML of each element
                _elmnts.title.innerHTML = document.title
                _elmnts.leftPanelHeader.innerHTML = env.ENGINE.leftHeader
                _elmnts.rightPanelHeader.innerHTML = env.ENGINE.rightHeader
                _elmnts.footer.innerHTML = env.ENGINE.footer
                _elmnts.canvas.innerHTML = 'Your browser does not support the &ltcanvas&gt tag'

                #set the size of the canvas
                _elmnts.canvas.width = _elmnts.canvas.clientWidth
                _elmnts.canvas.height = _elmnts.canvas.clientHeight

                #center the canvas origin point
                _elmnts.canvas
                .getContext('2d')
                .translate(
                    _elmnts.canvas.width / 2,
                    _elmnts.canvas.height / 2)

                #draw the start screen
                _ctx = _elmnts.canvas.getContext '2d'
                _ctx.save()
                _ctx.globalAlpha = 1.0
                _ctx.textAlign = 'center'
                _ctx.textBaseline = 'middle'
                _ctx.font = "#{env.STARTUP.size}px #{env.STARTUP.font}"
                _ctx.fillStyle = env.STARTUP.color
                _ctx.fillText env.STARTUP.text, 0, 0
                _ctx.restore()

                #make the entire canvas a start button
                _elmnts.canvas.onclick = ->
                    _startEverything()
                    Greenhorn.changeState stateName ? 'GREENHORN'
                    _elmnts.canvas.onclick = (e) ->
                        Sprite.emitAll 'mouse:click'

                #don't do all this a second time
                _firstTime = false
            else
                _startEverything()
                if stateName then @changeState stateName

#mixin EventEmitter
_mixin Greenhorn, EventEmitter::

#add to namespace object
gh.Greenhorn = Greenhorn