###
aniSprite.coffee

The Greenhorn Gaming Engine animated Sprite class
###

#private helper class
class AniCycle
    constructor: (data) ->
        @frame = data.start
        @index = data.index
        @start = data.start
        @stop = data.stop
        @name = data.name

class @AniSprite extends @Sprite
    #constructor
    constructor: (config = {}) ->
        #add environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.ANISPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #create primary object
        @_ani = {}
        
        #create secondary objects
        @_ani.cycles = []
        @_ani.timer = new Timer(true)
        
        #call the Sprite constructor
        super(config)
    
    #getter
    get: (what) ->
        switch what
            when 'cellWidth', 'cellHeight', 'frameRate'
                @_ani[what]
            when 'current', 'animation', 'cycle'
                @_ani.current.name
            else
                super what
    
    #setter
    set: (what, to) ->
        if what is 'cellWidth' or
        what is 'cellHeight' or
        what is 'frameRate'
            @_ani[what] = to
        else if what is 'current' or
            what is 'animation' or
            what is 'cycle'
                if to isnt @_ani.current.name
                    @_ani.current.frame = @_ani.current.start
                    for cycle in @_ani.cycles when cycle.name is to
                        @_ani.current = cycle
        else if what.match /^cycle/i
            i = 0
            to.index ?= i += 1
            to.start ?= 1
            to.stop ?= to.start + env.ANICYCLE_DEFAULT_CONFIG.numFrames - 1
            to.name ?= if what.slice(5) then what.slice(5) else env.ANICYCLE_DEFAULT_CONFIG.name
            @_ani.cycles.push(new AniCycle(to))
            @_ani.current ?= @_ani.cycles[0]
        else
            super what, to
        this
    
    #animation control
    play: ->
        @_ani.timer.start()
        this
    pause: ->
        @_ani.timer.pause()
        this
    stop: ->
        @_ani.timer.stop()
        @_ani.current.frame = @_ani.current.start
        this
    
    #update routines
    _draw: ->
        if @_dis.visible
            #save current context
            @_dis.context.save()
            
            #translate and rotate
            @_dis.context.translate @_pos.x, -@_pos.y
            @_dis.context.rotate -@_pos.a
            
            #determine slicing index
            if env.SPRITESHEET_ORIENTATION.toLowerCase() is 'horizontal'
                sliceX = @_ani.current.frame - 1
                sliceY = @_ani.current.index - 1
            else if env.SPRITESHEET_ORIENTATION.toLowerCase() is 'vertical'
                sliceX = @_ani.current.index - 1
                sliceY = @_ani.current.frame - 1
            
            #draw frame
            @_dis.context.drawImage( 
                @_dis.image, #spritesheet
                @_ani.cellWidth * sliceX, #sx
                @_ani.cellHeight * sliceY, #sy
                @_ani.cellWidth, #swidth
                @_ani.cellHeight, #sheight
                -@_dis.width / 2, #x
                -@_dis.height / 2, #y
                @_dis.width, #width
                @_dis.height) #height
            
            #restore context
            @_dis.context.restore()
    _update: ->
        if @_dis.visible
            if @_ani.timer.getElapsedTime() >= (1000 / @_ani.frameRate)
                if @_ani.current.frame < @_ani.current.stop
                    @_ani.current.frame += 1
                else
                    @_ani.current.frame = @_ani.current.start
                @_ani.timer.restart()
            super()
#end class AniSprite
