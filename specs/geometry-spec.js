/*TODO: find a good way to test
 *distance and angle calculations
 *that are affected by rounding errors
 */

describe('Point', function(){
    var Point = gh.Point;

    describe('Private API', function(){
        it('should have a get method', function(){
            Point.prototype.get.should.be.a.Function;
        });

        it('should have a set method', function(){
            Point.prototype.set.should.be.a.Function;
        });

        it('should have a change method', function(){
            Point.prototype.change.should.be.a.Function;
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

describe('Line', function(){
    var Point = gh.Point;
    var Line = gh.Line;

    describe('Private API', function(){
        it('should have a get method', function(){
            Line.prototype.get.should.be.a.Function;
        });

        it('should have a contains method', function(){
            Line.prototype.contains.should.be.a.Function;
        });

        it('should have an intersection method', function(){
            Line.prototype.intersection.should.be.a.Function;
        });

        it('should have a collidesWith method', function(){
            Line.prototype.collidesWith.should.be.a.Function;
        });
    });

    describe('constructor', function(){
        var origin = {_pos: {x: 0, y: 0}};
        var p1 = new Point(-1, -1, origin);
        var p2 = new Point(1, 1, origin);
        var p3 = new Point(0, -1, origin);
        var p4 = new Point(0, 1, origin);

        it('should preserve the order when points are listed in ascending x order', function(){
            var line = new Line(p1, p2);

            line.p1.should.equal(p1);
            line.p2.should.equal(p2);
        });

        it('should reverse the order when points are listed in decending x order', function(){
            var line = new Line(p2, p1);

            line.p1.should.equal(p1);
            line.p2.should.equal(p2);
        });

        it('should preserve the order when points are listed in ascending y order', function(){
            var line = new Line(p3, p4);

            line.p1.should.equal(p3);
            line.p2.should.equal(p4);
        });

        it('should reverse the order when points are listed in decending y order', function(){
            var line = new Line(p4, p3);

            line.p1.should.equal(p3);
            line.p2.should.equal(p4);
        });
    });

    describe('::get', function(){
        var origin = {_pos: {x: 0, y: 0}};
        var p1 = new Point(-1, -1, origin);
        var p2 = new Point(1, 1, origin);
        var p3 = new Point(0, -1, origin);
        var p4 = new Point(0, 1, origin);

        it('should allow get("m")', function(){
            var line = new Line(p1, p2);
            (function(){line.get('m');}).should.not.throw();
        });

        it('should allow get("b")', function(){
            var line = new Line(p1, p2);
            (function(){line.get('b');}).should.not.throw();
        });

        it('should not allow get("anythingElse")', function(){
            var line = new Line(p1, p2);
            (function(){line.get('somethingNotAllowed');}).should.throw();
        });

        it('should return a Number when get("m") or get("b") is called on a non-vertical line', function(){
            var line = new Line(p1, p2);

            line.get('m').should.be.a.Number;
            line.get('b').should.be.a.Number;
        });

        it('should return undefined when get("m") or get("b") is called on a vertical line', function(){
            var line = new Line(p3, p4);

            Should.equal(line.get('m'), undefined);
            Should.equal(line.get('b'), undefined);
        });
    });

    describe('::contains', function(){
        var origin = {_pos: {x: 0, y: 0}};
        var p1 = new Point(-1, -1, origin);
        var p2 = new Point(1, 1, origin);
        var p3 = new Point(0, -1, origin);
        var p4 = new Point(0, 1, origin);
        var line1 = new Line(p1, p2);
        var line2 = new Line(p3, p4);

        it('should return true if a point is on the line and within it\'s bounds', function(){
            line1.contains(new Point(-.5, -.5, origin)).should.be.true;
            line1.contains(new Point(0, 0, origin)).should.be.true;
            line1.contains(new Point(.5, .5, origin)).should.be.true;

            line2.contains(new Point(0, -.5, origin)).should.be.true;
            line2.contains(new Point(0, 0, origin)).should.be.true;
            line2.contains(new Point(0, .5, origin)).should.be.true;
        });

        it('should return false if a point is on the line, but not within it\'s bounds', function(){
            line1.contains(new Point(-2, -2, origin)).should.be.false;
            line1.contains(new Point(2, 2, origin)).should.be.false;

            line2.contains(new Point(0, -2, origin)).should.be.false;
            line2.contains(new Point(0, 2, origin)).should.be.false;
        });

        it('should return false if a point is within it\'s bounds, but not on the line', function(){
            line1.contains(new Point(0, -.5, origin)).should.be.false;
            line1.contains(new Point(0, .5, origin)).should.be.false;
        });

        it('should return false if a point is not within it\'s bounds and not on the line', function(){
            line1.contains(new Point(-5, -2, origin)).should.be.false;
            line1.contains(new Point(2, 5, origin)).should.be.false;
        });
    });

    describe('::intersection', function(){
        var origin = {_pos: {x: 0, y: 0}};
        var p1 = new Point(-1, -1, origin);
        var p2 = new Point(1, 1, origin);
        var p3 = new Point(0, -1, origin);
        var p4 = new Point(0, 1, origin);
        var p5 = new Point(-1, 0, origin);
        var p6 = new Point(1, 0, origin);
        var line1 = new Line(p1, p2);
        var line2 = new Line(p3, p4);
        var line3 = new Line(p1, p4);
        var line4 = new Line(p3, p2);
        var line5 = new Line(p1, p3);
        var line6 = new Line(p4, p2);
        var line7 = new Line(p1, p5);
        var line8 = new Line(p6, p2);

        it('should return undefined when two lines are parallel', function(){
            Should.equal(line3.intersection(line4), undefined);
            Should.equal(line5.intersection(line6), undefined);
            Should.equal(line7.intersection(line8), undefined);
        });

        it('should return a Point when two lines are not parallel', function(){
            line1.intersection(line2).should.be.an.instanceof(Point);
            line1.intersection(line3).should.be.an.instanceof(Point);
            line1.intersection(line5).should.be.an.instanceof(Point);
            line2.intersection(line5).should.be.an.instanceof(Point);
        });
    });

    describe('::collidesWith', function(){
        var origin = {_pos: {x: 0, y: 0}};
        var p1 = new Point(-1, -1, origin);
        var p2 = new Point(1, 1, origin);
        var p3 = new Point(0, -1, origin);
        var p4 = new Point(0, 1, origin);
        var p5 = new Point(-1, 2, origin);
        var p6 = new Point(1, 2, origin);
        var line1 = new Line(p1, p2);
        var line2 = new Line(p3, p4);
        var line3 = new Line(p5, p6);

        it('should return true when two lines overlap', function(){
            line1.collidesWith(line2).should.be.true;
        });

        it('should return false when two lines do not overlap', function(){
            line1.collidesWith(line3).should.be.false;
            line2.collidesWith(line3).should.be.false;
        });
    });
});
