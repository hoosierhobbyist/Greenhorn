###
textSprite.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class TextSprite extends Sprite
    constructor: (config = {}) ->
        #add missing keys to config
        for own key, value of env.TEXTBOX_DEFAULT_CONFIG
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
    get: (what) ->
        if what.match /^text$/i
            @_text.join '\n'
        else if what.match /^font\w+/i
            @_font[what.slice(4).toLowerCase()]
        else if what.match /^border\w+/i
            @_border[what.slice(6).toLowerCase()]
        else if what.match /^outline\w+/i
            @_outline[what.slice(7).toLowerCase()]
        else if what.match /^margins\w+/i
            @_margins[what.slice(7).toLowerCase()]
        else if what.match /^background\w+/i
            @_background[what.slice(10).toLowerCase()]
        else
            super what

    #setter
    set: (what, to) ->
        if what.match /^text$/i
            @_text = to.split '\n'
        else if what.match /^font\w+/i
            @_font[what.slice(4).toLowerCase()] = to
        else if what.match /^border\w+/i
            @_border[what.slice(6).toLowerCase()] = to
        else if what.match /^outline\w+/i
            @_outline[what.slice(7).toLowerCase()] = to
        else if what.match /^margins\w+/i
            @_margins[what.slice(7).toLowerCase()] = to
        else if what.match /^background\w+/i
            @_background[what.slice(10).toLowerCase()] = to
        else if what.match /(^font$|^border$|^outline$|^margins$|^background$)/i
            @set what.concat(k), v for own k, v of to
        else
            super what, to
        this

    change: (what, step) ->
        if what.match /^text$/i
            @_text = (@_text.join('\n').concat(step)).split('\n')
        else if what.match /^font\w+/i
            @_font[what.slice(4).toLowerCase()] += step
        else if what.match /^border\w+/i
            @_border[what.slice(6).toLowerCase()] += step
        else if what.match /^outline\w+/i
            @_outline[what.slice(7).toLowerCase()] += step
        else if what.match /^margins\w+/i
            @_margins[what.slice(7).toLowerCase()] += step
        else if what.match /^background\w+/i
            @_background[what.slice(10).toLowerCase()] += step
        else if what.match /(^font$|^border$|^outline$|^margins$|^background$)/i
            @change what.concat(k), v for own k, v of to
        else
            super what, step
        this

    #internal control
    _draw: ->
        if @_dis.visible

            #save current context
            @_dis.context.save()

            #translate and rotate
            @_dis.context.translate @_pos.x, -@_pos.y
            @_dis.context.rotate -@_pos.a

            #draw background
            if @_background.visible
                @_dis.context.save()
                @_dis.context.fillStyle = @_background.color
                @_dis.context.globalAlpha = @_background.alpha
                @_dis.context.fillRect(
                    -@_dis.width / 2, #left
                    -@_dis.height / 2, #top
                    @_dis.width, #width
                    @_dis.height) #height
                @_dis.context.restore()

            #draw borders
            if @_border.visible
                @_dis.context.save()
                @_dis.context.strokeStyle = @_border.color
                @_dis.context.lineWidth = @_border.size
                @_dis.context.globalAlpha = @_border.alpha
                @_dis.context.strokeRect(
                    -@_dis.width / 2, #left
                    -@_dis.height / 2, #top
                    @_dis.width, #width
                    @_dis.height) #height
                @_dis.context.restore()

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
            @_dis.context.textAlign = "#{@_font.align}"
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

        #call Sprite update
        super()

#add to namespace object
gh.TextSprite = TextSprite