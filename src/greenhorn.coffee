###
greenhorn.coffee
by Seth Bullock

***THE GREENHORN GAMING ENGINE***

primarily inspired by Andy Harris'
(aharrisbooks.net) simpleGame.js gaming engine
###

#keyboard input tracking array
@isDown = new Array(256)
key = false for key in @isDown

#keyboard value mapping object
@KEYS =
    ESC: 27, SPACE: 32, PGUP: 33
    PGDOWN: 34, END: 35, HOME: 36
    LEFT: 37, UP: 38, RIGHT: 39, DOWN: 40
    _0: 48, _1: 49, _2: 50, _3: 51, _4: 52
    _5: 53, _6: 54, _7: 55, _8: 56, _9: 57
    A: 65, B: 66, C: 67, D: 68, E: 69, F: 70
    G: 71, H: 72, I: 73, J: 74, K: 75, L: 76, M: 77
    N: 78, O: 79, P: 80, Q: 81, R: 82, S: 83
    T: 84, U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90

#document event handlers
document.onreadystatechange = ->
    if @readyState is 'interactive' then (init ? Greenhorn.start).call()
document.onkeydown = (e) ->
    e.preventDefault()
    isDown[e.keyCode] = true
document.onkeyup = (e) ->
    e.preventDefault()
    isDown[e.keyCode] = false
document.onmousemove = (e) ->
    @mouseX = e.pageX
    @mouseY = e.pageY

#integer ID used to start and stop _masterUpdate
_masterID = null

#handles all behind the scenes update tasks once per frame
_masterUpdate = ->
    #clear previous frame
    Greenhorn.clear()
    
    #call user's update
    #if one is defined
    update?()
    
    #draw all Sprites
    Sprites._drawAll()
#end _masterUpdate

