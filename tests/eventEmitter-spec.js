describe('EventEmitter', function(){
    var EventEmitter = gh.EventEmitter;

    describe('API', function(){
        it('should have an on method', function(){
            Should.exist(EventEmitter.prototype.on);
        });

        it('should have a once method', function(){
            Should.exist(EventEmitter.prototype.once);
        });

        it('should have an emit method', function(){
            Should.exist(EventEmitter.prototype.emit);
        });

        it('should have a remove method', function(){
            Should.exist(EventEmitter.prototype.remove);
        });

        it('should have a listeners method', function(){
            Should.exist(EventEmitter.prototype.listeners);
        });
    });

    describe('constructor', function(){
        var ee = new EventEmitter();

        it('should define an events mapping', function(){
            ee.listeners().should.not.be.undefined;
        });
    });

    describe('::on', function(){
        var ee;

        beforeEach(function(){
            ee = new EventEmitter();
        });

        it('should register an event', function(){
            ee.listeners('test').should.be.false;
            ee.on('test', function(){});
            ee.listeners('test').should.be.an.Array;
        });

        it('should fire an event:added event when a new event is registered', function(){
            var fired = false;

            ee.on('event:added', function(eventName){
                fired = true;
                eventName.should.equal('test');
            });

            ee.on('test', function(){});
            fired.should.be.true;
        });

        it('should not fire and event:added event when a new listener is added to an existing event', function(){
            var fired = false;

            ee.on('test', function(){});
            ee.on('event:added', function(eventName){fired = true;});

            ee.on('test', function(){});
            fired.should.be.false;
        });

        it('should fire a listener:added event whenever a new listener is added', function(){
            var fired = false;
            var test = function(){};

            ee.on('listener:added', function(eventName, listener){
                fired = true;
                eventName.should.equal('test');
                listener.should.equal(test);
            });

            ee.on('test', test);
            fired.should.be.true;

            fired = false;
            ee.on('test', test);
            fired.should.be.true;
        });

        it('should store listeners for the same event in the order given', function(){
            var test1 = function(){};
            var test2 = function(){};
            var test3 = function(){};

            ee.on('test', test1);
            ee.on('test', test3);
            ee.on('test', test2);

            ee.listeners('test').should.have.length(3);
            ee.listeners('test')[0].should.equal(test1);
            ee.listeners('test')[1].should.equal(test3);
            ee.listeners('test')[2].should.equal(test2);
        });

        it('should store any options on the listener array', function(){
            var options = {
                'one': 1,
                'two': 2,
                'three': 3
            };

            ee.on('test', function(){}, options);
            ee.listeners('test').should.have.properties(options);
        });

        it('should return a reference to itself for the purposes of chaining', function(){
            var ref = ee.on('test', function(){});
            ref.should.equal(ee);
        });
    });

    describe('::once', function(){
        var ee;

        beforeEach(function(){
            ee = new EventEmitter();
        });

        it('should behave like ::on', function(){
            var ref;
            var options = {
                'one': 1,
                'two': 2,
                'three': 3
            };

            ref = ee.once('test', function(){}, options);
            ref.should.equal(ee);
            ee.listeners('test').should.be.an.Array.and.have.properties(options);
        });

        it('should register a listener that is removed after one use', function(){
            var onTest = function(){};
            var onceTest = function(){};

            ee.on('test', onTest);
            ee.once('test', onceTest);

            ee.listeners('test').should.have.length(2);
            ee.emit('test');
            ee.listeners('test').should.have.length(1);
        });

        it('should not remove a duplicate listener that was registered with ::on', function(){
            var test = function(){};

            ee.on('test', test);
            ee.once('test', test);
            ee.emit('test');
            ee.listeners('test').should.have.length(1);
        });
    });
});
