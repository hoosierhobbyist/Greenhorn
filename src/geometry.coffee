###
geometry.coffee
Written by Seth Bullock
sedabull@gmail.com
###

class Point
    constructor: (@_x, @_y, @_sprite) ->
    
    get: (what) ->
        if what is 'x'
            @_x + @_sprite._pos.x
        else if what is 'y'
            @_y + @_sprite._pos.y
        else if what is 'a'
            Math.atan2 @_y, @_x
        else if what is 'dist'
            Math.sqrt @_y**2 + @_x**2
        else
            throw new Error "#{what} is not a get-able Point attribute"
    
    set: (what, to) ->
        if what is 'x'
            @_x = to
        else if what is 'y'
            @_y = to
        else if what is 'a'
            _x = @get('dist') * Math.cos to
            _y = @get('dist') * Math.sin to
            @set 'x', _x
            @set 'y', _y
        else if what is 'dist'
            _x = to * Math.cos @get 'a'
            _y = to * Math.sin @get 'a'
            @set 'x', _x
            @set 'y', _y
        else
            throw new Error "#{what} is not a set-able Point attribute"
        return this
    
    change: (what, step) ->
        if what is 'x'
            @_x += step
        else if what is 'y'
            @_y += step
        else if what is 'a'
            _x = @get('dist') * Math.cos step
            _y = @get('dist') * Math.sin step
            @change 'x', _x
            @change 'y', _y
        else if what is 'dist'
            _x = step * Math.cos @get('a')
            _y = step * Math.sin @get('a')
            @change 'x', _x
            @change 'y', _y
        else
            throw new Error "#{what} is not a change-able Point attribute"
        return this

class Line
    constructor: (@p1, @p2) ->
        if @p1.get('x') > @p2.get('x')
            [@p1, @p2] = [@p2, @p1]
        else if Math.abs(@p1.get('x') - @p2.get('x')) < .1 and @p1.get('y') > @p2.get('y')
            [@p1, @p2] = [@p2, @p1]
    
    get: (what) ->
        if what is 'slope' or 'm'
            if Math.abs(@p1.get('x') - @p2.get('x')) < .1
                undefined
            else
                (@p2.get('y') - @p1.get('y')) / (@p2.get('x') - @p1.get('x'))
        else if what is 'y-intercept' or 'b'
            if Math.abs(@p1.get('x') - @p2.get('x')) < .1
                undefined
            else
                -@get('m') * @p1.get('x') + @p1.get('y')
        else
            throw new Error "#{what} is not a get-able Line attribute"
    
    collidesWith: (other) ->
        if _int = @_intersection other
            if @_contains _int
                if other._contains _int
                    return true
        return false
    
    _contains: (pt) ->
        if Math.abs(@p1.get('x') - @p2.get('x')) < .1
            if Math.abs(@p1.get('x')- pt.get('x')) < .1
                if @p1.get('y') <= pt.get('y') <= @p2.get('y')
                    return true
        else if @p1.get('x') <= pt.get('x') <= @p2.get('x')
            if Math.abs((@get('m') * pt.get('x') + @get('b')) - pt.get('y')) < .1
                return true
        return false
    
    _intersection: (other) ->
        if @get('m') is undefined and other.get('m') is undefined
            return undefined
        else if @get('m') is undefined
            _x = @p1.get('x')
            _y = other.get('m') * _x + other.get('b')
        else if other.get('m') is undefined
            _x = other.p1.get('x')
            _y = @get('m') * _x + @get('b')
        else if Math.abs(@get('m') - other.get('m')) < .1
            return undefined
        else
            _x = (other.get('b') - @get('b')) / (@get('m') - other.get('m'))
            _y = @get('m') * _x + @get('b')
        return new Point _x, _y, _pos: {x: 0, y: 0}