#engine class
class @Greenhorn
    #create Engine elements
    _elmnts =
        main: document.createElement("div")
        title: document.createElement("h1")
        leftPanel: document.createElement("div")
        canvas: document.createElement("canvas")
        rightPanel: document.createElement("div")
        bottomPanel: document.createElement("div")
    
    #give id's to all elements
    _elmnts.main.id = 'Greenhorn'
    _elmnts.title.id = 'gh-title'
    _elmnts.leftPanel.id = 'gh-left-panel'
    _elmnts.canvas.id = 'gh-canvas'
    _elmnts.rightPanel.id = 'gh-right-panel'
    _elmnts.bottomPanel.id = 'gh-bottom-panel'
    
    #append all children to @_main
    _elmnts.main.appendChild _elmnts.title
    _elmnts.main.appendChild _elmnts.leftPanel
    _elmnts.main.appendChild _elmnts.canvas
    _elmnts.main.appendChild _elmnts.rightPanel
    _elmnts.main.appendChild _elmnts.bottomPanel
    
    #mouse position
    @getMouseX = -> document.mouseX - @get("main", "offsetLeft") - @get("canvas", "offsetLeft") - @get("canvas", "width") / 2
    @getMouseY = -> document.mouseY - @get("main", "offsetTop") - @get("canvas", "offsetTop") - @get("canvas", "height") / 2
    
    #generic element getter/setter
    @get = (elmnt, attr) ->
        _elmnts[elmnt][attr]
    @set = (elmnt, attr, what) ->
        if Object::toString.call(what) isnt '[object Object]'
            _elmnts[elmnt][attr] = what
        else
            _elmnts[elmnt][attr][key] = value for own key, value of what
    
    #unique id for each button created
    _buttonID = 0
    
    #add button to one of the panels
    @addButton = (config = {}) ->
        #increment _buttonID
        _buttonID += 1
        
        #add environment defaults to config
        #if the user has chosen to omit them
        for own key, value of env.BUTTON_DEFAULT_CONFIG when key isnt style
            config[key] ?= value
        for own key, value of env.BUTTON_DEFAULT_CONFIG.style
            config.style ?= {}
            config.style[key] ?= value
        
        #create element
        button = document.createElement "button"
        
        #set values
        button.id = "gh-button#{_buttonID}"
        button.setAttribute "type", "button"
        button.innerHTML = config.label
        button.style = config.style
        button.onclick = config.onclick
        
        #append to an element
        _elmnts[config.elmnt].appendChild button
    
    #game control
    @start = =>
        #add engine to document body
        document.body.appendChild _elmnts.main
        
        #change the document body's backgroundColor
        document.body.style.backgroundColor = env.BODY_BACKGROUND_COLOR
        
        #basic style formatting for elements
        mainStyle =
            width: '74%'
            height: '60%'
            display: 'inline-block'
            marginTop: '5%'
            marginLeft: '13%'
            border: '5px solid silver'
            borderRadius: '15px'
            fontFamily: 'Tahoma, Geneva, sans-serif'
            backgroundColor: env.ENGINE_BACKGROUND_COLOR
        titleStyle =
            width: '100%'
            textAlign: 'center'
            cssFloat: 'left'
            clear: 'both'
            display: 'initial'
            marginTop: '1%'
            marginBottom: '0px'
            paddingBottom: '1%'
            borderRadius: 'inherit'
            borderBottom: '1px solid silver'
            backgroundColor: 'inherit'
        leftPanelStyle =
            width: '15%'
            height: '78%'
            cssFloat: 'left'
            clear: 'left'
            display: 'initial'
            margin: '1%'
            overflow: 'auto'
            whiteSpace: 'pre'
            fontSize: '.75em'
            backgroundColor: 'inherit'
        canvasStyle =
            width: '65%'
            height: '78%'
            display: 'initial'
            cssFloat: 'left'
            borderRight: '1px solid silver'
            borderLeft: '1px solid silver'
            backgroundColor: env.ENGINE_CANVAS_COLOR
        rightPanelStyle =
            width: '15%'
            height: '78%'
            display: 'initial'
            cssFloat: 'left'
            clear: 'right'
            margin: '1%'
            overflow: 'auto'
            whiteSpace: 'pre'
            fontSize: '.75em'
            backgroundColor: 'inherit'
        bottomPanelStyle =
            width: '100%'
            display: 'initial'
            textAlign: 'center'
            cssFloat: 'left'
            clear: 'both'
            paddingTop: '1%'
            marginBottom: '1%'
            borderRadius: 'inherit'
            borderTop: '1px solid silver'
            fontSize: '1em'
            backgroundColor: 'inherit'
        
        #set the style of each element
        @set "main", "style", mainStyle
        @set "title", "style", titleStyle
        @set "leftPanel", "style", leftPanelStyle
        @set "canvas", "style", canvasStyle
        @set "rightPanel", "style", rightPanelStyle
        @set "bottomPanel", "style", bottomPanelStyle
        
        #set the actual size of the canvas to prevent distortion
        correctWidth = @get "canvas", "offsetWidth"
        correctHeight = @get "canvas", "offsetHeight"
        @set "canvas", "width", correctWidth
        @set "canvas", "height", correctHeight
        
        #center the canvas origin point
        _elmnts.canvas.getContext("2d").translate(@get("canvas", "width") / 2, @get("canvas", "height") / 2)
        
        #set the innerHTML of each element
        @set "title", "innerHTML", document.title
        @set "leftPanel", "innerHTML", env.ENGINE_LEFT_PANEL
        @set "rightPanel", "innerHTML", env.ENGINE_RIGHT_PANEL
        @set "bottomPanel", "innerHTML", env.ENGINE_BOTTOM_PANEL
        @set "canvas", "innerHTML", "your browser does not support the <canvas> tag"
        
        #start running _masterUpdate at env.FRAME_RATE frames/sec
        _masterID = setInterval _masterUpdate, Math.ceil 1000 / env.FRAME_RATE
        return
    @stop = ->
        clearInterval _masterID
    @clear = ->
        _elmnts.canvas.getContext("2d").clearRect(-@get("canvas", "width") / 2, -@get("canvas", "height") / 2, @get("canvas", "width"), @get("canvas", "height"))
    @hide = ->
        @set "main", "style", {"display": "none"}
    @show = ->
        @set "main", "style", {"display": "inline-block"}
    @hideCursor = ->
        @set "canvas", "style", {"cursor": "none"}
    @showCursor = ->
        @set "canvas", "style", {"cursor": "default"}
#end class Greenhorn
