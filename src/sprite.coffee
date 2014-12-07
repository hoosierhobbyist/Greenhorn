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
    #used to track all Sprite instances
    _list = []
    _sortRule = makeSortRule "z", "ascending"
    
    #Sprite class methods
    @howMany = -> _list.length
    @_drawAll = ->
        sp._draw() for sp in _list
        return
    @_startAll = ->
        sp._start() for sp in _list
        return
    @_stopAll = ->
        sp._stop() for sp in _list
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
        
        #used to track asynchronous _update
        @_updateID = null
        
        #create primary objects
        @_dis = {}
        @_pos = {}
        @_mot = {}
        @_acc = {}
        
        #create secondary objects
        @_dis.image = new Image()
        @_dis.context = document.querySelector('#gh-canvas').getContext('2d')
        
        #add the environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.SPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #set this sprite's configuration
        @set 'config', config
        
        #start updating if the engine is already running
        if Greenhorn.isRunning() then @_start()
        
        #sort the Sprite _list according to _sortRule
        _list.push this
        _list.sort _sortRule
    
    #start and stop _update function
    _start: ->
        @_updateID = setInterval _update, 1000 / env.FRAME_RATE
    _stop: ->
        clearInterval @_updateID
        @_updateID = null
    isRunning: ->
        @_updateID?
    
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
        if other is 'mouse'
            collision = false
            if @_dis.visible
                if @get("left") < Greenhorn.getMouseX() < @get("right") and
                @get("bottom") < Greenhorn.getMouseY() < @get("top")
                    collision = true
        else
            collision = true
            if @_dis.visible and other.get("visible") and @_pos.z == other.get("z")
                if @get("bottom") > other.get("top") or
                @get("top") < other.get("bottom") or
                @get("right") < other.get("left") or
                @get("left") > other.get("right")
                    collision = false
            else collision = false
        collision
    distanceTo: (other) ->
        otherX = otherY = 0
        if other is 'mouse'
            otherX = Greenhorn.getMouseX()
            otherY = Greenhorn.getMouseY()
        else
            otherX = other.get 'x'
            otherY = other.get 'y'
        Math.sqrt (@_pos.x - otherX)**2 + (@_pos.y - otherY)**2
    angleTo: (other) ->
        otherX = otherY = 0
        if other is 'mouse'
            otherX = Greenhorn.getMouseX()
            otherY = Greenhorn.getMouseY()
        else
            otherX = other.get 'x'
            otherY = other.get 'y'
        -Math.atan2 otherY - @_pos.y, otherX - @_pos.x
    
    #update routines
    _draw: ->
        if @_dis.visible
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
