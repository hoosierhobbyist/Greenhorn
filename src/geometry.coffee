###
geometry.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Point
    constructor: (@x, @y, @org_x, @org_y) ->
        @x += @org_x
        @y += @org_y
    
    get: (what) ->
        if what is 'x'
            @x.toFixed 2
        else if what is 'y'
            @y.toFixed 2
        else if what is 'org_x'
            @org_x.toFixed 2
        else if what is 'org_y'
            @org_y.toFixed 2
        else if what is 'a'
            Math.atan2 @y - @org_y, @x - @org_x
        else if what is 'dist'
            Math.sqrt (@y - @org_y)**2 + (@x - @org_x)**2
        else
            throw new Error "#{what} is not a get-able Point attribute"
    
    set: (what, to) ->
        if what is 'x'
            @x = to + @org_x
        else if what is 'y'
            @y = to + @org_y
        else if what is 'org_x'
            diff = to - @org_x
            @org_x = to
            @x += diff
        else if what is 'org_y'
            diff = to - @org_y
            @org_y = to
            @y += diff
        else if what is 'a'
            _x = @get('dist') * Math.cos to
            _y = @get('dist') * Math.sin to
            @x = _x + @org_x
            @y = _y + @org_y
        else if what is 'dist'
            _x = to * Math.cos @get 'a'
            _y = to * Math.sin @get 'a'
            @x = _x + @org_x
            @y = _y + @org_y
        else
            throw new Error "#{what} is not a set-able Point attribute"
        return this
    
    change: (what, step) ->
        if what is 'x'
            @x += step
        else if what is 'y'
            @y += step
        else if what is 'org_x'
            @x += step
            @org_x += step
        else if what is 'org_y'
            @y += step
            @org_y += step
        else if what is 'a'
            _x = @get('dist') * Math.cos step + @get('a')
            _y = @get('dist') * Math.sin step + @get('a')
            @x = _x + @org_x
            @y = _y + @org_y
        else if what is 'dist'
            _x = (@get('dist') + step) * Math.cos @get('a')
            _y = (@get('dist') + step) * Math.sin @get('a')
            @x = _x + @org_x
            @y = _y + @org_y
        else
            throw new Error "#{what} is not a change-able Point attribute"
        return this

class Line
    constructor: (@p1, @p2) ->
        if @p1.get('x') > @p2.get('x')
            [@p1, @p2] = [@p2, @p1]
        else if @p1.get('x') == @p2.get('x') and @p1.get('y') > @p2.get('y')
            [@p1, @p2] = [@p2, @p1]
    
    get: (what, roundOff = true) ->
        if what is 'slope' or 'm'
            if @p1.get('x') == @p2.get('x')
                undefined
            else
                if roundOff
                    ((@p2.y - @p1.y) / (@p2.x - @p1.x)).toFixed 2
                else
                    (@p2.y - @p1.y) / (@p2.x - @p1.x)
        else if what is 'y-intercept' or 'b'
            if @p1.get('x') == @p2.get('x')
                undefined
            else
                if roundOff
                    -((@p2.y - @p1.y) / (@p2.x - @p1.x) * @p1.x + @p1.y).toFixed 2
                else
                    -(@p2.y - @p1.y) / (@p2.x - @p1.x) * @p1.x + @p1.y
        else
            throw new Error "#{what} is not a get-able Line attribute"
    
    collidesWith: (other) ->
        if _int = @_intersection other
            if @_contains _int
                if other._contains _int
                    return true
        return false
    
    _contains: (pt) ->
        if @p1.get('x') == @p2.get('x') == pt.get('x')
            if @p1.get('y') <= pt.get('y') <= @p2.get('y')
                return true
        else if @p1.get('x') <= pt.get('x') <= @p2.get('x')
            if (@get('m', false) * pt.x + @get('b', false)).toFixed(2) == pt.get('y')
                return true
        return false
    
    _intersection: (other) ->
        if @get('m') == other.get('m')
            return undefined
        else if @get('m') is undefined
            _x = @p1.x
            _y = other.get('m', false) * _x + other.get('b', false)
        else if other.get('m') is undefined
            _x = other.p1.x
            _y = @get('m', false) * _x + @get('b', false)
        else
            _x = (other.get('b', false) - @get('b', false)) / (@get('m', false) - other.get('m', false))
            _y = @get('m', false) * _x + @get('b', false)
        return new Point _x, _y, 0, 0
