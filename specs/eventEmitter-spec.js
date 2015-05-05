describe('EventEmitter', function(){
    var EventEmitter = gh.EventEmitter;

    describe('Public API', function(){
        it('should have an on method', function(){
            EventEmitter.prototype.on.should.be.a.Function;
        });

        it('should have a once method', function(){
            EventEmitter.prototype.once.should.be.a.Function;
        });

        it('should have an emit method', function(){
            EventEmitter.prototype.emit.should.be.a.Function;
        });

        it('should have a remove method', function(){
            EventEmitter.prototype.remove.should.be.a.Function;
        });

        it('should have a listeners method', function(){
            EventEmitter.prototype.listeners.should.be.a.Function;
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

    describe('::emit', function(){
        var ee;

        beforeEach(function(){
            ee = new EventEmitter();
        });

        it('should return true if there are registered listeners', function(){
            ee.on('test', function(){});
            ee.emit('test').should.be.true;
        });

        it('should return false if there are no registered listeners', function(){
            ee.emit('test').should.be.false;
        });

        it('should pass arguments on to the listeners', function(){
            var fired = false;
            ee.on('test', function(one, two, three){
                fired = true;
                one.should.equal(1);
                two.should.equal(2);
                three.should.equal(3);
            });

            ee.emit('test', 1, 2, 3);
            fired.should.be.true;
        });
        
        it('should always fire all listeners', function(){
            var fired = [false, false, false, false false];
            
            ee.once('test', function(){
                fired[0] = true;
            });
            ee.on('test', function(){
                fired[1] = true;
            });
            ee.on('test', function(){
                fired[2] = true;
            });
            ee.once('test', function(){
                fired[3] = true;
            });
            ee.on('test', function(){
                fired[4] = true;
            });
            
            ee.emit('test');
            ee.listeners('test').should.have.length(3);
            fired.forEach(function(value){
                value.should.be.true;
            });
        });
    });

    describe('::remove', function(){
        var ee;

        beforeEach(function(){
            ee = new EventEmitter();
        });

        it('should unregister a listener when called with two arguments', function(){
            var test1 = function(){};
            var test2 = function(){};

            ee.on('test', test1);
            ee.on('test', test2);
            ee.listeners('test').should.have.length(2);

            ee.remove('test', test1);
            ee.listeners('test').should.have.length(1);
            ee.listeners('test')[0].should.equal(test2);
        });

        it('should return true when removing a registered listener', function(){
            var test = function(){};

            ee.on('test', test);
            ee.remove('test', test).should.be.true;
        });

        it('should return false when trying to remove an unregistered listener', function(){
            var test = function(){};

            ee.on('test', test);
            ee.remove('test', function(){}).should.be.false;
        });

        it('should delete the event if removing the last listener', function(){
            var test = function(){};

            ee.on('test', test);
            ee.listeners('test').should.have.length(1);

            ee.remove('test', test);
            ee.listeners('test').should.be.false;
        });

        it('should unregister an event when called with one argument', function(){
            ee.on('test', function(){});
            ee.once('test', function(){});

            ee.listeners('test').should.have.length(2);
            ee.remove('test');
            ee.listeners('test').should.be.false;
        });

        it('should return true when removing a registered event', function(){
            ee.on('test', function(){});
            ee.remove('test').should.be.true;
        });

        it('should return false when trying to remove an unregistered event', function(){
            ee.remove('test').should.be.false;
        });
    });

    describe('::listeners', function(){
        var ee;

        beforeEach(function(){
            ee = new EventEmitter();
        });

        it('should return the entire events object when called with zero arguments', function(){
            var test1 = function(){};
            var test2 = function(){};
            var test3 = function(){};

            ee.listeners().should.be.an.Object;

            ee.on('test1', test1);
            ee.on('test2', test2);
            ee.on('test2', test3);
            ee.listeners().should.have.properties({
                'test1': [
                    test1
                ],
                'test2': [
                    test2,
                    test3
                ]
            });
        });

        it('should return an array of listeners when accessing a registered event', function(){
            var test1 = function(){};
            var test2 = function(){};
            var test3 = function(){};

            ee.on('test', test1);
            ee.on('test', test2);
            ee.on('test', test3);
            ee.listeners('test').should.containDeepOrdered([test1, test2, test3]);
        });

        it('should return false when trying to access an unregistered event', function(){
            ee.listeners('test').should.be.false;
        });
    });
});
