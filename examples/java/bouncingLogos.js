// Generated by CoffeeScript 1.8.0

/*
bouncingLogos.coffee
Written by Seth Bullock
sedabull@gmail.com
 */
var init, randomConfig, update;

document.title = 'Bouncing Ubuntu Logos';

env.IMAGE_PATH = '../images/';

env.ENGINE.leftHeader = 'INFORMATION';

env.ENGINE.rightHeader = 'BUTTONS';

env.SPRITE_DEFAULT_CONFIG.ddy = -50;

env.SPRITE_DEFAULT_CONFIG.imageFile = 'logo.png';

env.SPRITE_DEFAULT_CONFIG.boundAction = 'BOUNCE';

randomConfig = function() {
  var size;
  size = Math.round(Math.random() * 64 + 32);
  return {
    width: size,
    height: size,
    da: Math.random() * 2 - 1,
    dx: Math.random() * 50 - 25,
    x: Math.random() * env.ENGINE.canvasWidth - env.ENGINE.canvasWidth / 2,
    y: Math.random() * env.ENGINE.canvasHeight - env.ENGINE.canvasHeight / 2
  };
};

init = function() {
  var i, information, _results;
  Greenhorn.start();
  Greenhorn.addButton({
    label: 'Start',
    onclick: function() {
      return Greenhorn.start();
    }
  });
  Greenhorn.addButton({
    label: 'Stop',
    onclick: function() {
      return Greenhorn.stop();
    }
  });
  Greenhorn.addButton({
    label: 'Add One',
    onclick: function() {
      return new Sprite(randomConfig());
    }
  });
  Greenhorn.addButton({
    label: 'Add Five',
    onclick: function() {
      var i, _results;
      i = 5;
      _results = [];
      while (i > 0) {
        i -= 1;
        _results.push(new Sprite(randomConfig()));
      }
      return _results;
    }
  });
  Greenhorn.addButton({
    label: 'Add Ten',
    onclick: function() {
      var i, _results;
      i = 10;
      _results = [];
      while (i > 0) {
        i -= 1;
        _results.push(new Sprite(randomConfig()));
      }
      return _results;
    }
  });
  Greenhorn.addButton({
    label: 'Add Fifty',
    onclick: function() {
      var i, _results;
      i = 50;
      _results = [];
      while (i > 0) {
        i -= 1;
        _results.push(new Sprite(randomConfig()));
      }
      return _results;
    }
  });
  Greenhorn.addButton({
    label: 'Remove All',
    onclick: function() {
      return Sprites.removeAll();
    }
  });
  information = '<div>\n<h4>Instructions</h4>\n<p style=\'margin:0\'>\nUse the Buttons on the left hand side\nto start and stop the engine, or add\nand remove Ubuntu Logos.\n</p>\n<h4>Trademark</h4>\n<p style=\'margin:0\'>\nPlease note that the logo used in this\nexample, which is known as\nThe Circle of Friends,\nis a registered trademark of\nCanonical Ltd.\n</p>\n</div>';
  $('#gh-left-panel').append(information);
  i = Math.round(Math.random() * 9 + 1);
  _results = [];
  while (i > 0) {
    i -= 1;
    _results.push(new Sprite(randomConfig()));
  }
  return _results;
};

update = function() {
  return $('#gh-title').html("" + document.title + ": " + (Sprites.howMany()));
};