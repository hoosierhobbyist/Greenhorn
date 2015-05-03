###
sprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Sprite extends EventEmitter
    #closures
    _list = []
    _canvas = Greenhorn.canvas
    _bounds =
        top: _canvas.height / 2
        bottom: -_canvas.height / 2
        right: _canvas.width / 2
        left: -_canvas.width / 2
    _sortRule = (sp1, sp2) ->
        sp1._dis.level - sp2._dis.level
    _boundaryCallbacks =
        'DIE':
            'top': -> @set 'visible', off, false
            'bottom': -> @set 'visible', off, false
            'right': -> @set 'visible', off, false
            'left': -> @set 'visible', off, false
        'WRAP':
            'top': -> @set 'top', _bounds.bottom, false
            'bottom': -> @set 'bottom', _bounds.top, false
            'right': -> @set 'right', _bounds.left, false
            'left': -> @set 'left', _bounds.right, false
        'STOP':
            'top': -> @set 'top', _bounds.top - 1, false
            'bottom': -> @set 'bottom', _bounds.bottom + 1, false
            'right': -> @set 'right', _bounds.right - 1, false
            'left': -> @set 'left', _bounds.left + 1, false
        'SPRING':
            'top': -> @change 'dy', Sprite.config.springConstant * (_bounds.top - @get('top', false)), false
            'bottom': -> @change 'dy', Sprite.config.springConstant * (_bounds.bottom - @get('bottom', false)), false
            'right': -> @change 'dx', Sprite.config.springConstant * (_bounds.right - @get('right', false)), false
            'left': -> @change 'dx', Sprite.config.springConstant * (_bounds.left - @get('left', false)), false
        'BOUNCE':
            'top': ->
                @set 'top', _bounds.top - 1, false
                @_mot.dy *= -1 + Sprite.config.bounceDecay
            'bottom': ->
                @set 'bottom', _bounds.bottom + 1, false
                @_mot.dy *= -1 + Sprite.config.bounceDecay
            'right': ->
                @set 'right', _bounds.right - 1, false
                @_mot.dx *= -1 + Sprite.config.bounceDecay
            'left': ->
                @set 'left', _bounds.left + 1, false
                @_mot.dx *= -1 + Sprite.config.bounceDecay

    #class objects
    @config:
        path: './'
        bounceDecay: 0
        springConstant: 25
    @defaults:
        x: 0
        y: 0
        a: 0
        dx: 0
        dy: 0
        da: 0
        ddx: 0
        ddy: 0
        dda: 0
        level: 0
        scale: 1
        width: 64
        height: 64
        visible: yes
        imageFile: ''
        shape: 'polygon'
        highlight: false
        ba_top: 'WRAP'
        ba_bottom: 'WRAP'
        ba_right: 'WRAP'
        ba_left: 'WRAP'

    #class methods
    @howMany: ->
        _list.length
    @getAll: (what, excep...) ->
        sp.get what for sp in _list when sp not in excep
    @setAll: (what, to, excep...) ->
        sp.set what, to for sp in _list when sp not in excep
        return
    @changeAll: (what, step, excep...) ->
        sp.change what, step for sp in _list when sp not in excep
        return
    @emitAll: (event, args...) ->
        sp.emit event, args... for sp in _list
        return
    @remove: (sprite) ->
        sprite._stop() if sprite.isRunning()
        i = _list.indexOf sprite
        if i > -1 then _list.splice i, 1
    @removeAll: (excep...) ->
        for sp in _list when sp not in excep
            sp._stop() if sp.isRunning()
        _list = []
        _list.push sp for sp in excep
        _list.sort _sortRule
        return
    @_drawAll: ->
        sp._draw() for sp in _list
        return
    @_startAll: ->
        sp._start() for sp in _list
        return
    @_stopAll: ->
        sp._stop() for sp in _list
        return

    #instance methods
    constructor: (config = {}) ->
        #call EventEmitter constructor
        super()

        #add missing keys to config
        for own key, value of Sprite.defaults
            config[key] ?= value

        #process config object
        size = {}
        angles = {}
        magnitudes = {}
        for own key, value of config
            if /(^width$|^height$)/.test key
                delete config[key]
                size[key] = value
            else if /(^distance$|^speed$|^rate$|^scale$)/.test key
                delete config[key]
                magnitudes[key] = value
            else if /(^posAngle$|^motAngle$|^accAngle$)/.test key
                delete config[key]
                angles[key] = value
            else if /^ba$/.test key
                delete config[key]
                config.ba_top = value
                config.ba_bottom = value
                config.ba_right = value
                config.ba_left = value
            else if /^on-\w+/.test key
                delete config[key]
                if typeof value is 'function'
                    @on key.slice(3), value
                else if Object.prototype.toString.call(value) is '[object Array]'
                    @on key.slice(3), value[0], value[1]
            else if /^once-\w+/.test key
                delete config[key]
                if typeof value is 'function'
                    @once key.slice(5), value
                else if Object.prototype.toString.call(value) is '[object Array]'
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
        @_updateID = setInterval (=> @_update), 1000 / Greenhorn.config.frameRate
    _stop: ->
        @emit 'stop'
        clearInterval @_updateID
        @_updateID = null

    #getter
    get: (what, _emit = true) ->
        if /^imageFile$/.test what
            value = @_dis.image.src
        else if /(^x$|^y$|^a$)/.test what
            value = @_pos[what]
        else if /(^dx$|^dy$|^da$)/.test what
            value = @_mot[what]
        else if /(^ddx$|^ddy$|^dda$)/.test what
            value = @_acc[what]
        else if /^top$/.test what
            if @_bnd.shape is 'polygon'
                value = (pt.get('y') for pt in @_bnd.points)
                value = Math.max value...
            else if @_bnd.shape is 'circle'
                value = @_pos.y + @_bnd.radius
        else if /^bottom$/.test what
            if @_bnd.shape is 'polygon'
                value = (pt.get('y') for pt in @_bnd.points)
                value = Math.min value...
            else if @_bnd.shape is 'circle'
                value = @_pos.y - @_bnd.radius
        else if /^right$/.test what
            if @_bnd.shape is 'polygon'
                value = (pt.get('x') for pt in @_bnd.points)
                value = Math.max value...
            else if @_bnd.shape is 'circle'
                value = @_pos.x + @_bnd.radius
        else if /^left$/.test what
            if @_bnd.shape is 'polygon'
                value = (pt.get('x') for pt in @_bnd.points)
                value = Math.min value...
            else if @_bnd.shape is 'circle'
                value = @_pos.x - @_bnd.radius
        else if /^radius$/.test what
            if @_bnd.radius?
                value = @_bnd.radius
            else
                value = (pt.get('dist') for pt in @_bnd.points)
                value = Math.max value...
        else if /^distance$/.test what
            value = Math.sqrt @_pos.x**2 + @_pos.y**2
        else if /^speed$/.test what
            value = Math.sqrt @_mot.dx**2 + @_mot.dy**2
        else if /^rate$/.test what
            value = Math.sqrt @_acc.ddx**2 + @_acc.ddy**2
        else if /^posAngle$/.test what
            value = Math.atan2 @_pos.y, @_pos.x
        else if /^motAngle$/.test what
            value = Math.atan2 @_mot.dy, @_mot.dx
        else if /^accAngle$/.test what
            value = Math.atan2 @_acc.ddy, @_acc.ddx
        else if /(^width$|^height$)/.test what
            value = @_dis[what] * @_dis.scale
        else if /(^level$|^scale$|^visible$|^highlight$)/.test what
            value = @_dis[what]
        else if /^ba_(top|bottom|right|left)$/.test what
            value = @_bas[what.split('_')[1]].ba
        else if /^shape$/.test what
            value = @_bnd.shape
        else
            value = @[what]
        if _emit then @emit "get:#{what}", value
        return value

    #setter
    set: (what, to, _emit = true) ->
        if /(^x$|^y$)/.test what
            old = @_pos[what] if _emit
            @_pos[what] = to
        else if /^a$/.test what
            if @_pos.a?
                diff = to - @_pos.a
            old = @_pos.a if _emit
            @_pos.a = to
            if diff and @_bnd.shape is 'polygon'
                for pt in @_bnd.points
                    pt.change 'a', diff
        else if /(^dx$|^dy$|^da$)/.test what
            old = @_mot[what] if _emit
            @_mot[what] = to
        else if /(^ddx$|^ddy$|^dda$)/.test what
            old = @_acc[what] if _emit
            @_acc[what] = to
        else if /^top$/.test what
            old = @get 'top', false if _emit
            if @_bnd.shape is 'polygon'
                _top = @_bnd.points[0]
                _top = pt for pt in @_bnd.points when pt._y > _top._y
                @_pos.y = to - _top._y
            else if @_bnd.shape is 'circle'
                @_pos.y = to - @get 'radius'
        else if /^bottom$/.test what
            old = @get 'bottom', false if _emit
            if @_bnd.shape is 'polygon'
                _bottom = @_bnd.points[0]
                _bottom = pt for pt in @_bnd.points when pt._y < _bottom._y
                @_pos.y = to - _bottom._y
            else if @_bnd.shape is 'circle'
                @_pos.y = to + @get 'radius'
        else if /^right$/.test what
            old = @get 'right', false if _emit
            if @_bnd.shape is 'polygon'
                _right = @_bnd.points[0]
                _right = pt for pt in @_bnd.points when pt._x > _right._x
                @_pos.x = to - _right._x
            else if @_bnd.shape is 'circle'
                @_pos.x = to - @get 'radius'
        else if /^left$/.test what
            old = @get 'left', false if _emit
            if @_bnd.shape is 'polygon'
                _left = @_bnd.points[0]
                _left = pt for pt in @_bnd.points when pt._x < _left._x
                @_pos.x = to - _left._x
            else if @_bnd.shape is 'circle'
                @_pos.x = to + @get 'radius'
        else if /^radius$/.test what
            old = @get 'radius', false if _emit
            if @_bnd.shape is 'circle'
                @_bnd.radius = to
            else
                throw new Error "Cannot set radius when shape isnt 'circle'"
        else if /^imageFile$/.test what
            old = @get 'imageFile', false if _emit
            if Sprite.config.imagePath.match /\/$/
                @_dis.image.src = Sprite.config.imagePath.concat to
            else
                if Sprite.config.imagePath
                    Sprite.config.imagePath += '/'
                    @_dis.image.src = Sprite.config.imagePath.concat to
                else
                    @_dis.image.src = to
        else if /^distance$/.test what
            old = @get 'distance', false if _emit
            proxy =
                x: to * Math.cos @get 'posAngle', false
                y: to * Math.sin @get 'posAngle', false
            @set '_pos', proxy, false
        else if /^speed$/.test what
            old = @get 'speed', false if _emit
            proxy =
                dx: to * Math.cos @get 'motAngle', false
                dy: to * Math.sin @get 'motAngle', false
            @set '_mot', proxy, false
        else if /^rate$/.test what
            old = @get 'rate', false if _emit
            proxy =
                ddx: to * Math.cos @get 'accAngle', false
                ddy: to * Math.sin @get 'accAngle', false
            @set '_acc', proxy, false
        else if /^posAngle$/.test what
            old = @get 'posAngle', false if _emit
            proxy =
                x: @get('distance', false) * Math.cos to
                y: @get('distance', false) * Math.sin to
            @set '_pos', proxy, false
        else if /^motAngle$/.test what
            old = @get 'motAngle', false if _emit
            proxy =
                dx: @get('speed', false) * Math.cos to
                dy: @get('speed', false) * Math.sin to
            @set '_mot', proxy, false
        else if /^accAngle$/.test what
            old = @get 'accAngle', false if _emit
            proxy =
                ddx: @get('rate', false) * Math.cos to
                ddy: @get('rate', false) * Math.sin to
            @set '_acc', proxy, false
        else if /(^_?dis|^_?pos|^_?mot|^_?acc|^config)/.test what
            #set old to what here?
            @set k, v, false for own k, v of to
        else if /(^level$|^visible$|^highlight$)/.test what
            old = @_dis[what] if _emit
            @_dis[what] = to
            if what is 'level'
                _list.sort _sortRule
        else if /^scale$/.test what
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
        else if /^ba$/.test what
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
        else if /^ba_(top|bottom|right|left)$/.test what
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
            @_bas[side] = _boundaryCallbacks[to][side]
            @_bas[side].ba = to
            @on "#{newCollision}:#{side}", @_bas[side]
        else if /^shape$/.test what #needs refining
            old = @_bnd.shape if _emit
            if @_bnd.shape is 'circle'
                if to is 'polygon'
                    @_bnd.radius = null
                    @_bnd.shape = to
            else if @_bnd.shape is 'polygon'
                if to is 'circle'
                    @_bnd.radius = @get 'radius'
                    @_bnd.shape = to
        else if /^points$/.test what
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
        if /(^x$|^y$|^a$)/.test what
            @_pos[what] += step / Greenhorn.config.frameRate
            if what is 'a' and @_bnd.shape is 'polygon'
                pt.change('a', step / Greenhorn.config.frameRate) for pt in @_bnd.points
        else if /(^dx$|^dy$|^da$)/.test what
            @_mot[what] += step / Greenhorn.config.frameRate
        else if /(^ddx$|^ddy$|^dda$)/.test what
            @_acc[what] += step / Greenhorn.config.frameRate
        else if /^level$/.test what
            @_dis.level += step / Greenhorn.config.frameRate
        else if /^distance$/.test what
            proxy =
                dx: step * Math.cos @get 'posAngle', false
                dy: step * Math.sin @get 'posAngle', false
            @change '_pos', proxy, false
        else if /^speed$/.test what
            proxy =
                ddx: step * Math.cos @get 'motAngle', false
                ddy: step * Math.sin @get 'motAngle', false
            @change '_mot', proxy, false
        else if /^rate$/.test what
            proxy =
                dddx: step * Math.cos @get 'accAngle', false
                dddy: step * Math.sin @get 'accAngle', false
            @change '_acc', proxy, false
        else if /^posAngle$/.test what
            proxy =
                x: @get('distance', false) * Math.cos step + @get 'posAngle', false
                y: @get('distance', false) * Math.sin step + @get 'posAngle', false
            @set '_pos', proxy, false
        else if /^motAngle$/.test what
            proxy =
                dx: @get('speed', false) * Math.cos step + @get 'motAngle', false
                dy: @get('speed', false) * Math.sin step + @get 'motAngle', false
            @set '_mot', proxy, false
        else if /^accAngle$/.test what
            proxy =
                ddx: @get('rate', false) * Math.cos step + @get 'accAngle', false
                ddy: @get('rate', false) * Math.sin step + @get 'accAngle', false
            @set '_acc', proxy, false
        else if /(^_?dis|^_?pos|^_?mot|^_?acc)/.test what
            @change k.slice(1), v, false for own k, v of step
        else
            @[what] += step / Greenhorn.config.frameRate
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
                                unless innerLine.contains outerLine.p1
                                    unless innerLine.contains outerLine.p2
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
                                                        unless myLine.contains otherLine.p1
                                                            unless myLine.contains otherLine.p2
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
                                                        unless otherLine.contains myLine.p1
                                                            unless otherLine.contains myLine.p2
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
    _update: ->
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
            if /^mouse:hover$/.test event
                if @collidesWith 'mouse'
                    @emit event
            #fire 'mouse:noHover' event
            if /^mouse:!hover$/.test event
                unless @collidesWith 'mouse'
                    @emit event
            #fire 'isDown' event
            if /^isDown:(\w+|\d)/.test event
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
            else if /^isUp:(\w+|\d)/.test event
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
            else if /^collisionWith:\w+/.test event
                if @collidesWith listeners.other
                    @emit event, listeners.other
            #fire 'noCollisionWith:other' events
            else if /^!collisionWith:\w+/.test event
                unless @collidesWith listeners.other
                    @emit event, listeners.other
            #fire 'distanceTo:other-cmp-value' events
            else if /^distanceTo:\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/.test event
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
            else if /^angleTo:\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/.test event
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
            else if /^\w+-(gt|lt|eq|ge|le|ne)-\d*\.?\d*$/.test event
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
            else if /^\w+-(eq|ne)-\w+/.test event
                tokens = event.split '-'
                if tokens[2].match /(^true$|^false$)/
                    `tokens[2] = (0, eval)(tokens[2])`
                switch tokens[1]
                    when 'eq'
                        if @get(tokens[0], false) is tokens[2]
                            @emit event
                    when 'ne'
                        if @get(tokens[0], false) isnt tokens[2]
                            @emit event
        return this

    #debugging
    toString: ->
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
