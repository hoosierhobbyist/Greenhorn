describe('Sound', function(){
    var Sound = gh.Sound;

    describe('Private API', function(){
        it('should have a _playAll method', function(){
            Sound._playAll.should.be.a.Function;
        });

        it('should have a _pauseAll method', function(){
            Sound._pauseAll.should.be.a.Function;
        });

        it('should have a _stopAll method', function(){
            Sound._stopAll.should.be.a.Function;
        });
    });

    describe('Public API', function(){
        it('should have a config object', function(){
            Sound.config.should.be.an.Object;
            Sound.config.should.have.properties({
                path: './',
                useAudioTag: false
            });
        });

        it('should have a defaults object', function(){
            Sound.defaults.should.be.an.Object;
            Sound.defaults.should.have.properties({
                url: "",
                loop: false,
                volume: 1.0,
                autoplay: false
            });
        });

        it('should have a play method', function(){
            Sound.prototype.play.should.be.a.Function;
        });

        it('should have a restart method', function(){
            Sound.prototype.restart.should.be.a.Function;
        });

        it('should have a pause method', function(){
            Sound.prototype.pause.should.be.a.Function;
        });

        it('should have a stop method', function(){
            Sound.prototype.stop.should.be.a.Function;
        });
    });
});
