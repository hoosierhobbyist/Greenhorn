###
sprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Sprite extends EventEmitter
    #closures
    _list = []
    _canvas = null
    _bounds = null
    _sortRule = (sp1, sp2) ->
        sp1._dis.level - sp2._dis.level
    _boundaryCallback = (ba, side) ->
        #cache boundaries
        _bounds ?=
            top: _canvas.height / 2
            bottom: -_canvas.height / 2
            right: _canvas.width / 2
            left: -_canvas.width / 2

        #return appropriate callback
        switch ba
            when 'DIE'
                -> @set 'visible', off, false
            when 'WRAP'
                switch side
                    when 'top'
                        -> @set 'top', _bounds.bottom, false
                    when 'bottom'
                        -> @set 'bottom', _bounds.top, false
                    when 'right'
                        -> @set 'right', _bounds.left, false
                    when 'left'
                        -> @set 'left', _bounds.right, false
            when 'STOP'
                switch side
                    when 'top'
                        -> @set 'top', _bounds.top - 1, false
                    when 'bottom'
                        -> @set 'bottom', _bounds.bottom + 1, false
                    when 'right'
                        -> @set 'right', _bounds.right - 1, false
                    when 'left'
                        -> @set 'left', _bounds.left + 1, false
            when 'SPRING'
                switch side
                    when 'top'
                        -> @change 'dy', env.SPRING_CONSTANT * (_bounds.top - @get('top', false)), false
                    when 'bottom'
                        -> @change 'dy', env.SPRING_CONSTANT * (_bounds.bottom - @get('bottom', false)), false
                    when 'right'
                        -> @change 'dx', env.SPRING_CONSTANT * (_bounds.right - @get('right', false)), false
                    when 'left'
                        -> @change 'dx', env.SPRING_CONSTANT * (_bounds.left - @get('left', false)), false
            when 'BOUNCE'
                switch side
                    when 'top'
                        ->
                            @set 'top', _bounds.top - 1, false
                            @_mot.dy *= -1 + env.BOUNCE_DECAY
                    when 'bottom'
                        ->
                            @set 'bottom', _bounds.bottom + 1, false
                            @_mot.dy *= -1 + env.BOUNCE_DECAY
                    when 'right'
                        ->
                            @set 'right', _bounds.right - 1, false
                            @_mot.dx *= -1 + env.BOUNCE_DECAY
                    when 'left'
                        ->
                            @set 'left', _bounds.left + 1, false
                            @_mot.dx *= -1 + env.BOUNCE_DECAY

    #class methods
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
    @emitAll = (event, args...) ->
        for sp in _list
            sp.emit event, args...
        return
    @remove = (sprite) ->
        sprite._stop() if sprite.isRunning()
        for sp, i in _list when sp is sprite
            _list.splice i, 1
            return
    @removeAll = (excep...) ->
        for sp in _list when sp not in excep
            sp._stop() if sp.isRunning()

        _list = []
        for sp in excep
            _list.push sp
        _list.sort _sortRule
        return
    @_drawAll = ->
        for sp in _list
            sp._draw()
        return
    @_startAll = ->
        for sp in _list
            sp._start()
        return
    @_stopAll = ->
        for sp in _list
            sp._stop()
        return

    #instance methods
    constructor: (config = {}) ->
        #cache class-level reference to gh-canvas
        _canvas ?= document.getElementById 'gh-canvas'

        #add missing keys to config
        for own key, value of env.SPRITE_DEFAULT_CONFIG
            config[key] ?= value

        #process config object
        size = {}
        angles = {}
        magnitudes = {}
        for own key, value of config
            if key.match /(^width$|^height$)/
                delete config[key]
                size[key] = value
            else if key.match /(^distance$|^speed$|^rate$|^scale$)/i
                delete config[key]
                magnitudes[key] = value
            else if key.match /(^posAngle$|^motAngle$|^accAngle$)/
                delete config[key]
                angles[key] = value
            else if key.match /^ba$/
                delete config[key]
                config.ba_top = value
                config.ba_bottom = value
                config.ba_right = value
                config.ba_left = value
            else if key.match /^on-\w+/
                delete config[key]
                if typeof value is 'function'
                    @on key.slice(3), value
                else if value.length?
                    @on key.slice(3), value[0], value[1]
            else if key.match /^once-\w+/
                delete config[key]
                if typeof value is 'function'
                    @once key.slice(5), value
                else if value.length?
                    @once key.slice(5), value[0], value[1]

        #create default boundary if none was provided
        unless config.bounds?
            if config.shape is 'polygon'
                _a = Math.atan2 size.height / 2, size.width / 2
                _dist = Math.sqrt (size.height / 2)**2 + (size.width / 2)**2
                config.bounds = [
                    {x: _dist * Math.cos(config.a + _a), y: _dist * Math.sin(config.a + _a)}
                    {x: _dist * Math.cos(config.a - _a), y: _dist * Math.sin(config.a - _a)}
                    {x: _dist * Math.cos(config.a + Math.PI + _a), y: _dist * Math.sin(config.a + Math.PI + _a)}
                    {x: _dist * Math.cos(config.a + Math.PI - _a), y: _dist * Math.sin(config.a + Math.PI - _a)}
                ]#end default boundary
            else if config.shape is 'circle'
                config.radius ?= Math.sqrt (size.height / 2)**2 + (size.width / 2)**2
            else
                throw new Error "config.shape must be either 'polygon' or 'circle'"
        else
            if config.shape isnt 'polygon'
                throw new Error "if config.bounds is defined, config.shape must be 'polygon'"

        #used to track asynchronous _update
        @_updateID = null

        #create primary objects
        @_pos = {}
        @_mot = {}
        @_acc = {}
        @_dis = {}
        @_bas = {}
        @_bnd = {}

        #create secondary objects
        @_dis.width = size.width
        @_dis.height = size.height
        @_dis.context = _canvas.getContext '2d'
        @_dis.image = document.createElement 'img'

        #set this sprite's configuration
        #"virtually" calls child's set method in "derived" classes
        @set 'config', config, false
        @set 'config', magnitudes, false
        @set 'config', angles, false

        #start updating if the engine is already running
        if Greenhorn.isRunning() then @_start()

        #add to class-level _list and sort by _dis.level
        _list.push this
        _list.sort _sortRule

    #_update control
    isRunning: ->
        @_updateID?
    _start: ->
        @emit 'start'
        @_updateID = setInterval @_update, 1000 / env.FRAME_RATE
    _stop: ->
        @emit 'stop'
        clearInterval @_updateID
        @_updateID = null

    #getter
    get: (what, _emit = true) ->
        if what.match /^imageFile$/
            value = @_dis.image.src
        else if what.match /(^x$|^y$|^a$)/
            value = @_pos[what]
        else if what.match /(^dx$|^dy$|^da$)/
            value = @_mot[what]
        else if what.match /(^ddx$|^ddy$|^dda$)/
            value = @_acc[what]
        else if what.match /^top$/
            if @_bnd.shape is 'polygon'
                value = (pt.get('y') for pt in @_bnd.points)
                value = Math.max value...
            else if @_bnd.shape is 'circle'
                value = @_pos.y + @_bnd.radius
        else if what.match /^bottom$/
            if @_bnd.shape is 'polygon'
                value = (pt.get('y') for pt in @_bnd.points)
                value = Math.min value...
            else if @_bnd.shape is 'circle'
                value = @_pos.y - @_bnd.radius
        else if what.match /^right$/
            if @_bnd.shape is 'polygon'
                value = (pt.get('x') for pt in @_bnd.points)
                value = Math.max value...
            else if @_bnd.shape is 'circle'
                value = @_pos.x + @_bnd.radius
        else if what.match /^left$/
            if @_bnd.shape is 'polygon'
                value = (pt.get('x') for pt in @_bnd.points)
                value = Math.min value...
            else if @_bnd.shape is 'circle'
                value = @_pos.x - @_bnd.radius
        else if what.match /^radius$/
            if @_bnd.radius?
                value = @_bnd.radius
            else
                value = (pt.get('dist') for pt in @_bnd.points)
                value = Math.max value...
        else if what.match /^distance$/
            value = Math.sqrt @_pos.x**2 + @_pos.y**2
        else if what.match /^speed$/
            value = Math.sqrt @_mot.dx**2 + @_mot.dy**2
        else if what.match /^rate$/
            value = Math.sqrt @_acc.ddx**2 + @_acc.ddy**2
        else if what.match /^posAngle$/
            value = Math.atan2 @_pos.y, @_pos.x
        else if what.match /^motAngle$/
            value = Math.atan2 @_mot.dy, @_mot.dx
        else if what.match /^accAngle$/
            value = Math.atan2 @_acc.ddy, @_acc.ddx
        else if what.match /(^width$|^height$)/
            value = @_dis[what] * @_dis.scale
        else if what.match /(^level$|^scale$|^visible$|^highlight$)/
            value = @_dis[what]
        else if what.match /^ba_(top|bottom|right|left)$/
            value = @_bas[what.split('_')[1]].ba
        else if what.match /^shape$/
            value = @_bnd.shape
        else
            value = @[what]
        if _emit then @emit "get:#{what}", value
        return value

    #setter
    set: (what, to, _emit = true) ->
        if what.match /(^x$|^y$)/
            old = @_pos[what] if _emit
            @_pos[what] = to
        else if what.match /^a$/
            if @_pos.a?
                diff = to - @_pos.a
            old = @_pos.a if _emit
            @_pos.a = to
            if diff and @_bnd.shape is 'polygon'
                for pt in @_bnd.points
                    pt.change 'a', diff
        else if what.match /(^dx$|^dy$|^da$)/
            old = @_mot[what] if _emit
            @_mot[what] = to
        else if what.match /(^ddx$|^ddy$|^dda$)/
            old = @_acc[what] if _emit
            @_acc[what] = to
        else if what.match /^top$/
            old = @get 'top', false if _emit
            if @_bnd.shape is 'polygon'
                _top = @_bnd.points[0]
                _top = pt for pt in @_bnd.points when pt._y > _top._y
                @_pos.y = to - _top._y
            else if @_bnd.shape is 'circle'
                @_pos.y = to - @get 'radius'
        else if what.match /^bottom$/
            old = @get 'bottom', false if _emit
            if @_bnd.shape is 'polygon'
                _bottom = @_bnd.points[0]
                _bottom = pt for pt in @_bnd.points when pt._y < _bottom._y
                @_pos.y = to - _bottom._y
            else if @_bnd.shape is 'circle'
                @_pos.y = to + @get 'radius'
        else if what.match /^right$/
            old = @get 'right', false if _emit
            if @_bnd.shape is 'polygon'
                _right = @_bnd.points[0]
                _right = pt for pt in @_bnd.points when pt._x > _right._x
                @_pos.x = to - _right._x
            else if @_bnd.shape is 'circle'
                @_pos.x = to - @get 'radius'
        else if what.match /^left$/
            old = @get 'left', false if _emit
            if @_bnd.shape is 'polygon'
                _left = @_bnd.points[0]
                _left = pt for pt in @_bnd.points when pt._x < _left._x
                @_pos.x = to - _left._x
            else if @_bnd.shape is 'circle'
                @_pos.x = to + @get 'radius'
        else if what.match /^radius$/
            old = @get 'radius', false if _emit
            if @_bnd.shape is 'circle'
                @_bnd.radius = to
            else
                throw new Error "Cannot set radius when shape isnt 'circle'"
        else if what.match /^imageFile$/
            old = @get 'imageFile', false if _emit
            if env.IMAGE_PATH.match /\/$/
                @_dis.image.src = env.IMAGE_PATH.concat to
            else
                if env.IMAGE_PATH
                    env.IMAGE_PATH += '/'
                    @_dis.image.src = env.IMAGE_PATH.concat to
                else
                    @_dis.image.src = to
        else if what.match /^distance$/
            old = @get 'distance', false if _emit
            proxy =
                x: to * Math.cos @get 'posAngle', false
                y: to * Math.sin @get 'posAngle', false
            @set '_pos', proxy, false
        else if what.match /^speed$/
            old = @get 'speed', false if _emit
            proxy =
                dx: to * Math.cos @get 'motAngle', false
                dy: to * Math.sin @get 'motAngle', false
            @set '_mot', proxy, false
        else if what.match /^rate$/
            old = @get 'rate', false if _emit
            proxy =
                ddx: to * Math.cos @get 'accAngle', false
                ddy: to * Math.sin @get 'accAngle', false
            @set '_acc', proxy, false
        else if what.match /^posAngle$/
            old = @get 'posAngle', false if _emit
            proxy =
                x: @get('distance', false) * Math.cos to
                y: @get('distance', false) * Math.sin to
            @set '_pos', proxy, false
        else if what.match /^motAngle$/
            old = @get 'motAngle', false if _emit
            proxy =
                dx: @get('speed', false) * Math.cos to
                dy: @get('speed', false) * Math.sin to
            @set '_mot', proxy, false
        else if what.match /^accAngle$/
            old = @get 'accAngle', false if _emit
            proxy =
                ddx: @get('rate', false) * Math.cos to
                ddy: @get('rate', false) * Math.sin to
            @set '_acc', proxy, false
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc|^config)/
            #set old to what here?
            @set k, v, false for own k, v of to
        else if what.match /(^level$|^visible$|^highlight$)/
            old = @_dis[what] if _emit
            @_dis[what] = to
            if what is 'level'
                _list.sort _sortRule
        else if what.match /^scale$/
            if @_dis.scale?
                if @_bnd.shape is 'polygon'
                    for pt in @_bnd.points
                        pt.set 'dist', pt.get('dist') / @_dis.scale
                else if @_bnd.shape is 'circle'
                    @set 'radius', @get('radius') / @_dis.scale
            old = @_dis.scale if _emit
            @_dis.scale = to
            if @_bnd.shape is 'polygon'
                for pt in @_bnd.points
                    pt.set 'dist', pt.get('dist') * @_dis.scale
            else if @_bnd.shape is 'circle'
                @set 'radius', @get('radius') * @_dis.scale
        else if what.match /^ba$/
            if _emit
                old = #deep copy?
                    ba_top: @bas['top']
                    ba_bottom: @bas['bottom']
                    ba_right: @bas['right']
                    ba_left: @bas['left']
            proxy =
                ba_top: to
                ba_bottom: to
                ba_right: to
                ba_left: to
            @set 'config', proxy, false
        else if what.match /^ba_(top|bottom|right|left)$/
            side = what.split('_')[1]
            oldCollision =
                if @_bas[side]?
                    if @_bas[side].ba.match /^(DIE|WRAP)$/
                        'off'
                    else
                        'hit'
                else ''
            newCollision =
                if to.match /(DIE|WRAP)/
                    'off'
                else if to.match /^(STOP|SPRING|BOUNCE)$/
                    'hit'
                else
                    throw new Error "#{to} is not a valid boundary action"
            old = @_bas[side] if _emit #deep copy?
            if @_bas[side]?
                @remove "#{oldCollision}:#{side}", @_bas[side]
            @_bas[side] = _boundaryCallback to, side
            @_bas[side].ba = to
            @on "#{newCollision}:#{side}", @_bas[side]
        else if what.match /^shape$/ #needs refining
            old = @_bnd.shape if _emit
            if @_bnd.shape is 'circle'
                if to is 'polygon'
                    @_bnd.radius = null
                    @_bnd.shape = to
            else if @_bnd.shape is 'polygon'
                if to is 'circle'
                    @_bnd.radius = @get 'radius'
                    @_bnd.shape = to
        else if what.match /^points$/
            old = @_bnd.points.slice 0 if _emit
            @_bnd.points = []
            for pt in to
                if pt.x? and pt.y?
                    @_bnd.points.push new Point pt.x, pt.y, this
        else
            old = @[what] if _emit
            @[what] = to
        if _emit then @emit "set:#{what}", old, to
        return this

    #changer
    #emit virtual change, real change or both?
    change: (what, step, _emit = true) ->
        if what.match /(^x$|^y$|^a$)/
            @_pos[what] += step / env.FRAME_RATE
            if what is 'a' and @_bnd.shape is 'polygon'
                pt.change('a', step / env.FRAME_RATE) for pt in @_bnd.points
        else if what.match /(^dx$|^dy$|^da$)/
            @_mot[what] += step / env.FRAME_RATE
        else if what.match /(^ddx$|^ddy$|^dda$)/
            @_acc[what] += step / env.FRAME_RATE
        else if what.match /^level$/
            @_dis.level += step / env.FRAME_RATE
        else if what.match /^distance$/
            proxy =
                dx: step * Math.cos @get 'posAngle', false
                dy: step * Math.sin @get 'posAngle', false
            @change '_pos', proxy, false
        else if what.match /^speed$/
            proxy =
                ddx: step * Math.cos @get 'motAngle', false
                ddy: step * Math.sin @get 'motAngle', false
            @change '_mot', proxy, false
        else if what.match /^rate$/
            proxy =
                dddx: step * Math.cos @get 'accAngle', false
                dddy: step * Math.sin @get 'accAngle', false
            @change '_acc', proxy, false
        else if what.match /^posAngle$/
            proxy =
                x: @get('distance', false) * Math.cos step + @get 'posAngle', false
                y: @get('distance', false) * Math.sin step + @get 'posAngle', false
            @set '_pos', proxy, false
        else if what.match /^motAngle$/
            proxy =
                dx: @get('speed', false) * Math.cos step + @get 'motAngle', false
                dy: @get('speed', false) * Math.sin step + @get 'motAngle', false
            @set '_mot', proxy, false
        else if what.match /^accAngle$/
            proxy =
                ddx: @get('rate', false) * Math.cos step + @get 'accAngle', false
                ddy: @get('rate', false) * Math.sin step + @get 'accAngle', false
            @set '_acc', proxy, false
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc)/
            @change k.slice(1), v, false for own k, v of step
        else
            @[what] += step / env.FRAME_RATE
        if _emit then @emit "change:#{what}", step
        return this

    #collision routines
    collidesWith: (other) ->
        if other is 'mouse'
            if @_dis.visible
                if @distanceTo('mouse') <= @get 'radius', false
                    if @_bnd.shape is 'circle'
                        return true
                    else
                        #declare Line arrays
                        outerLines = []
                        innerLines = []
                        mousePos = new Point Greenhorn.getMouseX(), Greenhorn.getMouseY(), _pos: {x: 0, y: 0}

                        #create Lines to check for collisions
                        for pt, i in @_bnd.points
                            innerLines.push new Line pt, mousePos
                            if i is @_bnd.points.length - 1
                                outerLines.push new Line pt, @_bnd.points[0]
                            else
                                outerLines.push new Line pt, @_bnd.points[i+1]

                        #check for collisions
                        for innerLine in innerLines
                            for outerLine in outerLines
                                unless innerLine._contains outerLine.p1
                                    unless innerLine._contains outerLine.p2
                                        if innerLine.collidesWith outerLine
                                            return false
                        return true
            return false
        else
            if @_dis.visible
                if other._dis.visible
                    if @_dis.level == other._dis.level
                        if @distanceTo(other) <= @get('radius', false) + other.get('radius', false)
                            if @_bnd.shape is 'circle' or other._bnd.shape is 'circle'
                                return true
                            else
                                #define points if circular
                                if @_bnd.shape is 'circle'
                                    unless @_bnd.points?
                                        #TODO figure out a good way to do this...

                                #declare Line arrays
                                myLines = []
                                otherLines = []

                                #create Lines representing boundaries
                                for pt, i in @_bnd.points
                                    if i is @_bnd.points.length - 1
                                        myLines.push new Line pt, @_bnd.points[0]
                                    else
                                        myLines.push new Line pt, @_bnd.points[i+1]
                                for pt, i in other._bnd.points
                                    if i is other._bnd.points.length - 1
                                        otherLines.push new Line pt, other._bnd.points[0]
                                    else
                                        otherLines.push new Line pt, other._bnd.points[i+1]

                                #check for collisions
                                for myLine in myLines
                                    for otherLine in otherLines
                                        if myLine.collidesWith otherLine
                                            return true
                                if @get('top') < other.get('top')
                                    if @get('bottom') > other.get('bottom')
                                        if @get('right') < other.get('right')
                                            if @get('left') > other.get('left')
                                                myLines = []
                                                for p1 in other._bnd.points
                                                    for p2 in @_bnd.points
                                                        myLines.push new Line p1, p2
                                                for myLine in myLines
                                                    for otherLine in otherLines
                                                        unless myLine._contains otherLine.p1
                                                            unless myLine._contains otherLine.p2
                                                                if myLine.collidesWith otherLine
                                                                    return false
                                                return true
                                if other.get('top') < @get('top')
                                    if other.get('bottom') > @get('bottom')
                                        if other.get('right') < @get('right')
                                            if other.get('left') > @get('left')
                                                otherLines = []
                                                for p1 in @_bnd.points
                                                    for p2 in other._bnd.points
                                                        otherLines.push new Line p1, p2
                                                for otherLine in otherLines
                                                    for myLine in myLines
                                                        unless otherLine._contains myLine.p1
                                                            unless otherLine._contains myLine.p2
                                                                if otherLine.collidesWith myLine
                                                                    return false
                                                return true
            return false
    distanceTo: (other) ->
        otherX = otherY = 0
        if other is 'mouse'
            otherX = Greenhorn.getMouseX()
            otherY = Greenhorn.getMouseY()
        else
            otherX = other._pos.x
            otherY = other._pos.y
        Math.sqrt (@_pos.x - otherX)**2 + (@_pos.y - otherY)**2
    angleTo: (other) ->
        otherX = otherY = 0
        if other is 'mouse'
            otherX = Greenhorn.getMouseX()
            otherY = Greenhorn.getMouseY()
        else
            otherX = other._pos.x
            otherY = other._pos.y
        Math.atan2(otherY - @_pos.y, otherX - @_pos.x)

    #update routines
    _draw: ->
        if @_dis.visible
            #save context
            @_dis.context.save()

            #fire draw:before event
            @emit 'draw:before'

            #translate and rotate
            @_dis.context.translate @_pos.x, -@_pos.y
            @_dis.context.rotate -@_pos.a
            @_dis.context.scale @_dis.scale, @_dis.scale

            #draw image
            @_dis.context.drawImage(
                @_dis.image, #imageFile
                -@_dis.width / 2, #left
                -@_dis.height / 2, #top
                @_dis.width, #width
                @_dis.height) #height

            #restore context
            @_dis.context.restore()

            #highlight boundaries
            if @_dis.highlight
                @_dis.context.save()
                @_dis.context.lineWidth = 3
                @_dis.context.strokeStyle = 'white'
                @_dis.context.beginPath()
                @_dis.context.moveTo @_bnd.points[0].get('x'), -@_bnd.points[0].get('y')
                for pt, i in @_bnd.points when i isnt 0
                    @_dis.context.lineTo pt.get('x'), -pt.get('y')
                @_dis.context.closePath()
                @_dis.context.stroke()
                @_dis.context.restore()

            #fire draw:after event
            @emit 'draw:after'
    _update: =>
        #fire update event
        @emit 'update'

        #accelerate and move
        @change '_mot', @_acc, false
        @change '_pos', @_mot, false

        #fire 'off:boundary' events
        if @get('bottom', false) > _bounds.top then @emit 'off:top'
        if @get('top', false) < _bounds.bottom then @emit 'off:bottom'
        if @get('left', false) > _bounds.right then @emit 'off:right'
        if @get('right', false) < _bounds.left then @emit 'off:left'

        #fire 'hit:boundary' events
        if @get('top', false) >= _bounds.top then @emit 'hit:top'
        if @get('bottom', false) <= _bounds.bottom then @emit 'hit:bottom'
        if @get('right', false) >= _bounds.right then @emit 'hit:right'
        if @get('left', false) <= _bounds.left then @emit 'hit:left'

        #determine other events to fire
        for own event, listeners of @_events
            #fire 'mouse:hover' event
            if event.match /^mouse:hover$/
                if @collidesWith 'mouse'
                    @emit event
            #fire 'mouse:noHover' event
            if event.match /^mouse:!hover$/
                unless @collidesWith 'mouse'
                    @emit event
            #fire 'isDown' event
            if event.match /^isDown:(\w+|\d)/
                token = event.split(':')[1].toUpperCase()
                if token.match /-/
                    _emit = false
                    keys = token.split '-'
                    for key in keys
                        if Greenhorn.isDown[KEYS[key]]
                            _emit = true
                    if _emit then @emit event
                else if token.match /\+/
                    _emit = true
                    keys = token.split '+'
                    for key in keys
                        unless Greenhorn.isDown[KEYS[key]]
                            _emit = false
                    if _emit then @emit event
                else
                    if Greenhorn.isDown[KEYS[token]]
                        @emit event
            #fire 'isUp' event
            else if event.match /^isUp:(\w+|\d)/
                token = event.split(':')[1].toUpperCase()
                if token.match /-/
                    _emit = false
                    keys = token.split '-'
                    for key in keys
                        unless Greenhorn.isDown[KEYS[key]]
                            _emit = true
                    if _emit then @emit event
                else if token.match /\+/
                    _emit = true
                    keys = token.split '+'
                    for key in keys
                        if Greenhorn.isDown[KEYS[key]]
                            _emit = false
                    if _emit then @emit event
                else
                    unless Greenhorn.isDown[KEYS[token]]
                        @emit event
            #fire 'collisionWith:other' events
            else if event.match /^collisionWith:\w+/
                if @collidesWith listeners.other
                    @emit event, listeners.other
            #fire 'noCollisionWith:other' events
            else if event.match /^!collisionWith:\w+/
                unless @collidesWith listeners.other
                    @emit event, listeners.other
            #fire 'distanceTo:other-cmp-value' events
            else if event.match /^distanceTo:\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/
                tokens = event.split(':')[1]
                tokens = tokens.split '-'
                tokens[2] = parseFloat tokens[2]
                switch tokens[1]
                    when 'gt'
                        if @distanceTo(listeners.other) > tokens[2]
                            @emit event, listeners.other
                    when 'lt'
                        if @distanceTo(listeners.other) < tokens[2]
                            @emit event, listeners.other
                    when 'eq'
                        if @distanceTo(listeners.other) == tokens[2]
                            @emit event, listeners.other
                    when 'ge'
                        if @distanceTo(listeners.other) >= tokens[2]
                            @emit event, listeners.other
                    when 'le'
                        if @distanceTo(listeners.other) <= tokens[2]
                            @emit event, listeners.other
                    when 'ne'
                        if @distanceTo(listeners.other) != tokens[2]
                            @emit event, listeners.other
            #fire 'angleTo:other-cmp-value' events
            else if event.match /^angleTo:\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/
                tokens = event.split(':')[1]
                tokens = tokens.split '-'
                tokens[2] = parseFloat tokens[2]
                switch tokens[1]
                    when 'gt'
                        if @angleTo(listeners.other) > tokens[2]
                            @emit event, listeners.other
                    when 'lt'
                        if @angleTo(listeners.other) < tokens[2]
                            @emit event, listeners.other
                    when 'eq'
                        if @angleTo(listeners.other) == tokens[2]
                            @emit event, listeners.other
                    when 'ge'
                        if @angleTo(listeners.other) >= tokens[2]
                            @emit event, listeners.other
                    when 'le'
                        if @angleTo(listeners.other) <= tokens[2]
                            @emit event, listeners.other
                    when 'ne'
                        if @angleTo(listeners.other) != tokens[2]
                            @emit event, listeners.other
            #fire 'attr-cmp-value' events
            else if event.match /^\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/
                tokens = event.split '-'
                tokens[2] = parseFloat tokens[2]
                switch tokens[1]
                    when 'gt'
                        if @get(tokens[0], false) > tokens[2]
                            @emit event
                    when 'lt'
                        if @get(tokens[0], false) < tokens[2]
                            @emit event
                    when 'eq'
                        if @get(tokens[0], false) == tokens[2]
                            @emit event
                    when 'ge'
                        if @get(tokens[0], false) >= tokens[2]
                            @emit event
                    when 'le'
                        if @get(tokens[0], false) <= tokens[2]
                            @emit event
                    when 'ne'
                        if @get(tokens[0], false) != tokens[2]
                            @emit event
            else if event.match /^\w+-(eq|ne)-\w+/
                tokens = event.split '-'
                if tokens[2].match /(^true$|^false$)/
                    tokens[2] = (0, eval)(tokens[2])
                switch tokens[1]
                    when 'eq'
                        if @get(tokens[0], false) is tokens[2]
                            @emit event
                    when 'ne'
                        if @get(tokens[0], false) isnt tokens[2]
                            @emit event
        this

    #debugging
    report: ->
        """
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
        display:
            level: #{@_dis.level}
            scale: #{@_dis.scale}
            width: #{@_dis.width}
            height: #{@_dis.height}
            visible: #{@_dis.visible}
            highlight: #{@_dis.highlight}
        bound actions:
            top: #{@_bas.top.ba}
            bottom: #{@_bas.bottom.ba}
            right: #{@_bas.right.ba}
            left: #{@_bas.left.ba}
        """

#add to namespace object
gh.Sprite = Sprite
