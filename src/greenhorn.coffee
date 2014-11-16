###
greenhorn.coffee
by Seth Bullock

***THE GREENHORN GAMING ENGINE***

primarily inspired by Andy Harris'
(aharrisbooks.net) simpleGame.js gaming engine
###

#keyboard value mapping object
@KEYS =
    LEFT: 37, RIGHT: 39, UP: 38, DOWN: 40
    SPACE: 32, ESC: 27, PGUP: 33
    PGDOWN: 34, HOME: 36, END: 35
    _0: 48, _1: 49, _2: 50, _3: 51, _4: 52
    _5: 53, _6: 54, _7: 55, _8: 56, _9: 57
    A: 65,  B: 66, C: 67, D: 68, E: 69, F: 70
    G: 71, H: 72, I: 73, J: 74, K: 75, L: 76, M: 77
    N: 78, O: 79, P: 80, Q: 81, R: 82, S: 83
    T: 84, U: 85, V: 86, W: 87, X: 88, Y: 89, Z: 90

#keyboard input tracking array
@keysDown = (key = false for key in (new Array(256)))

#document event handlers
document.onkeydown = (e) ->
    e.preventDefault()
    keysDown[e.keyCode] = true
document.onkeyup = (e) ->
    e.preventDefault()
    keysDown[e.keyCode] = false
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
    
    #update all Sprites
    Sprites._updateAll()
#end _masterUpdate

#<canvas> tag wrapper class
class @Greenhorn
    #create Engine elements
    @_elmnts =
        main: document.createElement "div"
        title: document.createElement "h2"
        leftPanel: document.createElement "div"
        canvas: document.createElement "canvas"
        rightPanel: document.createElement "div"
        bottomPanel: document.createElement "div"
    
    #append all children to @_main
    @_elmnts.main.appendChild @_elmnts.title
    @_elmnts.main.appendChild @_elmnts.leftPanel
    @_elmnts.main.appendChild @_elmnts.canvas
    @_elmnts.main.appendChild @_elmnts.rightPanel
    @_elmnts.main.appendChild @_elmnts.bottomPanel
    
    #mouse position
    @getMouseX = -> document.mouseX - @get("main", "offsetLeft") - @get("canvas", "offsetLeft") - @get("canvas", "width") / 2
    @getMouseY = -> document.mouseY - @get("main", "offsetTop") - @get("canvas", "offsetTop") - @get("canvas", "height") / 2
    
    #canvas boundaries
    @getBound = (side) ->
        switch side
            when "top"
                @get("canvas", "height") / 2
            when "bottom"
                -@get("canvas", "width") / 2
            when "right"
                @get("canvas", "height") / 2
            when "left"
                -@get("canvas", "width") / 2
    
    #generic element getter/setter
    @get = (elmnt, attr) ->
        if attr
            @_elmnts[elmnt][attr]
        else
            @_elmnts[elmnt]
    @set = (elmnt, attr, what) ->
        if Object::toString.call(what) is '[object Object]'
            @_elmnts[elmnt][attr][key] = value for key, value of what
        else
            @_elmnts[elmnt][attr] = what
    
    #add button to one of the panels
    @addButton = (where, label = env.BUTTON_DEFAULT_LABEL, style = {}, whenClicked = =>) ->
        button = document.createElement "button"
        button.setAttribute "type", "button"
        button.innerHTML = label
        button.style[key] = value for key, value of style
        button.onclick = whenClicked
        @_elmnts[where].appendChild button
    
    #game control
    @start = ->
        #change the document body's backgroundColor
        document.body.bgColor = env.BODY_BACKGROUND_COLOR
        #add engine to document body
        document.body.appendChild @_elmnts.main
        
        #basic style formatting for elements
        mainStyle =
            width: "100%"
            display: "inline-block"
            backgroundColor: env.ENGINE_BACKGROUND_COLOR
        titleStyle =
            textAlign: "center"
            cssFloat: "left"
            display: "initial"
            marginTop: "1%"
            marginBottom: "1%"
            backgroundColor: "inherit"
            minWidth: "100%"
            minHeight: "6%"
            maxWidth: "100%"
            maxHeight: "6%"
        leftPanelStyle =
            minWidth: "15%"
            minHeight: "80%"
            maxWidth: "15%"
            maxHeight: "80%"
            cssFloat: "left"
            display: "initial"
            marginLeft: "1%"
            marginRight: "1%"
            overflow: "auto"
            whiteSpace: "pre"
            backgroundColor: "inherit"
        canvasStyle =
            minWidth: "66%"
            minHeight: "80%"
            maxWidth: "66%"
            maxHeight: "80%"
            display: "initial"
            cssFloat: "left"
            backgroundColor: env.ENGINE_CANVAS_COLOR
        rightPanelStyle =
            minWidth: "15%"
            minHeight: "80%"
            maxWidth: "15%"
            maxHeight: "80%"
            display: "initial"
            cssFloat: "left"
            marginLeft: "1%"
            marginRight: "1%"
            overflow: "auto"
            whiteSpace: "pre"
            backgroundColor: "inherit"
        bottomPanelStyle =
            minWidth: "100%"
            minHeight: "10%"
            maxWidth: "100%"
            maxHeight: "10%"
            display: "initial"
            textAlign: "center"
            cssFloat: "left"
            marginTop: "1%"
            marginBottom: "1%"
            backgroundColor: "inherit"
        
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
        @_elmnts.canvas.getContext("2d").translate(@get("canvas", "width") / 2, @get("canvas", "height") / 2)
        
        #set the innerHTML of each element
        @set "title", "innerHTML", env.ENGINE_TITLE
        @set "leftPanel", "innerHTML", env.ENGINE_LEFT_PANEL
        @set "rightPanel", "innerHTML", env.ENGINE_RIGHT_PANEL
        @set "bottomPanel", "innerHTML", env.ENGINE_BOTTOM_PANEL
        @set "canvas", "innerHTML", env.ENGINE_CANVAS_ERROR
        
        #start running _masterUpdate at env.FRAME_RATE frames/sec
        _masterID = setInterval _masterUpdate, Math.ceil 1000 / env.FRAME_RATE
        return
    @stop = ->
        clearInterval _masterID
    @clear = ->
        @_elmnts.canvas.getContext("2d").clearRect(-@get("canvas", "width") / 2, -@get("canvas", "height") / 2, @get("canvas", "width"), @get("canvas", "height"))
    @hide = ->
        set "main", "style", {"display": "none"}
    @show = ->
        set "main", "style", {"display": "inline-block"}
    @hideCursor = ->
        set "canvas", "style", {"cursor": "none"}
    @showCursor = ->
        set "canvas", "style", {"cursor": "default"}
#end class Greenhorn