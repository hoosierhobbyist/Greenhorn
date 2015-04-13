###
textSprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class TextSprite extends Sprite
    #class level object
    @defaults:
        level: -1
        text: "*-TEXTSPRITE-*"
        fontSize: 12
        fontAlpha: 1.0
        fontColor: "white"
        fontAlign: "left"
        fontName: "sans-serif"
        borderSize: 5
        borderAlpha: 1.0
        borderVisible: yes
        borderColor: "white"
        outlineSize: 1
        outlineAlpha: 1.0
        outlineVisible: no
        outlineColor: "grey"
        marginsTop: 5
        marginsBottom: 5
        marginsRight: 5
        marginsLeft: 5
        backgroundAlpha: 1.0
        backgroundVisible: yes
        backgroundColor: "black"

    constructor: (config = {}) ->
        #add missing keys to config
        for own key, value of TextSprite.defaults
            config[key] ?= value

        #create primary objects
        @_text = []
        @_font = {}
        @_border = {}
        @_outline = {}
        @_margins = {}
        @_background = {}

        #call Sprite constructor
        super(config)

    #getter
    get: (what, _emit = true) ->
        if what.match /^text$/
            value = @_text.join '\n'
        else if what.match /^font\w+/
            value = @_font[what.slice(4).toLowerCase()]
        else if what.match /^border\w+/
            value = @_border[what.slice(6).toLowerCase()]
        else if what.match /^outline\w+/
            value = @_outline[what.slice(7).toLowerCase()]
        else if what.match /^margins\w+/
            value = @_margins[what.slice(7).toLowerCase()]
        else if what.match /^background\w+/
            value = @_background[what.slice(10).toLowerCase()]
        else
            value = super what, false
        if _emit then @emit "get:#{what}"
        return value

    #setter
    set: (what, to, _emit = true) ->
        if what.match /^text$/
            @_text = to.split '\n'
        else if what.match /^font\w+/
            @_font[what.slice(4).toLowerCase()] = to
        else if what.match /^border\w+/
            @_border[what.slice(6).toLowerCase()] = to
        else if what.match /^outline\w+/
            @_outline[what.slice(7).toLowerCase()] = to
        else if what.match /^margins\w+/
            @_margins[what.slice(7).toLowerCase()] = to
        else if what.match /^background\w+/
            @_background[what.slice(10).toLowerCase()] = to
        else if what.match /(^font$|^border$|^outline$|^margins$|^background$)/
            @set what.concat(k), v, false for own k, v of to
        else
            super what, to, _emit
            _emit = false
        if _emit then @emit "set:#{what}", to
        return this

    change: (what, step, _emit = true) ->
        if what.match /^text$/
            @_text = (@_text.join('\n').concat(step)).split('\n')
        else if what.match /^font\w+/
            @_font[what.slice(4).toLowerCase()] += step / Greenhorn.config.frameRate
        else if what.match /^border\w+/
            @_border[what.slice(6).toLowerCase()] += step / Greenhorn.config.frameRate
        else if what.match /^outline\w+/
            @_outline[what.slice(7).toLowerCase()] += step / Greenhorn.config.frameRate
        else if what.match /^margins\w+/
            @_margins[what.slice(7).toLowerCase()] += step / Greenhorn.config.frameRate
        else if what.match /^background\w+/
            @_background[what.slice(10).toLowerCase()] += step / Greenhorn.config.frameRate
        else if what.match /(^font$|^border$|^outline$|^margins$|^background$)/i
            @change what.concat(k), v, false for own k, v of to
        else
            super what, step, _emit
            _emit = false
        if _emit then @emit "change:#{what}", step
        return this

    #internal control
    _draw: ->
        if @_dis.visible
            #fire draw event
            @emit 'draw'

            #save current context
            @_dis.context.save()

            #translate and rotate
            @_dis.context.translate @_pos.x, -@_pos.y
            @_dis.context.rotate -@_pos.a

            #draw background
            if @_background.visible
                @_dis.context.fillStyle = @_background.color
                @_dis.context.globalAlpha = @_background.alpha
                @_dis.context.fillRect(
                    -@_dis.width / 2, #left
                    -@_dis.height / 2, #top
                    @_dis.width, #width
                    @_dis.height) #height

            #draw borders
            if @_border.visible
                @_dis.context.strokeStyle = @_border.color
                @_dis.context.lineWidth = @_border.size
                @_dis.context.globalAlpha = @_border.alpha
                @_dis.context.strokeRect(
                    -@_dis.width / 2, #left
                    -@_dis.height / 2, #top
                    @_dis.width, #width
                    @_dis.height) #height

            #calculate text yOffset
            yOffset = (@_text.length - 1) * @_font.size * .75

            #calculate text xOffset
            if @_font.align.toLowerCase() is 'center'
                xOffset = 0
            else if @_font.align.toLowerCase() is 'left'
                xOffset = -@_dis.width / 2 + @_margins.left
                if @_border.visible
                    xOffset += @_border.size
            else if @_font.align.toLowerCase() is 'right'
                xOffset = @_dis.width / 2 - @_margins.right
                if @_border.visible
                    xOffset -= @_border.size

            #initialize context for text
            @_dis.context.textBaseline = 'middle'
            @_dis.context.fillStyle = @_font.color
            @_dis.context.globalAlpha = @_font.alpha
            @_dis.context.textAlign = @_font.align
            @_dis.context.font = "#{@_font.size}px #{@_font.name}"

            #draw text on canvas
            for line, i in @_text
                @_dis.context.fillText(
                    line,
                    xOffset,
                    @_font.size * 1.5 * i - yOffset)

            #draw text outline if visible
            if @_outline.visible
                @_dis.context.lineWidth = @_outline.size
                @_dis.context.strokeStyle = @_outline.color
                @_dis.context.globalAlpha = @_outline.alpha
                for line, i in @_text
                    @_dis.context.strokeText(
                        line,
                        xOffset,
                        @_font.size * 1.5 * i - yOffset)

            #restore old context
            @_dis.context.restore()
    _update: ->
        #call Sprite update
        super()

        #calculate new size
        @_dis.width = 0
        @_dis.height = @_font.size * 1.5 * @_text.length

        #find maximum line width
        @_dis.context.save()
        @_dis.context.font = "#{@_font.size}px #{@_font.name}"
        for line in @_text
            len = @_dis.context.measureText(line).width
            @_dis.width = len if @_dis.width < len
        @_dis.context.restore()

        #adjust for margins and border
        @_dis.width += @_margins.left + @_margins.right
        @_dis.height += @_margins.top + @_margins.bottom
        if @_border.visible
            @_dis.width += 2 * @_border.size
            @_dis.height += 2 * @_border.size

    #debugging
    toString: ->
        """
        #{super()}
        font:
            size: #{@_font.size}
            alpha: #{@_font.alpha}
            color: #{@_font.color}
            align: #{@_font.align}
            name: #{@_font.name}
        border:
            size: #{@_border.size}
            alpha: #{@_border.alpha}
            visible: #{@_border.visible}
            color: #{@_border.color}
        outline:
            size: #{@_outline.size}
            alpha: #{@_outline.alpha}
            visible: #{@_outline.visible}
            color: #{@_outline.color}
        margins:
            top: #{@_margins.top}
            bottom: #{@_margins.bottom}
            right: #{@_margins.right}
            left: #{@_margins.left}
        background:
            alpha: #{@_background.alpha}
            visible: #{@_background.visible}
            color: #{@_background.color}
        """

#add to namespace object
gh.TextSprite = TextSprite
