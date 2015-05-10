describe('Greenhorn', function(){
    var Greenhorn = gh.Greenhorn;
    
    it('should be an instance of EventEmitter', function(){
        (Greenhorn instanceof gh.EventEmitter).should.be.true;
    });
    
    describe('Public API', function(){
        it('should have a config object', function(){
            Greenhorn.config.should.be.an.Object;
            Greenhorn.config.should.have.properties({
                frameRate: 25,
                title: 'GH-TITLE',
                leftHeader: 'GH-LEFT-PANEL',
                rightHeader: 'GH-RIGHT-PANEL',
                footer: 'GH-FOOTER',
                startUp:{
                    size: 50
                    color: '#006400'
                    font: 'sans-serif'
                    text: 'CLICK HERE TO START!'
                }
            });
        });
        
        it('should have a buttonDefaults object', function(){
            Greenhorn.buttonDefaults.should.be.an.Object;
            Greenhorn.buttonDefaults.should.have.properties({
                type: 'button',
                onclick: undefined,
                parent: 'gh-right-panel',
                label: 'Launch the Missiles!'
            });
        });
        
        it('should have a canvas property', function(){
            Should.exist(Greenhorn.canvas);
        });
        
        it('should have a getMouseX method', function(){
            Greenhorn.getMouseX.should.be.a.Function;
        });
        
        it('should have a getMouseY method', function(){
            Greenhorn.getMouseY.should.be.a.Function;
        });
        
        it('should have an isDown method', function(){
            Greenhorn.isDown.should.be.a.Function;
        });
        
        it('should have an addButton method', function(){
            Greenhorn.addButton.should.be.a.Function;
        });
        
        it('should have a currentState method', function(){
            Greenhorn.currentState.should.be.a.Function;
        });
        
        it('should have a changeState method', function(){
            Greenhorn.changeState.should.be.a.Function;
        });
        
        it('should have an isRunning method', function(){
            Greenhorn.isRunning.should.be.a.Function;
        });
        
        it('should have a stop method', function(){
            Greenhorn.isRunning.should.be.a.Function;
        });
        
        it('should have a clear method', function(){
            Greenhorn.clear.should.be.a.Function;
        });
        
        it('should have a start method', function(){
            Greenhorn.start.should.be.a.Function;
        });
    });
});
