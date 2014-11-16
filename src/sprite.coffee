###
sprite.coffee

The Greenhorn Gaming Engine core class
###

#Sprite boundaryAction enumeration
BOUND_ACTIONS =
    WRAP: 0
    BOUNCE: 1
    SEMIBOUNCE: 2
    STOP: 3
    DIE: 4
    CONTINUE: 5

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
    @_updateAll = -> sp._update() for sp in _list
    #@sortBy = (@_sortRule) -> @resort()
    
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
        @_borders = {}
        
        #get the context used to draw sprite
        @_dis.context = Greenhorn._elmnts.canvas.getContext "2d"
        
        #add the environment defaults to config,
        #if the user has chosen to omit them
        for key, value of env.SPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #set this sprite's configuration
        @set "config", config
        
        #experimental: setInterval to check bounds
        setInterval @_checkBounds, Math.ceil 1000 / env.FRAME_RATE
        
        #sort the Sprite _list according to _sortRule
        _list.push this
        _list.sort _sortRule
        
        #return this
        @
    
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
            when "borders"
                @_borders
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
            when "top", "bottom", "right", "left"
                @_borders[what]
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
                @set k, v for k, v of to
            when "imageFile"
                @_dis.image ?= new Image()
                @_dis.image.src = env.IMAGE_PATH.concat to
            when "boundAction"
                @_dis.boundAction = BOUND_ACTIONS[to]
            when "width", "height", "visible"
                @_dis[what] = to
                @_calcBorders() if what is "width" or what is "height"
            when "x", "y", "z", "a"
                @_pos[what] = to
                @_calcBorders() if what is "x" or what is "y"
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
                @change k.slice(1), v for k, v of step
            when "width", "height"
                @_dis[what] += step
                @_calcBorders()
            when "x", "y", "z", "a"
                @_pos[what] += step / env.FRAME_RATE
                @_calcBorders() if what is "x" or what is "y"
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
        if @_dis.visible and other._dis.visible and @_pos.z == other.get "z"
            if @_borders.bottom > other._borders.top or
            @_borders.top < other._borders.bottom or
            @_borders.right < other._borders.left or
            @_borders.left > other._borders.right
                collision = false
        else collision = false
        collision
    collidesWithMouse: ->
        collision = false
        if @_dis.visible
            if @_borders.left < Greenhorn.getMouseX() < @_borders.right and
            @_borders.bottom < Greenhorn.getMouseY() < @_borders.top
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
    
    #internal adjustments
    _calcBorders: () ->
        @_borders.left = @_pos.x - @_dis.width / 2
        @_borders.right = @_pos.x + @_dis.width / 2
        @_borders.top = @_pos.y + @_dis.height / 2
        @_borders.bottom = @_pos.y - @_dis.height / 2
    
    #update routines
    _draw: ->
        @_dis.context.save()
        @_dis.context.translate @_pos.x, -@_pos.y
        @_dis.context.rotate -@_pos.a
        @_dis.context.drawImage @_dis.image, 0 - @_dis.width / 2, 0 - @_dis.height / 2, @_dis.width, @_dis.height
        @_dis.context.restore()
    _checkBounds: =>
        #canvas boundaries
        bounds =
            top: Greenhorn.get("canvas", "height") / 2
            bottom: -Greenhorn.get("canvas", "height") / 2
            right: Greenhorn.get("canvas", "width") / 2
            left: -Greenhorn.get("canvas", "width") / 2
        borders =
            top: @_pos.y + @_dis.height / 2
            bottom: @_pos.y - @_dis.height / 2
            right: @_pos.x + @_dis.width / 2
            left: @_pos.x - @_dis.width / 2
        
        #sprite has completely disappeared offscreen
        offTop = borders.bottom > bounds.top
        offBottom = borders.top < bounds.bottom
        offRight = borders.left > bounds.right
        offLeft = borders.right < bounds.left
        
        #sprite has just come into contact with a boundary
        hitTop = borders.top >= bounds.top
        hitBottom = borders.bottom <= bounds.bottom
        hitRight = borders.right >= bounds.right
        hitLeft = borders.left <= bounds.left
        
        switch @_dis.boundAction
            when BOUND_ACTIONS.WRAP
                if offTop
                    @set "y", bounds.bottom - @_dis.height / 2
                if offBottom
                    @set "y", bounds.top + @_dis.height / 2
                if offRight
                    @set "x", bounds.left - @_dis.width / 2
                if offLeft
                    @set "x", bounds.right + @_dis.width / 2
            when BOUND_ACTIONS.BOUNCE
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
            when BOUND_ACTIONS.SEMIBOUNCE
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
            when BOUND_ACTIONS.STOP
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
            when BOUND_ACTIONS.DIE
                if offTop or offBottom or offRight or offLeft
                    @_dis.visible = no
        @_dis.boundAction
    _update: ->
        if @_dis.visible
            @change "motion", @_acc
            @change "position", @_mot
            #@_checkBounds()
            @_draw()
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