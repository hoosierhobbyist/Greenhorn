###
sprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#core engine class
class @Sprite
    #<---CLASS-LEVEL--->
    #used to track all Sprite instances
    _list = []
    _sortRule = (sp1, sp2) ->
        sp1._dis.level - sp2._dis.level

    #collective manipulation
    @howMany = ->
        _list.length
    @getAll = (what, excep...) ->
        for sp in _list when sp not in excep
            sp.get what
    @setAll = (what, to, excep...) ->
        for sp in _list when sp not in excep
            sp.set what, to
        return
    @changeAll = (what, step, excep...) ->
        for sp in _list when sp not in excep
            sp.change what, step
        return
    @_drawAll = ->
        for sp in _list
            sp._draw()
        return
    @_startAll = ->
        for sp in _list
            sp.start()
        return
    @_stopAll = ->
        for sp in _list
            sp.stop()
        return

    #<---INSTANCE-LEVEL--->
    constructor: (config = {}) ->
        #forbidden key regex
        forbidden = /(^ditance$|^speed$|^rate$|^posAngle$|^motAngle$|^accAngle$)/i

        #throw an error if a forbidden key is provided in the configuration
        for own key of config when key.match forbidden
            throw new Error "#{key} is a forbidden config value"

        #add missing keys to config
        for own key, value of env.SPRITE_DEFAULT_CONFIG
            config[key] ?= value

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

        #set this sprite's configuration
        #"virtually" calls child's set method in derived classes
        @set 'config', config

        #start updating if the engine is already running
        if Greenhorn.isRunning() then @_start()

        #add to Sprite _list and sort by level
        _list.push this
        _list.sort _sortRule

    #_update control
    _start: ->
        @_updateID = setInterval @_update, 1000 / env.FRAME_RATE
    _stop: ->
        clearInterval @_updateID
        @_updateID = null
    isRunning: ->
        @_updateID?

    #getter
    get: (what) ->
        if what.match /^imageFile$/i
            @_dis.image.src
        else if what.match /(^x$|^y$|^a$)/i
            @_pos[what.toLowerCase()]
        else if what.match /(^dx$|^dy$|^da$)/i
            @_mot[what.toLowerCase()]
        else if what.match /(^ddx$|^ddy$|^dda$)/i
            @_acc[what.toLowerCase()]
        else if what.match /^top$/i
            @_pos.y + @_dis.height / 2
        else if what.match /^bottom$/i
            @_pos.y - @_dis.height / 2
        else if what.match /^right$/i
            @_pos.x + @_dis.width / 2
        else if what.match /^left$/i
            @_pos.x - @_dis.width / 2
        else if what.match /^distance$/i
            Math.sqrt @_pos.x**2 + @_pos.y**2
        else if what.match /^speed$/i
            Math.sqrt @_mot.dx**2 + @_mot.dy**2
        else if what.match /^rate$/i
            Math.sqrt @_acc.ddx**2 + @_acc.ddy**2
        else if what.match /^posAngle$/i
            Math.atan2 -@_pos.y, @_pos.x
        else if what.match /^motAngle$/i
            Math.atan2 -@_mot.dy, @_mot.dx
        else if what.match /^accAngle$/i
            Math.atan2 -@_acc.ddy, @_acc.ddx
        else if what.match /(^level$|^width$|^height$|^visible$|^boundAction$)/
            @_dis[what]
        else
            throw new Error "#{what} is not a get-able Sprite attribute"

    #setter
    set: (what, to) ->
        if what.match /^imageFile$/i
            @_dis.image.src = env.IMAGE_PATH.concat to
        else if what.match /(^x$|^y$|^a$)/i
            @_pos[what.toLowerCase()] = to
        else if what.match /(^dx$|^dy$|^da$)/i
            @_mot[what.toLowerCase()] = to
        else if what.match /(^ddx$|^ddy$|^dda$)/i
            @_acc[what.toLowerCase()] = to
        else if what.match /^top$/i
            @_pos.y = to - @_dis.height / 2
        else if what.match /^bottom$/i
            @_pos.y = to + @_dis.height / 2
        else if what.match /^right$/i
            @_pos.x = to - @_dis.width / 2
        else if what.match /^left$/i
            @_pos.x = to + @_dis.width / 2
        else if what.match /^distance$/i
            proxy =
                x: to * Math.cos @get('posAngle')
                y: to * Math.sin @get('posAngle')
            @set '_pos', proxy
        else if what.match /^speed$/i
            proxy =
                dx: to * Math.cos @get('motAngle')
                dy: to * Math.sin @get('motAngle')
            @set '_mot', proxy
        else if what.match /^rate$/i
            proxy =
                ddx: to * Math.cos @get('accAngle')
                ddy: to * Math.sin @get('accAngle')
            @set '_acc', proxy
        else if what.match /^posAngle$/i
            proxy =
                x: @get('distance') * Math.cos to
                y: @get('distance') * Math.sin to
            @set '_pos', proxy
        else if what.match /^motAngle$/i
            proxy =
                dx: @get('speed') * Math.cos to
                dy: @get('speed') * Math.sin to
            @set '_mot', proxy
        else if what.match /^accAngle$/i
            proxy =
                ddx: @get('rate') * Math.cos to
                ddy: @get('rate') * Math.sin to
            @set '_acc', proxy
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc|^config)/i
            @set k, v for own k, v of to
        else if what.match /(^level$|^width$|^height$|^visible$|^boundAction$)/
            @_dis[what] = to
            _list.sort _sortRule if what is 'level'
        else
            throw new Error "#{what} is not a set-able Sprite attribute"
        this

    #changer
    change: (what, step) ->
        if what.match /(^x$|^y$|^a$)/i
            @_pos[what.toLowerCase()] += step / env.FRAME_RATE
        else if what.match /(^dx$|^dy$|^da$)/i
            @_mot[what.toLowerCase()] += step / env.FRAME_RATE
        else if what.match /(^ddx$|^ddy$|^dda$)/i
            @_acc[what.toLowerCase()] += step / env.FRAME_RATE
        else if what.match /(^level$|^width$|^height$)/i
            @_dis[what.toLowerCase()] += step / env.FRAME_RATE
        else if what.match /^distance$/i
            proxy =
                dx: step * Math.cos @get('posAngle')
                dy: step * Math.sin @get('posAngle')
            @change '_pos', proxy
        else if what.match /^speed$/i
            proxy =
                ddx: step * Math.cos @get('motAngle')
                ddy: step * Math.sin @get('motAngle')
            @change '_mot', proxy
        else if what.match /^rate$/i
            proxy =
                dddx: step * Math.cos @get('accAngle')
                dddy: step * Math.sin @get('accAngle')
            @change '_acc', proxy
        else if what.match /^posAngle$/i
            proxy =
                dx: @get('distance') * Math.cos step
                dy: @get('distance') * Math.sin step
            @change '_pos', proxy
        else if what.match /^motAngle$/i
            proxy =
                ddx: @get('speed') * Math.cos step
                ddy: @get('speed') * Math.sin step
            @change '_mot', proxy
        else if what.match /^accAngle$/i
            proxy =
                dddx: @get('rate') * Math.cos step
                dddy: @get('rate') * Math.sin step
            @change '_acc', proxy
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc)/i
            @change k.slice(1), v for own k, v of step
        else
            throw new Error "#{what} is not a change-able Sprite attribute"
        this

    #collision routines
    collidesWith: (other) ->
        if other is 'mouse'
            collision = false
            if @_dis.visible
                if @get('left') < Greenhorn.getMouseX() < @get('right') and
                @get('bottom') < Greenhorn.getMouseY() < @get('top')
                    collision = true
        else
            collision = true
            if @_dis.visible and other.get('visible') and @_dis.level == other.get('level')
                if @get('bottom') > other.get('top') or
                @get('top') < other.get('bottom') or
                @get('right') < other.get('left') or
                @get('left') > other.get('right')
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
        Math.atan2 @_pos.y - otherY, @_pos.x - otherX

    #update routines
    _draw: ->
        if @_dis.visible
            #save context
            @_dis.context.save()

            #translate and rotate
            @_dis.context.translate @_pos.x, -@_pos.y
            @_dis.context.rotate -@_pos.a

            #draw image
            @_dis.context.drawImage(
                @_dis.image, #imageFile
                -@_dis.width / 2, #left
                -@_dis.height / 2, #top
                @_dis.width, #width
                @_dis.height) #height

            #restore context
            @_dis.context.restore()
    _update: =>
        if @_dis.visible
            #accelerate and move
            @change '_mot', @_acc
            @change '_pos', @_mot

            #check boundaries
            bounds =
                top: Greenhorn.get('canvas', 'height') / 2
                bottom: -Greenhorn.get('canvas', 'height') / 2
                right: Greenhorn.get('canvas', 'width') / 2
                left: -Greenhorn.get('canvas', 'width') / 2

            #sprite has completely disappeared offscreen
            offTop = @get('bottom') > bounds.top
            offBottom = @get('top') < bounds.bottom
            offRight = @get('left') > bounds.right
            offLeft = @get('right') < bounds.left

            #sprite has just come into contact with a boundary
            hitTop = @get('top') >= bounds.top
            hitBottom = @get('bottom') <= bounds.bottom
            hitRight = @get('right') >= bounds.right
            hitLeft = @get('left') <= bounds.left

            #determine how to behave at boundaries
            switch @_dis.boundAction
                when 'DIE'
                    if offTop or offBottom or offRight or offLeft
                        @_dis.visible = false
                when 'WRAP'
                    if offTop
                        @set 'top', bounds.bottom
                    if offBottom
                        @set 'bottom', bounds.top
                    if offRight
                        @set 'right', bounds.left
                    if offLeft
                        @set 'left', bounds.right
                when 'STOP'
                    if hitTop
                        @set 'top', bounds.top - 1
                    if hitBottom
                        @set 'bottom', bounds.bottom + 1
                    if hitRight
                        @set 'right', bounds.right - 1
                    if hitLeft
                        @set 'left', bounds.left + 1
                when 'BOUNCE'
                    if hitTop
                        @set 'top', bounds.top - 1
                        @_mot.dy *= -1 + env.ENGINE.bounceDecay
                    if hitBottom
                        @set 'bottom', bounds.bottom + 1
                        @_mot.dy *= -1 + env.ENGINE.bounceDecay
                    if hitRight
                        @set 'right', bounds.right - 1
                        @_mot.dx *= -1 + env.ENGINE.bounceDecay
                    if hitLeft
                        @set 'left', bounds.left + 1
                        @_mot.dx *= -1 + env.ENGINE.bounceDecay
        this

    #debugging
    report: ->
        """
        display:
            level: #{Math.round @_dis.level}
            width: #{Math.round @_dis.width}
            height: #{Math.round @_dis.height}
            visible: #{@_dis.visible}
            boundAction: #{@_dis.boundAction}
        position:
            x: #{@_pos.x.toFixed 2}
            y: #{@_pos.y.toFixed 2}
            a: #{@_pos.a.toFixed 2}
        motion:
            dx: #{@_mot.dx.toFixed 2}
            dy: #{@_mot.dy.toFixed 2}
            da: #{@_mot.da.toFixed 2}
        acceleration:
            ddx: #{@_acc.ddx.toFixed 2}
            ddy: #{@_acc.ddy.toFixed 2}
            dda: #{@_acc.dda.toFixed 2}
        """
    log: ->
        console.log @report()
        return
#end class Sprite

#more natural alias for
#calling collective methods
@Sprites = @Sprite
