// Generated by CoffeeScript 1.8.0

/*
bouncingLogos.coffee

the classic bouncing ball
demonstration using the ubuntu logo
 */
var init, randomConfig, update;

document.title = 'Bouncing Logos';

env.IMAGE_PATH = '../images/';

env.ENGINE_BOTTOM_PANEL = 'Press Space to add more logos';

env.SPRITE_DEFAULT_CONFIG.imageFile = 'logo.png';

env.SPRITE_DEFAULT_CONFIG.boundAction = 'BOUNCE';

randomConfig = function() {
  var size;
  size = Math.round(Math.random() * 64 + 32);
  return {
    x: Math.random() * 400 - 200,
    y: Math.random() * 300 - 150,
    dx: Math.random() * 50 - 25,
    da: Math.random() * 2 - 1,
    width: size,
    height: size
  };
};

init = function() {
  var i;
  i = Math.round(Math.random() * 9 + 1);
  while (i > 0) {
    i -= 1;
    new Sprite(randomConfig());
  }
  return Greenhorn.start();
};

update = function() {
  if (keysDown[KEYS.SPACE]) {
    new Sprite(randomConfig());
  }
  return Sprites.changeAll('dy', -50);
};