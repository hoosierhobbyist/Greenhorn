###
environment.coffee

The Greenhorn Gaming environment object
###

@env =
    #miscellaneous
    FRAME_RATE: 25
    #document body settings
    BODY_BACKGROUND_COLOR: "goldenrod"
    #default engine settings
    ENGINE_TITLE: document.title
    ENGINE_LEFT_PANEL: "LEFT PANEL"
    ENGINE_RIGHT_PANEL: "RIGHT PANEL"
    ENGINE_BOTTOM_PANEL: "BOTTOM PANEL"
    ENGINE_CANVAS_COLOR: "black"
    ENGINE_BACKGROUND_COLOR: "darkgreen"
    #default Sprite settings
    IMAGE_PATH: ""
    SPRITE_DEFAULT_CONFIG:
        x: 0
        y: 0
        z: 0
        a: 0
        dx: 0
        dy: 0
        dz: 0
        da: 0
        ddx: 0
        ddy: 0
        ddz: 0
        dda: 0
        width: 64
        height: 64
        imageFile: ""
        visible: yes
        boundAction: "WRAP"
    #default TextBox settings
    TEXTBOX_DEFAULT_CONFIG:
        z: -1
        text: "*-TextBox-*"
        align: "center"
        backgroundColor: "black"
        backgroundAlpha: 1.0
        backgroundVisible: yes
        borderSize: 5
        borderColor: "white"
        borderAlpha: 1.0
        borderVisible: yes
        fontName: "Arial"
        fontSize: 8
        fontColor: "white"
        fontAlpha: 1.0
        marginsTop: 5
        marginsBottom: 5
        marginsRight: 5
        marginsLeft: 5
    ANISPRITE_DEFAULT_CONFIG:
        sheetWidth: 256
        sheetHeight: 256
        cellWidth: 32
        cellHeight: 32
        frameRate: 5
        numFrames: 8
    #default sound settings
    SOUND_PATH: ""
    USE_AUDIO_TAG: false
    SOUND_DEFAULT_CONFIG:
        url: ""
        playOnLoad: false
    #default timer settings
    TIMER_START_ON_CONSTRUCTION: yes
    #default button settings
    BUTTON_DEFAULT_LABEL: "Launch the Missiles!"
#end environment object



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
    
    #draw all Sprites
    Sprites._drawAll()
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
    
    #generic element getter/setter
    @get = (elmnt, attr) ->
        if attr
            @_elmnts[elmnt][attr]
        else
            @_elmnts[elmnt]
    @set = (elmnt, attr, what) ->
        if Object::toString.call(what) is '[object Object]'
            @_elmnts[elmnt][attr][key] = value for own key, value of what
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
        @set "canvas", "innerHTML", "your browser does not support the <canvas> tag"
        
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



###
sprite.coffee

The Greenhorn Gaming Engine core class
###

#generate a sort rule to determine
#in what order the sprites are drawn
makeSortRule = (sortBy, order) ->
    if order is "ascending"
        (sp1, sp2) ->
            sp1.get(sortBy) - sp2.get(sortBy)
    else if order is "decending"
        (sp1, sp2) ->
            sp2.get(sortBy) - sp1.get(sortBy)
    else
        throw new Error "order must be ascending or decending"

