Greenhorn Gaming Engine
=======================

This project started out as a simple excersise in learning CoffeeScript.
I had previously worked with Andy Harris' simpleGame.js (included in history/)
and I decided to rewrite it in CS. It quickly became an obsession, and now I am
publishing it here, in the hopes that it will continue to grow into something amazing.

Working Examples
================

For the time being you can check out a few working examples at https://cs.iupui.edu/~sedabull.
I hope to have a more permanent website with demonstrations soon!

Using the Engine
================

If you would like to use the Greenhorn Gaming Engine to create your own games, all you must do
is download the file Greenhorn/lib/Greenhorn.js and include it in your webpage like this:
```
<!DOCTYPE html>
<html>
  <head>
    <script type="text/javascript" src="path/to/Greenhorn.js"></script>
    <script type="text/javascript">
      //set up the environment
      env.IMAGE_PATH = "path/to/images/"; //etc.
      
      //name your objects as globally available
      var sprite1, sprite2, textbox1; //etc.
      
      //the init function is called by the body onload
      function init() {
        //initialize objects
        sp1 = new Sprite(); //etc
        
        //do any document specific setup
        myDiv = document.getElementById("myDiv"); //etc
        
        //start the engine (very important)
        Greenhorn.start();
      }//end init
      
      //your own personal update function is called once per frame
      function update() {
        //handle events here
        if(keyDown[KEYS.UP]) {
          //do something
        }//end if
        if(sprite1.collidesWith(sprite2)) {
          //do something
        }//end if
        //etc.
  </head>
  <body onload="init()">
    <div id="myDiv"></div>
  </body>
</html>
```
