// Generated by CoffeeScript 1.8.0

/*
textBoxTimer.coffee

a demonstration of two classes at once
 */
var display, init, timer, update;

document.title = 'TextBox Timer';

env.ENGINE_RIGHT_PANEL = 'CONTROLS:\n    S-start\n    P-pause\n    R-restart\n    T-stop';

timer = null;

display = null;

init = function() {
  timer = new Timer(false);
  display = new TextBox({
    x: Math.random() * 400 - 200,
    y: Math.random() * 300 - 150,
    dx: Math.random() * 100 - 50,
    dy: Math.random() * 100 - 50,
    text: (timer.getElapsedTime() / 1000).toFixed(2),
    boundAction: 'BOUNCE'
  });
  return Greenhorn.start();
};

update = function() {
  if (keysDown[KEYS.S]) {
    timer.start();
  } else if (keysDown[KEYS.P]) {
    timer.pause();
  } else if (keysDown[KEYS.R]) {
    timer.restart();
  } else if (keysDown[KEYS.T]) {
    timer.stop();
  }
  Greenhorn.set('leftPanel', 'innerHTML', display.report());
  return display.set('text', (timer.getElapsedTime() / 1000).toFixed(2));
};