#core engine class
class @Sprite
    #<---CLASS-LEVEL--->
    #state values
    _list = []
    _sortRule = makeSortRule "z", "ascending"
    
    #Sprite class methods
    @howMany = -> _list.length
    @_drawAll = ->
        sp._draw() for sp in _list
        return
    
    #collective manipulation
    @getAll = (what, excep...) ->
        sp.get what for sp in _list when sp not in excep
    @setAll = (what, to, excep...) ->
        sp.set what, to for sp in _list when sp not in excep
    @changeAll = (what, step, excep...) ->
        sp.change what, step for sp in _list when sp not in excep
    
    #<---INSTANCE-LEVEL--->
    #constructor
    constructor: (config = {}) ->
        forbidden = [
            "display"
            "position"
            "motion"
            "acceleration"
            "config"
            "distance"
            "speed"
            "rate"
            "posAngle"
            "motAngle"
            "accAngle"
        ]#end forbidden config keys
        
        #throw an error if a forbidden key is provided in the configuration
        throw new Error "#{key} is a forbidden config value" for key in forbidden when config[key]?
        
        #create primary objects
        @_dis = {}
        @_pos = {}
        @_mot = {}
        @_acc = {}
        
        #get the context used to draw sprite
        @_dis.context = Greenhorn._elmnts.canvas.getContext "2d"
        
        #add the environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.SPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #set this sprite's configuration
        @set "config", config
        
        #asynchronously calls this._update, so that _masterUpdate doesn't have to
        setInterval @_update, Math.ceil 1000 / env.FRAME_RATE
        
        #sort the Sprite _list according to _sortRule
        _list.push this
        _list.sort _sortRule
    
    #getter
    get: (what) ->
        switch what
            when "display"
                @_dis
            when "position"
                @_pos
            when "motion"
                @_mot
            when "acceleration"
                @_acc
            when "imageFile"
                @_dis.image.src
            when "width", "height", "visible", "boundAction"
                @_dis[what]
            when "x", "y", "z", "a"
                @_pos[what]
            when "dx", "dy", "dz", "da"
                @_mot[what]
            when "ddx", "ddy", "ddz", "dda"
                @_acc[what]
            when "top"
                @_pos.y + @_dis.height / 2
            when "bottom"
                @_pos.y - @_dis.height / 2
            when "right"
                @_pos.x + @_dis.width / 2
            when "left"
                @_pos.x - @_dis.width / 2
            when "distance"
                Math.sqrt @_pos.x**2 + @_pos.y**2
            when "speed"
                Math.sqrt @_mot.dx**2 + @_mot.dy**2
            when "rate"
                Math.sqrt @_acc.ddx**2 + @_acc.ddy**2
            when "posAngle"
                Math.atan2 @_pos.y, @_pos.x
            when "motAngle"
                Math.atan2 @_mot.dy, @_mot.dx
            when "accAngle"
                Math.atan2 @_acc.ddy, @_acc.ddx
            else
                throw new Error "#{what} is not a get-able Sprite attribute"
    
    #setter
    set: (what, to) ->
        switch what
            when "display", "position", "motion", "acceleration", "config"
                @set k, v for own k, v of to
            when "imageFile"
                @_dis.image ?= new Image()
                @_dis.image.src = env.IMAGE_PATH.concat to
            when "width", "height", "visible", "boundAction"
                @_dis[what] = to
            when "x", "y", "z", "a"
                @_pos[what] = to
                _list.sort _sortRule if what is "z"
            when "dx", "dy", "dz", "da"
                @_mot[what] = to
            when "ddx", "ddy", "ddz", "dda"
                @_acc[what] = to
            when "distance"
                proxy =
                    x: to * Math.cos @get "posAngle"
                    y: to * Math.sin @get "posAngle"
                @set "position", proxy
            when "speed"
                proxy =
                    dx: to * Math.cos @get "motAngle"
                    dy: to * Math.sin @get "motAngle"
                @set "motion", proxy
            when "rate"
                proxy =
                    ddx: to * Math.cos @get "accAngle"
                    ddy: to * Math.sin @get "accAngle"
                @set "acceleration", proxy
            when "posAngle"
                proxy =
                    x: @get("distance") * Math.cos to
                    y: @get("distance") * Math.sin to
                @set "position", proxy
            when "motAngle"
                proxy =
                    dx: @get("speed") * Math.cos to
                    dy: @get("speed") * Math.sin to
                @set "motion", proxy
            when "accAngle"
                proxy =
                    ddx: @get("rate") * Math.cos to
                    ddy: @get("rate") * Math.sin to
                @set "acceleration", proxy
            else
                throw new Error "#{what} is not a set-able Sprite attribute"
        this
    
    #changer
    change: (what, step) ->
        switch what
            when "display", "position", "motion", "acceleration"
                @change k.slice(1), v for own k, v of step
            when "width", "height"
                @_dis[what] += step / env.FRAME_RATE
            when "x", "y", "z", "a"
                @_pos[what] += step / env.FRAME_RATE
                _list.sort _sortRule if what is "z"
            when "dx", "dy", "dz", "da"
                @_mot[what] += step / env.FRAME_RATE
            when "ddx", "ddy", "ddz", "dda"
                @_acc[what] += step / env.FRAME_RATE
            when "distance"
                proxy =
                    dx: step * Math.cos @get "posAngle"
                    dy: step * Math.sin @get "posAngle"
                @change "position", proxy
            when "speed"
                proxy =
                    ddx: step * Math.cos @get "motAngle"
                    ddy: step * Math.sin @get "motAngle"
                @change "motion", proxy
            when "rate"
                proxy =
                    dddx: step * Math.cos @get "accAngle"
                    dddy: step * Math.sin @get "accAngle"
                @change "acceleration", proxy
            when "posAngle"
                proxy =
                    dx: @get("distance") * Math.cos step
                    dy: @get("distance") * Math.sin step
                @change "position", proxy
            when "motAngle"
                proxy =
                    ddx: @get("speed") * Math.cos step
                    ddy: @get("speed") * Math.sin step
                @change "motion", proxy
            when "accAngle"
                proxy =
                    dddx: @get("rate") * Math.cos step
                    dddy: @get("rate") * Math.sin step
                @change "acceleration", proxy
            else
                throw new Error "#{what} is not a change-able Sprite attribute"
        this
    
    #collision routines
    collidesWith: (other) ->
        collision = true
        if @_dis.visible and other.get("visible") and @_pos.z == other.get("z")
            if @get("bottom") > other.get("top") or
            @get("top") < other.get("bottom") or
            @get("right") < other.get("left") or
            @get("left") > other.get("right")
                collision = false
        else collision = false
        collision
    collidesWithMouse: ->
        collision = false
        if @_dis.visible
            if @get("left") < Greenhorn.getMouseX() < @get("right") and
            @get("bottom") < Greenhorn.getMouseY() < @get("top")
                collision = true
        collision
    distanceTo: (other) ->
        Math.sqrt (@_pos.x - other.get("x"))**2 + (@_pos.y - other.get("y"))**2
    distanceToMouse: ->
        Math.sqrt (@_pos.x - Greenhorn.getMouseX())**2 + (@_pos.y - Greenhorn.getMouseY())**2
    angleTo: (other) ->
        -Math.atan2 other.get("y") - @_pos.y, other.get("x") - @_pos.x
    angleToMouse: ->
        -Math.atan2 Greenhorn.getMouseY() - @_pos.y, Greenhorn.getMouseX() - @_pos.x
    
    #update routines
    _draw: ->
        @_dis.context.save()
        @_dis.context.translate @_pos.x, -@_pos.y
        @_dis.context.rotate -@_pos.a
        @_dis.context.drawImage @_dis.image, -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        @_dis.context.restore()
    _update: =>
        if @_dis.visible
            @change "motion", @_acc
            @change "position", @_mot
            
            #check boundaries
            bounds =
                top: Greenhorn.get("canvas", "height") / 2
                bottom: -Greenhorn.get("canvas", "height") / 2
                right: Greenhorn.get("canvas", "width") / 2
                left: -Greenhorn.get("canvas", "width") / 2
            
            #sprite has completely disappeared offscreen
            offTop = @get("bottom") > bounds.top
            offBottom = @get("top") < bounds.bottom
            offRight = @get("left") > bounds.right
            offLeft = @get("right") < bounds.left
            
            #sprite has just come into contact with a boundary
            hitTop = @get("top") >= bounds.top
            hitBottom = @get("bottom") <= bounds.bottom
            hitRight = @get("right") >= bounds.right
            hitLeft = @get("left") <= bounds.left
            
            switch @_dis.boundAction
                when "WRAP"
                    if offTop
                        @set "y", bounds.bottom - @_dis.height / 2
                    if offBottom
                        @set "y", bounds.top + @_dis.height / 2
                    if offRight
                        @set "x", bounds.left - @_dis.width / 2
                    if offLeft
                        @set "x", bounds.right + @_dis.width / 2
                when "BOUNCE"
                    if hitTop
                        @set "y", bounds.top - @_dis.height / 2
                        @_mot.dy *= -1
                    if hitBottom
                        @set "y", bounds.bottom + @_dis.height / 2
                        @_mot.dy *= -1
                    if hitRight
                        @set "x", bounds.right - @_dis.width / 2
                        @_mot.dx *= -1
                    if hitLeft
                        @set "x", bounds.left + @_dis.width / 2
                        @_mot.dx *= -1
                when "SEMIBOUNCE"
                    if hitTop
                        @set "y", bounds.top - @_dis.height / 2
                        @_mot.dy *= -.75
                    if hitBottom
                        @set "y", bounds.bottom + @_dis.height / 2
                        @_mot.dy *= -.75
                    if hitRight
                        @set "x", bounds.right - @_dis.width / 2
                        @_mot.dx *= -.75
                    if hitLeft
                        @set "x", bounds.left + @_dis.width / 2
                        @_mot.dx *= -.75
                when "STOP"
                    if hitTop or hitBottom or hitRight or hitLeft
                        @_mot.dx = 0
                        @_mot.dy = 0
                        @_acc.ddx = 0
                        @_acc.ddy = 0
                        
                        if hitTop
                            @set "y", bounds.top - @_dis.height / 2
                        if hitBottom
                            @set "y", bounds.bottom + @_dis.height / 2
                        if hitRight
                            @set "x", bounds.right - @_dis.width / 2
                        if hitLeft
                            @set "x", bounds.left + @_dis.width / 2
                when "DIE"
                    if offTop or offBottom or offRight or offLeft
                        @_dis.visible = no
        this
    
    #debugging
    report: ->
        """
        display:
            width: #{Math.round @_dis.width}
            height: #{Math.round @_dis.height}
            visible: #{@_dis.visible}
            boundAction: #{@_dis.boundAction}
        position:
            x: #{@_pos.x.toFixed 3}
            y: #{@_pos.y.toFixed 3}
            z: #{@_pos.z.toFixed 3}
            a: #{@_pos.a.toFixed 3}
        motion:
            dx: #{@_mot.dx.toFixed 3}
            dy: #{@_mot.dy.toFixed 3}
            dz: #{@_mot.dz.toFixed 3}
            da: #{@_mot.da.toFixed 3}
        acceleration:
            ddx: #{@_acc.ddx.toFixed 3}
            ddy: #{@_acc.ddy.toFixed 3}
            ddz: #{@_acc.ddz.toFixed 3}
            dda: #{@_acc.dda.toFixed 3}
        """
    log: ->
        console?.log @report()
        return
