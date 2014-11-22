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
        for own key, value of env.ANISPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #create new attributes
        @_dis.cycles = new Array()
        @_dis.timer = new Timer()
        
        #push provided cycles onto the array
        i = 0
        for own key, value of config when key.indexOf("cycle") is 0
            key.name ?= key.slice 5
            key.row ?= i += 1
            key.numFrames ?= config.sheetWidth / config.cellWidth
            @_dis.cycles.push(new AniCycle(value))
        
        #call Sprite constructor
        super(config)
        @_dis.current ?= @_dis.cycles[0]
        
        #return this
        this
    
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
        switch what
            when "sheetWidth", "sheetHeight", "cellWidth", "cellHeight", "frameRate"
                @_dis[what] = to
            when "current"
                @_dis.current.frame = 1
                for cycle in @_dis.cycles when cycle.name is to
                    @_dis.current = cycle
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
        @_dis.translate @_pos.x, -@_pos.y
        @_dis.rotate -@_pos.a
        
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
