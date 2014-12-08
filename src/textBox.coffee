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
        
        #create primary objects
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
            if @_font.size? and @_font.name?
                @_dis.context.font = "#{@_font.size}px #{@_font.name}"
        else if what.indexOf("margins") is 0
            @_margins[what.slice(7).toLowerCase()] = to
        else
            super what, to
        this
    
    #style control
    showBackground: ->
        @_background.visible = yes
    hideBackground: ->
        @_background.visible = no
    showBorder: ->
        @_border.visible = yes
    hideBorder: ->
        @_border.visible = no
    
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
                @_dis.context.fillStyle = @_background.color
                @_dis.context.globalAlpha = @_background.alpha
                @_dis.context.fillRect(
                    -@_dis.width / 2,
                    -@_dis.height / 2,
                    @_dis.width,
                    @_dis.height)
            
            #draw borders
            if @_border.visible
                @_dis.context.strokeStyle = @_border.color
                @_dis.context.lineWidth = @_border.size
                @_dis.context.globalAlpha = @_border.alpha
                @_dis.context.strokeRect(
                    -@_dis.width / 2,
                    -@_dis.height / 2,
                    @_dis.width,
                    @_dis.height)
            
            #calculate text offset
            yOffset = @_font.size / 4 * @_text.length
            if @_text.length > 2
                yOffset += @_font.size / 2 * (@_text.length - 2)
            
            if @get('align').toLowerCase() is 'center'
                xOffset = 0
            else if @get('align').toLowerCase() is 'left'
                xOffset = -@_dis.width / 2 + @_margins.left
                if @_border.visible
                    xOffset += @_border.size
            else if @get('align').toLowerCase() is 'right'
                xOffset = @_dis.width / 2 - @_margins.right
                if @_border.visible
                    xOffset -= @_border.size
            
            #initialize context for text
            @_dis.context.fillStyle = @_font.color
            @_dis.context.globalAlpha = @_font.alpha
            
            #draw text on canvas
            if @_text.length > 1
                for line, i in @_text
                    @_dis.context.fillText(
                        line,
                        xOffset,
                        @_font.size * 1.5 * i - yOffset)
            else
                @_dis.context.fillText(
                    @_text[0],
                    xOffset,
                    yOffset)
            
            #restore old context
            @_dis.context.restore()
    _update: ->
        #calculate new size
        @_dis.width = 0
        @_dis.height = @_font.size * 1.5 * @_text.length
        for line in @_text
            len = @_dis.context.measureText(line).width
            @_dis.width = len if @_dis.width < len
        
        #adjust for margins and border
        @_dis.width += @_margins.left + @_margins.right
        @_dis.height += @_margins.top + @_margins.bottom
        if @_border.visible
            @_dis.width += 2 * @_border.size
            @_dis.height += 2 * @_border.size
        
        #call Sprite update
        super()
#end class TextBox