#end class Sprite

#more natural alias for
#calling collective methods
@Sprites = @Sprite



###
textBox.coffee

The Greenhorn Gaming TextBox class
###

#simple textbox
class @TextBox extends @Sprite
    #constructor
    constructor: (config = {}) ->
        #add the environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.TEXTBOX_DEFAULT_CONFIG
            config[key] ?= value
        
        #primary objects
        @_text = []
        @_background = {}
        @_border = {}
        @_font = {}
        @_margins = {}
        
        #call Sprite constructor
        super(config)
    
    #generic getter
    get: (what) ->
        switch what
            when "text"
                @_text.join '\n'
            when "align"
                @_dis.context.textAlign
            when "background", "border", "font", "margins"
                @["_".concat what]
            when what.indexOf("background") is 0
                @_background[what.slice(10).toLowerCase()]
            when what.indexOf("border") is 0
                @_border[what.slice(6).toLowerCase()]
            when what.indexOf("font") is 0
                @_font[what.slice(4).toLowerCase()]
            when what.indexOf("margins") is 0
                @_margins[what.slice(7).toLowerCase()]
            else
                super what
    
    #generic setter
    set: (what, to) ->
        if what is "text"
            @_text = to.split "\n"
        else if what is "align"
            @_dis.context.textAlign = to
        else if what is "background" or what is "border" or what is "font" or what is "margins"
            @["_".concat what][k] = v for k, v of to
        else if what.indexOf("background") is 0
            @_background[what.slice(10).toLowerCase()] = to
        else if what.indexOf("border") is 0
            @_border[what.slice(6).toLowerCase()] = to
        else if what.indexOf("font") is 0
            @_font[what.slice(4).toLowerCase()] = to
        else if what.indexOf("margins") is 0
            @_margins[what.slice(7).toLowerCase()] = to
        else
            super what, to
        
        if @_dis.width? and @_dis.height? and @_font.size? and
        @_margins.left? and @_margins.right? and @_margins.bottom? and
        @_margins.top? and @_border.visible? and @_border.size?
            @_fitText()
        this
    
    #style control
    showBackground: ->
        @_background.visible = yes
        return
    hideBackground: ->
        @_background.visible = no
        return
    showBorder: ->
        @_border.visible = yes
        @_fitText()
        return
    hideBorder: ->
        @_border.visible = no
        @_fitText()
        return
    
    #internal control
    _fitText: ->
        #calculate new size
        @_dis.width = 0
        @_dis.height = (@_font.size * @_text.length) + (@_font.size * (@_text.length - 1))
        for line in @_text
            len = @_dis.context.measureText(line).width
            @_dis.width = len if @_dis.width < len
        
        #adjust for margins and border
        @_dis.width += @_margins.left + @_margins.right
        @_dis.height += @_margins.top + @_margins.bottom
        if @_border.visible
            @_dis.width += 2 * @_border.size
            @_dis.height += 2 * @_border.size
        
        return this
    _draw: ->
        #save current context
        @_dis.context.save()
        
        #translate and rotate
        @_dis.context.translate @_pos.x, -@_pos.y
        @_dis.context.rotate -@_pos.a
        
        #draw background
        if @_background.visible
            @_dis.context.fillStyle = @_background.color
            @_dis.context.globalAlpha = @_background.alpha
            @_dis.context.fillRect -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        
        #draw borders
        if @_border.visible
            @_dis.context.strokeStyle = @_border.color
            @_dis.context.lineWidth = @_border.size
            @_dis.context.globalAlpha = @_border.alpha
            @_dis.context.strokeRect -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        
        #draw text
        xOffset = @_margins.left
        yOffset = @_margins.top + @_font.size
        if @_border.visible
            xOffset += @_border.size
            yOffset += @_border.size
        
        #initialize context
        @_dis.context._font = "#{@_font.size}px #{@_font.name}"
        @_dis.context.fillStyle = @_font.color
        @_dis.context.globalAlpha = @_font.alpha
        
        #draw text on canvas
        if @_text.length > 1
            for line, i in @_text
                @_dis.context.fillText line, xOffset - (@_dis.width / 2), yOffset - (@_dis.height / 2) + (@_font.size * 2 * i)
        else
            @_dis.context.fillText @_text[0], xOffset - (@_dis.width / 2), yOffset - (@_dis.height / 2)
        
        #restore old context
        @_dis.context.restore()
        return
