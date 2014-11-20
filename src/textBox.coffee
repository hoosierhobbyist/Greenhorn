###
textBox.coffee

The Greenhorn Gaming TextBox class
###

#simple textbox
class @TextBox extends @Sprite
    #constructor
    constructor: (config = {}) ->
        #add the environment defaults to config,
        #if the user has chosen to omit them
        for own key, value of env.TEXTBOX_DEFAULT_CONFIG
            config[key] ?= value
        
        #primary objects
        @_text = []
        @_background = {}
        @_border = {}
        @_font = {}
        @_margins = {}
        
        #call Sprite constructor
        super(config)
    
    #generic getter
    get: (what) ->
        switch what
            when "text"
                @_text.join '\n'
            when "align"
                @_dis.context.textAlign
            when "background", "border", "font", "margins"
                @["_".concat what]
            when what.indexOf("background") is 0
                @_background[what.slice(10).toLowerCase()]
            when what.indexOf("border") is 0
                @_border[what.slice(6).toLowerCase()]
            when what.indexOf("font") is 0
                @_font[what.slice(4).toLowerCase()]
            when what.indexOf("margins") is 0
                @_margins[what.slice(7).toLowerCase()]
            else
                super what
    
    #generic setter
    set: (what, to) ->
        if what is "text"
            @_text = to.split "\n"
        else if what is "align"
            @_dis.context.textAlign = to
        else if what is "background" or what is "border" or what is "font" or what is "margins"
            @["_".concat what][k] = v for k, v of to
        else if what.indexOf("background") is 0
            @_background[what.slice(10).toLowerCase()] = to
        else if what.indexOf("border") is 0
            @_border[what.slice(6).toLowerCase()] = to
        else if what.indexOf("font") is 0
            @_font[what.slice(4).toLowerCase()] = to
        else if what.indexOf("margins") is 0
            @_margins[what.slice(7).toLowerCase()] = to
        else
            super what, to
        
        if @_dis.width? and @_dis.height? and @_font.size? and
        @_margins.left? and @_margins.right? and @_margins.bottom? and
        @_margins.top? and @_border.visible? and @_border.size?
            @_fitText()
        this
    
    #style control
    showBackground: ->
        @_background.visible = yes
        return
    hideBackground: ->
        @_background.visible = no
        return
    showBorder: ->
        @_border.visible = yes
        @_fitText()
        return
    hideBorder: ->
        @_border.visible = no
        @_fitText()
        return
    
    #internal control
    _fitText: ->
        #calculate new size
        @_dis.width = 0
        @_dis.height = (@_font.size * @_text.length) + (@_font.size * (@_text.length - 1))
        for line in @_text
            len = @_dis.context.measureText(line).width
            @_dis.width = len if @_dis.width < len
        
        #adjust for margins and border
        @_dis.width += @_margins.left + @_margins.right
        @_dis.height += @_margins.top + @_margins.bottom
        if @_border.visible
            @_dis.width += 2 * @_border.size
            @_dis.height += 2 * @_border.size
        
        return this
    _draw: ->
        #save current context
        @_dis.context.save()
        
        #translate and rotate
        @_dis.context.translate @_pos.x, -@_pos.y
        @_dis.context.rotate -@_pos.a
        
        #draw background
        if @_background.visible
            @_dis.context.fillStyle = @_background.color
            @_dis.context.globalAlpha = @_background.alpha
            @_dis.context.fillRect -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        
        #draw borders
        if @_border.visible
            @_dis.context.strokeStyle = @_border.color
            @_dis.context.lineWidth = @_border.size
            @_dis.context.globalAlpha = @_border.alpha
            @_dis.context.strokeRect -@_dis.width / 2, -@_dis.height / 2, @_dis.width, @_dis.height
        
        #draw text
        xOffset = @_margins.left
        yOffset = @_margins.top + @_font.size
        if @_border.visible
            xOffset += @_border.size
            yOffset += @_border.size
        
        #initialize context
        @_dis.context._font = "#{@_font.size}px #{@_font.name}"
        @_dis.context.fillStyle = @_font.color
        @_dis.context.globalAlpha = @_font.alpha
        
        #draw text on canvas
        if @_text.length > 1
            for line, i in @_text
                @_dis.context.fillText line, xOffset - (@_dis.width / 2), yOffset - (@_dis.height / 2) + (@_font.size * 2 * i)
        else
            @_dis.context.fillText @_text[0], xOffset - (@_dis.width / 2), yOffset - (@_dis.height / 2)
        
        #restore old context
        @_dis.context.restore()
        return
#end class TextBox
