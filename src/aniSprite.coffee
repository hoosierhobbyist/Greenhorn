###
aniSprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#closed over helper class
class AniCycle
    constructor: (data) ->
        @frame = data.start
        @index = data.index
        @start = data.start
        @stop = data.stop
        @name = data.name

class AniSprite extends Sprite
    constructor: (config = {}) ->
        #add missing keys to config
        for own key, value of env.ANISPRITE_DEFAULT_CONFIG
            config[key] ?= value
        
        #filter out initial cycle if one is provided
        initialCycle = null
        for own key, value of config
            if key.match /(^current$|^animation$)/i
                delete config[key]
                initialCycle = value

        #create primary object
        @_ani = {}

        #create secondary objects
        @_ani.cycles = []
        @_ani.timer = new Timer(on)

        #call the Sprite constructor
        super(config)
        
        #set initial cycle if one was provided
        @set 'current', initialCycle if initialCycle?

    #getter
    get: (what) ->
        if what.match /(^current$|^animation$)/i
            @_ani.current.name
        else if what.match /(^cellWidth$|^cellHeight$|^frameRate$|^orientation$)/
            @_ani[what]
        else
            super what

    #setter
    set: (what, to) ->
        if what.match /(^current$|^animation$)/i
            if to isnt @_ani.current.name
                @_ani.current.frame = @_ani.current.start
                for cycle in @_ani.cycles when cycle.name is to
                    @_ani.current = cycle
        else if what.match /(^cellWidth$|^cellHeight$|^frameRate$|^orientation$)/
            @_ani[what] = to
        else if what.match /^cycle/i
            to.index ?= env.ANICYCLE_DEFAULT_CONFIG.index
            to.start ?= env.ANICYCLE_DEFAULT_CONFIG.start
            to.stop ?= to.start + env.ANICYCLE_DEFAULT_CONFIG.numFrames - 1
            to.name ?= what.slice(5) ? env.ANICYCLE_DEFAULT_CONFIG.name

            @_ani.cycles.push(new AniCycle(to))
            @_ani.current ?= @_ani.cycles[0]
        else
            super what, to
        this

    #changer
    change: (what, step) ->
        if what.match /^frameRate$/i
            @_ani.frameRate += step
        else
            super what, step

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
            if @_ani.orientation.toLowerCase() is 'horizontal'
                sliceX = @_ani.current.frame - 1
                sliceY = @_ani.current.index - 1
            else if @_ani.orientation.toLowerCase() is 'vertical'
                sliceX = @_ani.current.index - 1
                sliceY = @_ani.current.frame - 1

            #draw frame
            @_dis.context.drawImage(
                @_dis.image, #spritesheet
                @_ani.cellWidth * sliceX, #sx
                @_ani.cellHeight * sliceY, #sy
                @_ani.cellWidth, #swidth
                @_ani.cellHeight, #sheight
                -@_dis.width / 2, #left
                -@_dis.height / 2, #top
                @_dis.width, #width
                @_dis.height) #height

            #restore context
            @_dis.context.restore()
    _update: ->
        if @_dis.visible
            #determine if it's time to change frames
            if @_ani.timer.getElapsedTime() >= (1000 / @_ani.frameRate)
                #determine next frame in animation loop
                if @_ani.current.frame < @_ani.current.stop
                    @_ani.current.frame += 1
                else
                    @_ani.current.frame = @_ani.current.start

                #restart the timer
                @_ani.timer.restart()

            #call Sprite _update
            super()

#add to namespace object
gh.AniSprite = AniSprite