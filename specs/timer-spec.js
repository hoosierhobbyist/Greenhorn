describe('Timer', function(){
    var Timer = gh.Timer;
    function wait(howLong){
        var start = (new Date()).getTime();
        while((new Date()).getTime() - start < howLong);
        return;
    }//end wait function

    describe('API', function(){
        it('should have a DEFAULTS object', function(){
            Should.exist(Timer.DEFAULTS);
            Timer.DEFAULTS.should.have.property('startImmediately').equal(true);
        });

        it('should have an isRunning method', function(){
            Should.exist(Timer.prototype.isRunning);
        });

        it('should have a getElapsedTime method', function(){
            Should.exist(Timer.prototype.getElapsedTime);
        });

        it('should have a start method', function(){
            Should.exist(Timer.prototype.start);
        });

        it('should have a pause method', function(){
            Should.exist(Timer.prototype.pause);
        });

        it('should have a restart method', function(){
            Should.exist(Timer.prototype.restart);
        });

        it('should have a stop method', function(){
            Should.exist(Timer.prototype.stop);
        });
    });

    describe('constructor', function(){
        it('should start running if feed true', function(){
            var timer = new Timer(true);
            timer.isRunning().should.be.true;
        });

        it('should not start running if feed false', function(){
            var timer = new Timer(false);
            timer.isRunning().should.be.false;
        });

        it('should use Timer.DEFAULTS.startImmediately if feed nothing', function(){
            var timer = new Timer();

            if(Timer.DEFAULTS.startImmediately){
                timer.isRunning().should.be.true;
            } else{
                timer.isRunning().should.be.false;
            }//end if/else
        });
    });

    describe('::isRunning', function(){
        it('should return true if the elapsed time is increasing with time', function(){
            var timer = new Timer(true);
            var control = timer.getElapsedTime();

            wait(5);
            timer.getElapsedTime().should.be.greaterThan(control);
            timer.isRunning().should.be.true;
        });

        it('should return false if the elapsed time is not increasing with time', function(){
            var timer = new Timer(false);
            var control = timer.getElapsedTime();

            wait(5);
            timer.getElapsedTime().should.equal(control);
            timer.isRunning().should.be.false;
        });
    });

    describe('::getElapsedTime', function(){
        it('should return zero if the timer hasn\'t run', function(){
            var timer = new Timer(false);

            wait(5);
            timer.getElapsedTime().should.equal(0);
        });

        it('should return more than zero if the timer has run', function(){
            var timer = new Timer(true);

            wait(5);
            timer.getElapsedTime().should.be.greaterThan(0);
        });
    });

    describe('::start', function(){
        it('should start the timer if not running', function(){
            var timer = new Timer(false);
            timer.isRunning().should.be.false;

            timer.start();
            timer.isRunning().should.be.true;
        });

        it('should not stop the timer if it is running', function(){
            var timer = new Timer(true);
            timer.isRunning().should.be.true;

            timer.start();
            timer.isRunning().should.be.true;
        });

        it('should not reset the elapsed time', function(){
            var control;
            var timer = new Timer(true);

            wait(10);
            control = timer.getElapsedTime();

            wait(5);
            timer.start();
            timer.getElapsedTime().should.be.greaterThan(control);
        });

        it('should resume from the current elapsed time when started from a pause', function(){
            var control;
            var timer = new Timer(true);

            wait(10);
            timer.pause();
            control = timer.getElapsedTime();
            timer.start();
            wait(5);
            timer.getElapsedTime().should.be.greaterThan(control);
        });
    });

    describe('::pause', function(){
        it('should stop the timer if it is running', function(){
            var timer = new Timer(true);
            timer.isRunning().should.be.true;

            timer.pause();
            timer.isRunning().should.be.false;
        });

        it('should not start the timer if it isn\'t running', function(){
            var timer = new Timer(false);
            timer.isRunning().should.be.false;

            timer.pause();
            timer.isRunning().should.be.false;
        });

        it('should preserve the elapsed time', function(){
            var timer = new Timer(true);

            wait(5);
            timer.pause();
            timer.getElapsedTime().should.be.greaterThan(0);
        });

        it('should not overwrite the elapsed time when already paused', function(){
            var control;
            var timer = new Timer(true);

            wait(5);
            timer.pause();
            control = timer.getElapsedTime();
            timer.pause();
            timer.getElapsedTime().should.equal(control);
        });
    });

    describe('::restart', function(){
        it('should start the timer if not running', function(){
            var timer = new Timer(false);
            timer.isRunning().should.be.false;

            timer.restart();
            timer.isRunning().should.be.true;
        });

        it('should not stop the timer if it is running', function(){
            var timer = new Timer(true);
            timer.isRunning().should.be.true;

            timer.restart();
            timer.isRunning().should.be.true;
        });

        it('should reset the elapsed time when running', function(){
            var control;
            var timer = new Timer(true);

            wait(5);
            control = timer.getElapsedTime();
            timer.restart();
            timer.getElapsedTime().should.be.lessThan(control);
        });

        it('should reset the elapsed time when not running', function(){
            var control;
            var timer = new Timer(true);

            wait(5);
            timer.pause();
            control = timer.getElapsedTime();
            timer.restart();
            timer.getElapsedTime().should.be.lessThan(control);
        });
    });

    describe('::stop', function(){
        it('should stop the timer if it is running', function(){
            var timer = new Timer(true);
            timer.isRunning().should.be.true;

            timer.stop();
            timer.isRunning().should.be.false;
        });

        it('should not start the timer if it isn\'t running', function(){
            var timer = new Timer(false);
            timer.isRunning().should.be.false;

            timer.stop();
            timer.isRunning().should.be.false;
        });

        it('should reset the elapsed time when running', function(){
            var timer = new Timer(true);

            wait(5);
            timer.stop();
            timer.getElapsedTime().should.equal(0);
        });

        it('should reset the elapsed time when not running', function(){
            var timer = new Timer(true);

            wait(5);
            timer.pause();
            timer.getElapsedTime().should.be.greaterThan(0);
            timer.stop();
            timer.getElapsedTime().should.equal(0);
        });
    });
});