#end class TextBox



###
timer.coffee

The Greenhorn Gaming Timer class
###

#simple timer class
class @Timer
    #constructor
    constructor: (start_now = env.TIMER_START_ON_CONSTRUCTION) ->
        @_elapsedTime = 0
        @_startTime = if start_now then @getCurrentTime() else null
        return this
    
    #getters
    getStartTime: -> @_startTime
    getCurrentTime: -> (new Date()).getTime()
    getElapsedTime: ->
        unless @_startTime
            @_elapsedTime
        else
            @_elapsedTime + @getCurrentTime() - @_startTime
    
    #timer control
    start: ->
        unless @_startTime
            @_startTime = @getCurrentTime()
            return
    pause: ->
        if @_startTime
            @_elapsedTime += @getCurrentTime() - @getStartTime()
            @_startTime = null
            return
    restart: ->
        @_elapsedTime = 0
        @_startTime = @getCurrentTime()
        return
    stop: ->
        @_elapsedTime = 0
        @_startTime = null
        return
#end class Timer


###
aniSprite.coffee

The Greenhorn Gaming Engine animated Sprite class
###

class AniCycle
    #constructor
    constructor: (data) ->
        #extract data
        @frame = 1
        @name = data.name
        @row = data.row
        @numFrames = data.numFrames

