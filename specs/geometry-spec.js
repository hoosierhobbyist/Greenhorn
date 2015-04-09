/*TODO: find a good way to test
 *distance and angle calculations
 *that are affected by rounding errors
 */

describe('Point (private class)', function(){
    var Point = gh.Point;

    describe('API', function(){
        it('should have a get method', function(){
            Should.exist(Point.prototype.get);
        });

        it('should have a set method', function(){
            Should.exist(Point.prototype.set);
        });

        it('should have a change method', function(){
            Should.exist(Point.prototype.change);
        });
    });

    describe('::get', function(){
        var pt;

        beforeEach(function(){
            pt = new Point(1, 1, {_pos: {x: 0, y: 0}});
        });

        it('should allow get("x")', function(){
            (function(){pt.get('x')}).should.not.throw();
        });

        it('should allow get("y")', function(){
            (function(){pt.get('y')}).should.not.throw();
        });

        it('should allow get("a")', function(){
            (function(){pt.get('a')}).should.not.throw();
        });

        it('should allow get("dist")', function(){
            (function(){pt.get('dist')}).should.not.throw();
        });

        it('should not allow get("randomGarbage")', function(){
            (function(){pt.get('somethingNotAllowed')}).should.throw();
        });

        it('should return offset x and y coordinates', function(){
            pt = new Point(5, 5, {_pos:{x: 7, y: -2}});

            pt.get('x').should.equal(12);
            pt.get('y').should.equal(3);
        });
    });

    describe('::set', function(){
        var pt;

        beforeEach(function(){
            pt = new Point(1, 1, {_pos: {x: 0, y: 0}});
        });

        it('should allow set("x", value)', function(){
            (function(){pt.set('x', 0);}).should.not.throw();
        });

        it('should allow set("y", value)', function(){
            (function(){pt.set('y', 0);}).should.not.throw();
        });

        it('should allow set("a", value)', function(){
            (function(){pt.set('a', 0);}).should.not.throw();
        });

        it('should allow set("dist", value)', function(){
            (function(){pt.set('dist', 0);}).should.not.throw();
        });

        it('should not allow set("randomGarbage", value)', function(){
            (function(){pt.set('somethingNotAllowed', 0)}).should.throw();
        });

        it('should set x and y offsets from their origin', function(){
            pt = new Point(0, 0, {_pos: {x: -1, y: -1}});

            pt.set('x', -2);
            pt.set('y', 3);

            pt.get('x').should.equal(-3);
            pt.get('y').should.equal(2);
        });

        it('should return a self-reference for chaining', function(){
            var ref = pt.set('x', 0);
            ref.should.equal(pt);
        });
    });

    describe('::change', function(){
        var pt;

        beforeEach(function(){
            pt = new Point(1, 1, {_pos: {x: 0, y: 0}});
        });

        it('should allow change("x", value)', function(){
            (function(){pt.change('x', 1);}).should.not.throw();
        });

        it('should allow change("y", value)', function(){
            (function(){pt.change('y', 1);}).should.not.throw();
        });

        it('should allow change("a", value)', function(){
            (function(){pt.change('a', Math.PI);}).should.not.throw();
        });

        it('should allow change("dist", value)', function(){
            (function(){pt.change('dist', 3);}).should.not.throw();
        });

        it('should not allow change("randomGarbage", value)', function(){
            (function(){pt.change('somethingNotAllowed', 1)}).should.throw();
        });

        it('should change x and y offsets from their origin', function(){
            pt = new Point(1, 1, {_pos: {x: -1, y: -1}});

            pt.change('x', -2);
            pt.change('y', 3);

            pt.get('x').should.equal(-2);
            pt.get('y').should.equal(3);
        });

        it('should return a self-reference for chaining', function(){
            var ref = pt.change('x', 1);
            ref.should.equal(pt);
        });
    });
});

describe('Line (private class)', function(){
    var Line = gh.Line;

    describe('API', function(){
        it('should have a get method', function(){
            Should.exist(Line.prototype.get);
        });

        it('should have a collidesWith method', function(){
            Should.exist(Line.prototype.collidesWith);
        });

        it('should have a contains method', function(){
            Should.exist(Line.prototype.contains);
        });

        it('should have an intersection method', function(){
            Should.exist(Line.prototype.intersection);
        });
    });
});
