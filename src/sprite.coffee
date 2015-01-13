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
    _boundaryCallback = (boundAction, side) ->
        #cache boundaries
        _bounds ?=
            top: _canvas.height / 2
            bottom: -_canvas.height / 2
            right: _canvas.width / 2
            left: -_canvas.width / 2
        
        #return appropriate callback
        switch boundAction
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
        magnitudes = {}
        angles = {}
        for own key, value of config
            if key.match /(^distance$|^speed$|^rate$)/i
                delete config[key]
                magnitudes[key] = value
            else if key.match /(^posAngle$|^motAngle$|^accAngle$)/
                delete config[key]
                angles[key] = value
            else if key.match /^ba_all$/
                delete config[key]
                config.ba_top = value
                config.ba_bottom = value
                config.ba_right = value
                config.ba_left = value
            else if key.match /^on\w+/
                delete config[key]
                if typeof value is 'function'
                    @on key.slice(2), value
                else if value.length?
                    @on key.slice(2), value[0], value[1]

        #used to track asynchronous _update
        @_updateID = null

        #create primary objects
        @_pos = {}
        @_mot = {}
        @_acc = {}
        @_dis = {}
        @_bas = {}

        #create secondary objects
        @_dis.image = new Image()
        @_dis.context = _canvas.getContext '2d'

        #set this sprite's configuration
        #"virtually" calls child's set method in derived classes
        @set 'config', config, false
        @set 'config', magnitudes, false
        @set 'config', angles, false
        
        #create default boundary if none was provided
        unless @_bnd?
            @_bnd = []
            @_bnd.push new Point -@_dis.width / 2, @_dis.height / 2, @_pos.x, @_pos.y
            @_bnd.push new Point @_dis.width / 2, @_dis.height / 2, @_pos.x, @_pos.y
            @_bnd.push new Point @_dis.width / 2, -@_dis.height / 2, @_pos.x, @_pos.y
            @_bnd.push new Point -@_dis.width / 2, -@_dis.height / 2, @_pos.x, @_pos.y

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
            value = pt.y for pt in @_bnd
            value = Math.max value...
        else if what.match /^bottom$/
            value = pt.y for pt in @_bnd
            value = Math.min value...
        else if what.match /^right$/
            value = pt.x for pt in @_bnd
            value = Math.max value...
        else if what.match /^left$/
            value = pt.x for pt in @_bnd
            value = Math.min value...
        else if what.match /^radius$/
            value = pt.get('dist') for pt in @_bnd
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
        else if what.match /(^level$|^width$|^height$|^visible$)/
            value = @_dis[what]
        else if what.match /^ba_(top|bottom|right|left)/
            value = @_bas[what.split('_')[1]].ba
        else if what.match /^bound/
            value = @_bnd
        else
            throw new Error "#{what} is not a get-able Sprite attribute"
        if _emit then @emit "get:#{what}"
        return value

    #setter
    set: (what, to, _emit = true) ->
        if what.match /^x$/
            @_pos.x = to
            for pt in @_bnd
                pt.set 'org_x', to
        else if what.match /^y$/
            @_pos.y = to
            for pt in @_bnd
                pt.set 'org_y', to
        else if what.match /^a$/
            diff = to - @_pos.a
            @_pos.a = to
            for pt in @_bnd
                pt.change 'a', diff
        else if what.match /(^dx$|^dy$|^da$)/
            @_mot[what] = to
        else if what.match /(^ddx$|^ddy$|^dda$)/
            @_acc[what] = to
        else if what.match /^top$/
            _top = @_bnd[0]
            for pt in @_bnd when pt.y > _top.y
                _top = pt
            @set 'y', to - Math.abs(_top.get('y') - _top.get('org_y')), false
        else if what.match /^bottom$/
            _bottom = @_bnd[0]
            for pt in @_bnd when pt.y < _bottom.y
                _bottom = pt
            @set 'y', to + Math.abs(_bottom.get('y') - _bottom.get('org_y')), false
        else if what.match /^right$/
            _right = @_bnd[0]
            for pt in @_bnd when pt.x > _right.x
                _right = pt
            @set 'x', to - Math.abs(_right.get('x') - _right.get('org_x')), false
        else if what.match /^left$/
            _left = @_bnd[0]
            for pt in @_bnd when pt.x < _left.x
                _left = pt
            @set 'x', to + Math.abs(_left.get('x') - _left.get('org_x')), false
        else if what.match /^imageFile$/
            if env.IMAGE_PATH.match /\/$/
                @_dis.image.src = env.IMAGE_PATH.concat to
            else
                if env.IMAGE_PATH
                    env.IMAGE_PATH += '/'
                    @_dis.image.src = env.IMAGE_PATH.concat to
                else
                    @_dis.image.src = to
        else if what.match /^distance$/
            proxy =
                x: to * Math.cos @get 'posAngle', false
                y: to * Math.sin @get 'posAngle', false
            @set '_pos', proxy, false
        else if what.match /^speed$/
            proxy =
                dx: to * Math.cos @get 'motAngle', false
                dy: to * Math.sin @get 'motAngle', false
            @set '_mot', proxy, false
        else if what.match /^rate$/
            proxy =
                ddx: to * Math.cos @get 'accAngle', false
                ddy: to * Math.sin @get 'accAngle', false
            @set '_acc', proxy, false
        else if what.match /^posAngle$/
            proxy =
                x: @get('distance', false) * Math.cos to
                y: @get('distance', false) * Math.sin to
            @set '_pos', proxy, false
        else if what.match /^motAngle$/
            proxy =
                dx: @get('speed', false) * Math.cos to
                dy: @get('speed', false) * Math.sin to
            @set '_mot', proxy, false
        else if what.match /^accAngle$/
            proxy =
                ddx: @get('rate', false) * Math.cos to
                ddy: @get('rate', false) * Math.sin to
            @set '_acc', proxy, false
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc|^config)/
            @set k, v, false for own k, v of to
        else if what.match /(^level$|^width$|^height$|^visible$)/
            @_dis[what] = to
            _list.sort _sortRule if what is 'level'
        else if what.match /^ba_(all|top|bottom|right|left)$/
            side = what.split('_')[1]
            oldCollision =
                if @_bas[side]?
                    if @_bas[side].ba.match /(DIE|WRAP)/
                        'off'
                    else
                        'hit'
                else ''
            newCollision = 
                if to.match /(DIE|WRAP)/
                    'off'
                else if to.match /(STOP|SPRING|BOUNCE)/
                    'hit'
                else
                    throw new Error "#{to} is not a valid boundary action"
            unless side is 'all'
                if @_bas[side]?
                    @remove "#{oldCollision}:#{side}", @_bas[side]
                @_bas[side] = _boundaryCallback to, side
                @_bas[side].ba = to
                @on "#{newCollision}:#{side}", @_bas[side]
            else
                proxy =
                    ba_top: to
                    ba_bottom: to
                    ba_right: to
                    ba_left: to
                @set 'config', proxy, false
        else if what.match /^bound/
            @_bnd = []
            for pt in to
                @_bnd.push new Point pt.x, pt.y, @_pos.x, @_pos.y
        else
            throw new Error "#{what} is not a set-able Sprite attribute"
        if _emit then @emit "set:#{what}", to
        return this

    #changer
    change: (what, step, _emit = true) ->
        if what.match /^x$/
            @_pos.x += step / env.FRAME_RATE
            for pt in @_bnd
                pt.change 'org_x', step / env.FRAME_RATE
        else if what.match /^y$/
            @_pos.y += step / env.FRAME_RATE
            for pt in @_bnd
                pt.change 'org_y', step / env.FRAME_RATE
        else if what.match /^a$/
            @_pos.a += step / env.FRAME_RATE
            for pt in @_bnd
                pt.change 'a', step / env.FRAME_RATE
        else if what.match /(^dx$|^dy$|^da$)/
            @_mot[what] += step / env.FRAME_RATE
        else if what.match /(^ddx$|^ddy$|^dda$)/
            @_acc[what] += step / env.FRAME_RATE
        else if what.match /(^level$|^width$|^height$)/
            @_dis[what] += step / env.FRAME_RATE
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
                dx: @get('distance', false) * Math.cos step
                dy: @get('distance', false) * Math.sin step
            @change '_pos', proxy, false
        else if what.match /^motAngle$/
            proxy =
                ddx: @get('speed', false) * Math.cos step
                ddy: @get('speed', false) * Math.sin step
            @change '_mot', proxy, false
        else if what.match /^accAngle$/
            proxy =
                dddx: @get('rate', false) * Math.cos step
                dddy: @get('rate', false) * Math.sin step
            @change '_acc', proxy, false
        else if what.match /(^_?dis|^_?pos|^_?mot|^_?acc)/
            @change k.slice(1), v, false for own k, v of step
        else
            throw new Error "#{what} is not a change-able Sprite attribute"
        if _emit then @emit "change:#{what}", step
        return this

    #collision routines
    collidesWith: (other) ->
        if other is 'mouse'
            if @_dis.visible
                if @distanceTo('mouse') <= @get('radius', false)
                    #declare Line arrays
                    myLines = []
                    otherLines = []
                    mousePos = new Point Greenhorn.getMouseX(), Greenhorn.getMouseY(), 0, 0
                    
                    #create Lines to check for collisions
                    for pt, i in @_bnd
                        otherLines.push new Line pt, mousePos
                        if i is @_bnd.length - 1
                            myLines.push new Line pt, @_bnd[0]
                        else
                            myLines.push new Line pt, @_bnd[i+1]
                    
                    #check for collisions
                    for myLine in myLines
                        for otherLine in otherLines
                            unless myLine.p1 is otherLine.p1 or myLine.p1 is otherLine.p2
                                unless myLine.p2 is otherLine.p1 or myLine.p2 is otherLine.p2
                                    if myLine.collidesWith otherLine
                                        return false
                    return true
            return false
        else
            if @_dis.visible
                if other._dis.visible
                    if @_dis.level == other._dis.level
                        if @distanceTo(other) <= @get('radius', false) + other.get('radius', false)
                            #declare Line arrays
                            myLines = []
                            otherLines = []
                            
                            #create Lines representing boundaries
                            for pt, i in @_bnd
                                if i is @_bnd.length - 1
                                    myLines.push new Line pt, @_bnd[0]
                                else
                                    myLines.push new Line pt, @_bnd[i+1]
                            for pt, i in other._bnd
                                if i is other._bnd.length - 1
                                    otherLines.push new Line pt, other._bnd[0]
                                else
                                    otherLines.push new Line pt, other._bnd[i+1]
                            
                            #check for collisions
                            for myLine in myLines
                                for otherLine in otherLines
                                    if myLine.collidesWith otherLine
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
        Math.atan2(@_pos.y - otherY, @_pos.x - otherX) + Math.PI

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

            #draw image
            @_dis.context.drawImage(
                @_dis.image, #imageFile
                -@_dis.width / 2, #left
                -@_dis.height / 2, #top
                @_dis.width, #width
                @_dis.height) #height
            
            #restore context
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
            if event.match /^mouse:noHover$/
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
            else if event.match /^noCollisionWith:\w+/
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
                    tokens[2] = eval tokens[2]
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
            level: #{Math.round @_dis.level}
            width: #{Math.round @_dis.width}
            height: #{Math.round @_dis.height}
            visible: #{@_dis.visible}
        bound actions:
            top: #{@_bas.top.ba}
            bottom: #{@_bas.bottom.ba}
            right: #{@_bas.right.ba}
            left: #{@_bas.left.ba}
        """
    highlight: ->
        @on 'draw:after', ->
            @_dis.context.save()
            @_dis.context.lineWidth = 3
            @_dis.context.strokeStyle = 'white'
            @_dis.context.beginPath()
            @_dis.context.moveTo(@_bnd[0].x, @_bnd[0].y)
            for pt, i in @_bnd when i isnt 0
                @dis.context.lineTo(pt.x, pt.y)
            @_dis.context.closePath()
            @_dis.context.stroke()
            @_dis.context.restore()

#add to namespace object
gh.Sprite = Sprite
