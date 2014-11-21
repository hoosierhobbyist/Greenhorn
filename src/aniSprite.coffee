###
aniSprite.coffee

The Greenhorn Gaming Engine animated Sprite class
###

class AniCycle
    #constructor
    constructor: (data) ->
        #throw errors if proper data isn't supplied
        throw new Error "cycle name must be supplied" unless data.name?
        throw new Error "start position must be supplied" unless data.start?
        throw new Error "number of frames must be supplied" unless data.numFrames?
        
        #extract data
        @name = data.name
        @start = data.start
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
        @_dis.timer = new Timer(off)
        
        #push provided cycles onto the array
        @_dis.cycles.push(new AniCycle(value)) for key, value of config when key.indexOf("cycle") is 0
        
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
    
    #update routines
    _draw: ->
        #add later
#end class AniSprite