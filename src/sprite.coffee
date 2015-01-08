###
sprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Sprite
    #closures
    _list = []
    _canvas = document.getElementById 'gh-canvas'
    _bounds =
        top: _canvas.height / 2
        bottom: -_canvas.height / 2
        right: _canvas.width / 2
        left: -_canvas.width / 2
    _sortRule = (sp1, sp2) ->
        sp1._dis.level - sp2._dis.level
    _boundaryCallback = (boundAction, side) ->
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
                        -> @change 'dy', env.SPRING_CONSTANT * (_bounds.top - @get('top')), false
                    when 'bottom'
                        -> @change 'dy', env.SPRING_CONSTANT * (_bounds.bottom - @get('bottom')), false
                    when 'right'
                        -> @change 'dx', env.SPRING_CONSTANT * (_bounds.right - @get('right')), false
                    when 'left'
                        -> @change 'dx', env.SPRING_CONSTANT * (_bounds.left - @get('left')), false
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

        #start updating if the engine is already running
        if Greenhorn.isRunning() then @_start()

        #add to Sprite _list and sort by level
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
            value = @_pos.y + @_dis.height / 2
        else if what.match /^bottom$/
            value = @_pos.y - @_dis.height / 2
        else if what.match /^right$/
            value = @_pos.x + @_dis.width / 2
        else if what.match /^left$/
            value = @_pos.x - @_dis.width / 2
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
        else
            throw new Error "#{what} is not a get-able Sprite attribute"
        if _emit then @emit "get:#{what}"
        return value

    #setter
    set: (what, to, _emit = true) ->
        if what.match /(^x$|^y$|^a$)/
            @_pos[what] = to
        else if what.match /(^dx$|^dy$|^da$)/
            @_mot[what] = to
        else if what.match /(^ddx$|^ddy$|^dda$)/
            @_acc[what] = to
        else if what.match /^top$/
            @_pos.y = to - @_dis.height / 2
        else if what.match /^bottom$/
            @_pos.y = to + @_dis.height / 2
        else if what.match /^right$/
            @_pos.x = to - @_dis.width / 2
        else if what.match /^left$/
            @_pos.x = to + @_dis.width / 2
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
                x: to * Math.cos @get('posAngle')
                y: to * Math.sin @get('posAngle')
            @set '_pos', proxy, false
        else if what.match /^speed$/
            proxy =
                dx: to * Math.cos @get('motAngle')
                dy: to * Math.sin @get('motAngle')
            @set '_mot', proxy, false
        else if what.match /^rate$/
            proxy =
                ddx: to * Math.cos @get('accAngle')
                ddy: to * Math.sin @get('accAngle')
            @set '_acc', proxy, false
        else if what.match /^posAngle$/
            proxy =
                x: @get('distance') * Math.cos to
                y: @get('distance') * Math.sin to
            @set '_pos', proxy, false
        else if what.match /^motAngle$/
            proxy =
                dx: @get('speed') * Math.cos to
                dy: @get('speed') * Math.sin to
            @set '_mot', proxy, false
        else if what.match /^accAngle$/
            proxy =
                ddx: @get('rate') * Math.cos to
                ddy: @get('rate') * Math.sin to
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
        else
            throw new Error "#{what} is not a set-able Sprite attribute"
        if _emit then @emit "set:#{what}", to
        return this

    #changer
    change: (what, step, _emit = true) ->
        if what.match /(^x$|^y$|^a$)/
            @_pos[what] += step / env.FRAME_RATE
        else if what.match /(^dx$|^dy$|^da$)/
            @_mot[what] += step / env.FRAME_RATE
        else if what.match /(^ddx$|^ddy$|^dda$)/
            @_acc[what] += step / env.FRAME_RATE
        else if what.match /(^level$|^width$|^height$)/
            @_dis[what] += step / env.FRAME_RATE
        else if what.match /^distance$/
            proxy =
                dx: step * Math.cos @get('posAngle')
                dy: step * Math.sin @get('posAngle')
            @change '_pos', proxy, false
        else if what.match /^speed$/
            proxy =
                ddx: step * Math.cos @get('motAngle')
                ddy: step * Math.sin @get('motAngle')
            @change '_mot', proxy, false
        else if what.match /^rate$/
            proxy =
                dddx: step * Math.cos @get('accAngle')
                dddy: step * Math.sin @get('accAngle')
            @change '_acc', proxy, false
        else if what.match /^posAngle$/
            proxy =
                dx: @get('distance') * Math.cos step
                dy: @get('distance') * Math.sin step
            @change '_pos', proxy, false
        else if what.match /^motAngle$/
            proxy =
                ddx: @get('speed') * Math.cos step
                ddy: @get('speed') * Math.sin step
            @change '_mot', proxy, false
        else if what.match /^accAngle$/
            proxy =
                dddx: @get('rate') * Math.cos step
                dddy: @get('rate') * Math.sin step
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
            collision = false
            if @_dis.visible
                if @get('left', false) < Greenhorn.getMouseX() < @get('right', false) and
                @get('bottom', false) < Greenhorn.getMouseY() < @get('top', false)
                    collision = true
        else
            collision = true
            if @_dis.visible and
            other._dis.visible and
            @_dis.level == other._dis.level
                if @get('bottom', false) > other.get('top', false) or
                @get('top', false) < other.get('bottom', false) or
                @get('right', false) < other.get('left', false) or
                @get('left', false) > other.get('right', false)
                    collision = false
            else collision = false
        collision
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
        Math.atan2 @_pos.y - otherY, @_pos.x - otherX

    #update routines
    _draw: ->
        if @_dis.visible
            #fire draw event
            @emit 'draw'
            
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
                        if @get(tokens[0]) > tokens[2]
                            @emit event
                    when 'lt'
                        if @get(tokens[0]) < tokens[2]
                            @emit event
                    when 'eq'
                        if @get(tokens[0]) == tokens[2]
                            @emit event
                    when 'ge'
                        if @get(tokens[0]) >= tokens[2]
                            @emit event
                    when 'le'
                        if @get(tokens[0]) <= tokens[2]
                            @emit event
                    when 'ne'
                        if @get(tokens[0]) != tokens[2]
                            @emit event
            else if event.match /^\w+-(eq|ne)-\w+/
                tokens = event.split '-'
                if tokens[2].match /(^true$|^false$)/
                    tokens[2] = eval tokens[2]
                switch tokens[1]
                    when 'eq'
                        if @get(tokens[0]) is tokens[2]
                            @emit event
                    when 'ne'
                        if @get(tokens[0]) isnt tokens[2]
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
    log: ->
        console.log @report()

#mixin EventEmitter
_mixin Sprite::, EventEmitter::

#add to namespace object
gh.Sprite = Sprite