class @AniSprite extends @Sprite
    #constructor
    constructor: (config = {}) ->
        #add environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.ANISPRITE_DEFAULT_CONFIG when key isnt "numFrames"
            config[key] ?= value
        
        #call the Sprite constructor
        super(config)
    
    #getter
    get: (what) ->
        switch what
            when "sheetWidth", "sheetHeight", "cellWidth", "cellHeight", "frameRate"
                @_dis[what]
            when "current"
                @_dis.current.name
            else
                super what
    
    #setter
    set: (what, to) ->
        if what is "sheetWidth" or
        what is "sheetHeight" or
        what is "cellWidth" or
        what is"cellHeight" or
        what is"frameRate"
            @_dis[what] = to
        else if what is "current"
            @_dis.current.frame = 1
            for cycle in @_dis.cycles when cycle.name is to
                @_dis.current = cycle
        else if what.indexOf("cycle") is 0
            @_dis.cycles ?= new Array()
            @_dis.timer ?= new Timer()
            
            i = 0
            to.name ?= what.slice 5
            to.row ?= i += 1
            to.numFrames ?= env.ANISPRITE_DEFAULT_CONFIG.numFrames
            @_dis.cycles.push(new AniCycle(to))
            @_dis.current ?= to
        else
            super what, to
        this
    
    #animation control
    play: ->
        @_dis.timer.start()
        this
    pause: ->
        @_dis.timer.pause()
        this
    
    #update routines
    _draw: ->
        #save current context
        @_dis.context.save()
        
        #translate and rotate
        @_dis.context.translate @_pos.x, -@_pos.y
        @_dis.context.rotate -@_pos.a
        
        #draw frame
        @_dis.context.drawImage( 
            @_dis.image, #spritesheet
            (@_dis.current.frame - 1) * @_dis.cellWidth, #sx
            (@_dis.current.row - 1) * @_dis.cellHeight, #sy
            @_dis.cellWidth, #swidth
            @_dis.cellHeight, #sheight
            -@_dis.width / 2, #x
            -@_dis.height / 2, #y
            @_dis.width, #width
            @_dis.height) #height
        
        #restore context
        @_dis.context.restore()
    _update: =>
        if @_dis.timer.getElapsedTime() >= (1000 / @_dis.frameRate)
            if @_dis.current.frame < @_dis.current.numFrames
                @_dis.current.frame += 1
            else
                @_dis.current.frame = 1
            @_dis.timer.restart()
        super()
