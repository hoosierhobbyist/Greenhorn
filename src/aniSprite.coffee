###
aniSprite.coffee

The Greenhorn Gaming Engine animated Sprite class
###

class AniCycle
    #constructor
    constructor: (data) ->
        #throw errors if proper data isn't supplied
        throw new Error "name must be supplied" unless data.name?
        throw new Error "startRow must be supplied" unless data.startRow?
        throw new Error "numFrames must be supplied" unless data.numFrames?
        
        #extract data
        @name = data.name
        @startRow = data.startRow
        @numFrames = data.numFrames
        @frame = 1

class @AniSprite extends @Sprite
    #constructor
    constructor: (config = {}) ->
        #add environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.ANISPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #create new attributes
        @_dis.cycles = new Array()
        @_dis.timer = new Timer()
        
        #push provided cycles onto the array
        for own key, value of config when key.indexOf("cycle") is 0
            key.name ?= key.slice 5
            @_dis.cycles.push(new AniCycle(value)) 
        
        #call Sprite constructor
        super(config)
        
        #return this
        this
    
    #getter
    get: (what) ->
        #add later
    
    #setter
    set: (what, to) ->
        #add later
    
    #changer
    change: (what, step) ->
        #add later
    
    #animation control
    play: ->
        @_dis.timer.start()
    pause: ->
        @_dis.timer.pause()
    
    #update routines
    _draw: ->
        #save current context
        @_dis.context.save()
        
        #translate and rotate
        @_dis.translate @_pos.x, -@_pos.y
        @_dis.rotate -@_pos.a
        
        #find current frame
        sx = (@_dis.cycles[@_dis.current].frame - 1) * @_dis.cellWidth
        sy = (@_dis.cycles[@_dis.current].startRow - 1) * @_dis.cellHeight
        
        #draw frame
        @_dis.context.drawImage @_dis.image, sx, sy, @_dis.cellWidth, @_dis.cellHeight, -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        
        #restore context
        @_dis.context.restore()
    _update: =>
        if @_dis.timer.getElapsedTime() >= Math.ceil(1000 / @_dis.frameRate)
            if @_dis.cycles[@_dis.current].frame < @_dis.cycles[@_dis.current].numFrames
                @_dis.cycle[@_dis.current].frame += 1
            else
                @_dis.cycles[@_dis.current].frame = 1
            @_dis.timer.restart()
        super()
#end class AniSprite