#end class AniSprite



###
sound.coffee

Greenhorn Gaming Engine Sound class
###

#determine what kind of AudioContext is avaliable
if @AudioContext? or @webkitAudioContext?
    AudioContext = @AudioContext ? @webkitAudioContext
    _audioContext = new AudioContext()
else
    env.USE_AUDIO_TAG = true

#simple sound class
class @Sound
    #constructor
    constructor: (config = {}) ->
        #assign default values if they have been omitted
        for own key, value of env.SOUND_DEFAULT_CONFIG
            config[key] ?= value
        
        #prefix the environment sound path
        config.url = env.SOUND_PATH.concat config.url
        
        #if the user has chosen to use the audio tag
        #or the current browser doesn't support the web audio api (IE)
        if env.USE_AUDIO_TAG
            #instance variable
            @_audio = document.createElement 'audio'
            #source elements for this._audio
            mp3_src = document.createElement 'source'
            ogg_src = document.createElement 'source'
            wav_src = document.createElement 'source'
            
            #assign proper types
            mp3_src.type = 'audio/mpeg'
            ogg_src.type = 'audio/ogg'
            wav_src.type = 'audio/wav'
            
            #assign proper srcs
            if config.url.indexOf('.mp3') isnt -1
                mp3_src.src = config.url
                ogg_src.src = config.url.replace '.mp3', '.ogg'
                wav_src.src = config.url.replace '.mp3', '.wav'
            else if config.url.indexOf('.ogg') isnt -1
                ogg_src.src = config.url
                mp3_src.src = config.url.replace '.ogg', '.mp3'
                wav_src.src = config.url.replace '.ogg', '.wav'
            else if config.url.indexOf('.wav') isnt -1
                wav_src.src = config.url
                mp3_src.src = config.url.replace '.wav', '.mp3'
                ogg_src.src = config.url.replace '.wav', '.ogg'
            else
                throw new Error "Only .mp3, .ogg, and .wav file extensions are supported by the audio tag"
            
            #append sources to this._audio
            @_audio.appendChild mp3_src
            @_audio.appendChild ogg_src
            @_audio.appendChild wav_src
            
            if config.playOnLoad then @_audio.autoplay = true
        
        else
            #instance variables
            @_buffer = null
            @_source = null
            @_isEnded = true
            
            #request setup
            request = new XMLHttpRequest()
            request.open 'GET', config.url, true
            request.responseType = 'arraybuffer'
            
            #request event handlers
            request.successCallback = (buffer) =>
                @_buffer = buffer
                if config.playOnLoad then @play()
            request.errorCallback = ->
                throw new Error "Web Audio API Error"
            request.onload = ->
                _audioContext.decodeAudioData @response, @successCallback, @errorCallback
            
            #send request
            request.send()
    
    #sound control
    play: (opt = {}) ->
        if env.USE_AUDIO_TAG
            @_audio.loop = opt.loop ? false
            @_audio.volume = opt.volume ? 1.0
            @_audio.play()
        else
            if @_isEnded
                gainNode = _audioContext.createGain()
                gainNode.gain.value = opt.volume ? 1.0
                
                @_isEnded = false
                @_source = _audioContext.createBufferSource()
                @_source.buffer = @_buffer
                @_source.onended = =>
                    @_isEnded = true
                
                @_source.loop = opt.loop ? false
                @_source.connect gainNode
                gainNode.connect _audioContext.destination
                @_source.start()
    stop: ->
        if env.USE_AUDIO_TAG
            @_audio.pause()
            @_audio.currentTime = 0
        else
            @_source.stop()
#end class Sound



