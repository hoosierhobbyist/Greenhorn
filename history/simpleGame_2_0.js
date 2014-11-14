/* simpleGame.js
   a very basic game library for the canvas tag
   loosely based on Python gameEngine
   and Scratch
   expects an HTML5-compliant browser
   includes support for mobile browsers

   Main code and design: Andy Harris - 2011/2012
   
   Work done by Tyler Mitchell, Ben Apple, and Eugene Quilter

*/
function Sprite(scene, imageFile, width, height, z) {
    //core class for game engine
    this.scene = scene;
    this.canvas = scene.canvas;
    this.context = this.canvas.getContext("2d");
	this.context.textAlign = 'center';
	this.ctx = this.context;
    this.image = new Image();
    this.animation = false; // becomes Animation Class
    this.width = width;
    this.height = height;
    this.cHeight = parseInt(this.canvas.height);
    this.cWidth = parseInt(this.canvas.width);
    this.x = 200;
    this.y = 200;
    this.dx = 0;
    this.dy = 0;
    this.imgAngle = 0;
    this.moveAngle = 0;
    this.speed = 0;
    this.camera = false;
    this.visible = true;
    this.boundAction = STOP;
	
	//Manually set to false if object should not be clickable
    this.clickable = true;
	
	//Sets the z position of the object
    this.z = z; 

	//Adds and Sorts Sprites by Z value in Global Array spriteList
    spriteList.addSprite(this); 
	
	if(imageFile != null){
		this.image.src = imageFile;
	}

	//Method to call to see if a sprite has been clicked
    this.isClickable = function (x, y) { 
        if (this.visible == true) { 
            if (this.clickable == true) { 
                return this.isMouseDown(x, y); 
            } 
        } 
        return false; 
    } 

    this.changeImage = function (imgFile) {
        this.image.src = imgFile;
    } // end this.changeImage

    this.setImage = function (imgFile) {
        //set and change image are the same thing.
        this.image.src = imgFile;
    } // end this.setImage

    this.setPosition = function (x, y) {
        //position is position of center
        this.x = x;
        this.y = y;
    } // end setPosition function

    this.setX = function (nx) {
        this.x = nx;
    }
    this.setY = function (ny) {
        this.y = ny;
    }
    this.setChangeX = function (ndx) {
        this.dx = ndx;
    }
    this.setChangeY = function (ndy) {
        this.dx = ndx;
    }
    this.setDX = function (newDX) {
        this.dx = newDX;
    }
    this.setDY = function (newDY) {
        this.dy = newDY;
    }
    this.changeXby = function (tdx) {
        this.x += tdx
    };
    this.changeYby = function (tdy) {
        this.y += tdy
    };
    this.hide = function () {
        this.visible = false;
    }
    this.show = function () {
        this.visible = true;
    }

    this.draw = function () {
        //draw self on canvas;
        //intended only to be called from update, should never
        //need to be deliberately called by user
        ctx = this.context;

        ctx.save();
        //The following lines are for Tyler's code. Removed for now
        //if( this.camera ){ ctx.translate(this.x - this.camera.cameraOffsetX, this.y - this.camera.cameraOffsetY); }
        //else{ ctx.translate(this.x, this.y); }

        //transform element
        ctx.translate(this.x, this.y);
        ctx.rotate(this.imgAngle);

        //draw image with center on origin
        if (this.animation != false) {
            this.animation.drawFrame(ctx);
        } else {
            ctx.drawImage(this.image,
                0 - (this.width / 2),
                0 - (this.height / 2),
                this.width, this.height);
        }
        ctx.restore();

    } // end draw function

    this.update = function () {
        this.x += this.dx;
        this.y += this.dy;
        this.checkBounds();
        if (this.visible) {
            this.draw();
        } // end if
    } // end update

    this.setBoundAction = function (action) {
        this.boundAction = action;
    } // end setBoundAction

    this.checkBounds = function () {
        //behavior changes based on
        //boundAction property

        camX = 0;
        camY = 0;
        if (this.camera) {
            camX = this.camera.cameraOffsetX;
            camY = this.camera.cameraOffsetY;
        }
        rightBorder = this.cWidth + camX;
        leftBorder = camX;
        topBorder = camY;
        bottomBorder = this.cHeight + camY;

        offRight = false;
        offLeft = false;
        offTop = false;
        offBottom = false;

        if (this.x > rightBorder) {
            offRight = true;
        }

        if (this.x < leftBorder) {
            offLeft = true;
        }

        if (this.y > bottomBorder) {
            offBottom = true;
        }

        if (this.y < topBorder) {
            offTop = true;
        }

        if (this.boundAction == WRAP) {
            if (offRight) {
                this.x = leftBorder;
            } // end if

            if (offBottom) {
                this.y = topBorder;
            } // end if

            if (offLeft) {
                this.x = rightBorder;
            } // end if

            if (offTop) {
                this.y = bottomBorder;
            }
        } else if (this.boundAction == SEMIBOUNCE) {
            if (offBottom) {
                this.dy *= -.5;
                this.calcSpeedAngle();
                //this.imgAngle = this.moveAngle;
            }

            if (offLeft || offRight) {
                this.dx *= -.8;
                this.calcSpeedAngle();
                //this.imgAngle = this.moveAngle;
            }

        } else if (this.boundAction == BOUNCE) {
            if (offBottom || offTop) {
                this.dy *= -1;
                this.calcSpeedAngle();
                //this.imgAngle = this.moveAngle;
            }

            if (offLeft || offRight) {
                this.dx *= -1;
                this.calcSpeedAngle();
                //this.imgAngle = this.moveAngle;
            }

        } else if (this.boundAction == STOP) {
            if (offLeft || offRight || offTop || offBottom) {
                this.setSpeed(0);
            }
        } else if (this.boundAction == DIE) {
            if (offLeft || offRight || offTop || offBottom) {
                this.hide();
                this.setSpeed(0);
            }
        } else {
            //keep on going forever
        }
    } // end checkbounds

    this.loadAnimation = function (imgWidth, imgHeight, cellWidth, cellHeight) {
        this.animation = new Animation(this.image, imgWidth, imgHeight, cellWidth, cellHeight);
        this.animation.setup();
    }

    //animation methods 
    this.generateAnimationCycles = function (slicingFlag, framesArray) {
        //Default: assume each row is a cycle and give them names Cycle1, Cycle2, ... , CycleN
        //SINGLE_ROW: all the sprites are in one row on the sheet, the second parameter is either a number saying each cycle is that many frames or a list of how many frames each cycle is
        //SINGLE_COLUMN: all the sprites are in one column on the sheet, the second parameter is either a number saying each cycle is that many frames or a list of how many frames each cycle is
        //VARIABLE_LENGTH: How many frames are in each cycle. framesArray must be defined.
        cWidth = this.animation.cellWidth;
        cHeight = this.animation.cellHeight;
        iWidth = this.animation.imgWidth;
        iHeight = this.animation.imgHeight;
        numCycles = 0;
        nextStartingFrame = 0;
        if (typeof framesArray == "number" || typeof slicingFlag == "undefined") {
            if (slicingFlag == SINGLE_COLUMN) {
                numCycles = (iHeight / cHeight) / framesArray;
            } else if (typeof slicingFlag == "undefined") {
                numCycles = (iHeight / cHeight);
                framesArray = iWidth / cWidth;
            } else {
                numCycles = (iWidth / cWidth) / framesArray;
            }
            for (i = 0; i < numCycles; i++) {
                cycleName = "cycle" + (i + 1);
                this.specifyCycle(cycleName, i * framesArray, framesArray);
            }
        } else {
            numCycles = framesArray.length;
            for (i = 0; i < numCycles; i++) {
                cycleName = "cycle" + (i + 1);
                this.specifyCycle(cycleName, nextStartingFrame, framesArray[i]);
                nextStartingFrame += framesArray[i];
            }
        }
        this.setCurrentCycle("cycle1");
    }

    this.renameCycles = function (cycleNames) {
        this.animation.renameCycles(cycleNames);
    }
    this.specifyCycle = function (cycleName, startingCell, frames) {
        this.animation.addCycle(cycleName, startingCell, frames);
    }
    this.specifyState = function (stateName, cellName) {
        this.animation.addCycle(stateName, cellName, 1);
    }
    this.setCurrentCycle = function (cycleName) {
        this.animation.setCycle(cycleName);
    }
    this.pauseAnimation = function () {
        this.animation.pause();
    }
    this.playAnimation = function () {
        this.animation.play();
    }
    this.resetAnimation = function () {
        this.animation.reset();
    }
    this.setAnimationSpeed = function (speed) {
        this.animation.setAnimationSpeed(speed);
    }

    this.calcVector = function () {
        //used throughout speed / angle calculations to 
        //recalculate dx and dy based on speed and angle
        this.dx = this.speed * Math.cos(this.moveAngle);
        this.dy = this.speed * Math.sin(this.moveAngle);
    } // end calcVector

    this.calcSpeedAngle = function () {
        //opposite of calcVector:
        //sets speed and moveAngle based on dx, dy
        this.speed = Math.sqrt((this.dx * this.dx) + (this.dy * this.dy));
        this.moveAngle = Math.atan2(this.dy, this.dx);
    }

    this.setSpeed = function (speed) {
        this.speed = speed;
        this.calcVector();
    } // end setSpeed

    this.getSpeed = function () {
        //calculate speed based on current dx and dy
        speed = Math.sqrt((this.dx * this.dx) + (this.dy * this.dy));
        return speed;
    } // end getSpeed

    this.changeSpeedBy = function (diff) {
        this.speed += diff;
        this.calcVector();
    } // end changeSpeedBy

    this.setImgAngle = function (degrees) {
        //offset degrees by 90
        degrees = degrees;
        //convert degrees to radians
        this.imgAngle = degrees * Math.PI / 180;
    } // end setImgAngle

    this.getImgAngle = function () {
        //imgAngle is stored in radians.
        //return it in degrees
        //don't forget we offset the angle by 90 degrees
        return (this.imgAngle * 180 / Math.PI) + 90;
    }

    this.changeImgAngleBy = function (degrees) {
        rad = degrees * Math.PI / 180;
        this.imgAngle += rad;
    } // end changeImgAngle

    this.setMoveAngle = function (degrees) {
        //take movement angle in degrees
        // offset degrees by 90
        degrees = degrees - 90
        //convert to radians
        this.moveAngle = degrees * Math.PI / 180;
        this.calcVector();
    } // end setMoveAngle
	
	this.getMoveAngle = function(){
    //moveAngle is stored in radians.
    //return it in degrees
    //don't forget we offset the angle by 90 degrees
    return (this.moveAngle * 180 / Math.PI) + 90;    
  }

    this.changeMoveAngleBy = function (degrees) {
        //convert diff to radians
        diffRad = degrees * Math.PI / 180;
        //add radian diff to moveAngle
        this.moveAngle += diffRad;
        this.calcVector();
    } // end changeMoveAngleBy

    //convenience functions combine move and img angles
    this.setAngle = function (degrees) {
        this.setMoveAngle(degrees);
        this.setImgAngle(degrees);
    } // end setAngle

    this.changeAngleBy = function (degrees) {
        this.changeMoveAngleBy(degrees);
        this.changeImgAngleBy(degrees);
    } // end changeAngleBy

    this.turnBy = function (degrees) {
        //same as changeAngleBy
        this.changeAngleBy(degrees);
    }

    this.addVector = function (degrees, thrust) {
        //Modify the current motion vector by adding a new vector to it.

        //offset angle by 90 degrees
        degrees -= 90;
        //input angle is in degrees - convert to radians    
        angle = degrees * Math.PI / 180;

        //calculate dx and dy
        newDX = thrust * Math.cos(angle);
        newDY = thrust * Math.sin(angle);
        this.dx += newDX;
        this.dy += newDY;

        //ensure speed and angle are updated
        this.calcSpeedAngle();
    } // end addVector

    this.collidesWith = function (sprite) {
        //check for collision with another sprite

        //collisions only activated when both sprites are visible
        collision = false;
        if (this.visible) {
            if (sprite.visible) {
                //define borders
                myLeft = this.x - (this.width / 2);
                myRight = this.x + (this.width / 2);
                myTop = this.y - (this.height / 2);
                myBottom = this.y + (this.height / 2);
                otherLeft = sprite.x - (sprite.width / 2);
                otherRight = sprite.x + (sprite.width / 2);
                otherTop = sprite.y - (sprite.height / 2);
                otherBottom = sprite.y + (sprite.height / 2);

                //assume collision
                collision = true;

                //determine non-colliding states
                if ((myBottom < otherTop) ||
                    (myTop > otherBottom) ||
                    (myRight < otherLeft) ||
                    (myLeft > otherRight)) {
                    collision = false;
                } // end if

            } // end 'other visible' if
        } // end 'I'm visible' if

        return collision;
    } // end collidesWith

    this.collidesWithMouse = function () {
        //check for collision with another sprite
		x = scene.getMouseX()
		y = scene.getMouseY()

        //collisions only activated when both sprites are visible
        collision = false;
        if (this.visible) {

            //define borders
            myLeft = this.x - (this.width / 2);
            myRight = this.x + (this.width / 2);
            myTop = this.y - (this.height / 2);
            myBottom = this.y + (this.height / 2);

            //assume collision
            collision = true;

            //determine non-colliding states
            if ((myBottom < y) ||
                (myTop > y) ||
                (myRight < x) ||
                (myLeft > x)) {
                collision = false;
            } // end if


        } // end 'I'm visible' if

        return collision;
    } // end collidesWith

    this.distanceTo = function (sprite) {
        diffX = this.x - sprite.x;
        diffY = this.y - sprite.y;
        dist = Math.sqrt((diffX * diffX) + (diffY * diffY));
        return dist;
    } // end distanceTo

    this.angleTo = function (sprite) {
        //get centers of sprites
        myX = this.x + (this.width / 2);
        myY = this.y + (this.height / 2);
        otherX = sprite.x + (sprite.width / 2);
        otherY = sprite.y + (sprite.height / 2);

        //calculate difference
        diffX = myX - otherX;
        diffY = myY - otherY;
        radians = Math.atan2(diffY, diffX);
        degrees = radians * 180 / Math.PI;
        //degrees are offset
        degrees += 90;
        return degrees;
    } // end angleTo

    this.angleToMouse = function () {
        myX = this.x + (this.width / 2);
        myY = this.y + (this.height / 2);
        otherX = this.scene.mouseX;
        otherY = this.scene.mouseY;

        diffX = myX - otherX;
        diffY = myY - otherY;
        radians = Math.atan2(diffY, diffX);
        degrees = radians * 180 / Math.PI;
        degrees += 270;
        return degrees;
    } // end angleToMouse

    this.isMouseDown = function (mx, my) {
        //determines if mouse is clicked on this element
        sLeft = this.x - this.width / 2;
        sRight = this.x + this.width / 2;
        sTop = this.y - this.height / 2;
        sBottom = this.y + this.height / 2;
        hit = false;

        if (mx > sLeft) {
            if (mx < sRight) {
                if (my > sTop) {
                    if (my < sBottom) {
                        hit = true;
                    }
                }
            }
        }
        return hit;
    } // end isMouseDown
	
	this.isClicked = function(){
		return this.isMouseDown();
  } // end isClicked

    this.setCameraRelative = function (cam) {
        this.camera = cam;
    }

    this.report = function () {
        //used only for debugging. Requires browser with JS console
        console.log("x: " + this.x + ", y: " + this.y + ", dx: " + this.dx + ", dy: " + this.dy + ", speed: " + this.speed + ", angle: " + this.moveAngle);
    } // end report
} // end Sprite class def

function Scene() {
    //Scene that encapsulates the animation background

    //determine if it's a touchscreen device
    this.touchable = 'createTouch' in document;
	scene = this;

    //dynamically create a canvas element
    this.canvas = document.createElement("canvas");
    this.canvas.style.backgroundColor = "yellow";
    document.body.appendChild(this.canvas);
    this.context = this.canvas.getContext("2d");
    spriteList = new SpriteList();
	
	if (typeof webkitAudioContext !== 'undefined') {
		this.audio_ctx = new webkitAudioContext();
	}
	
	this.canvas.addEventListener('touchstart', function (e) {scene.touchstartEvent(e)}, false);
	
	this.canvas.addEventListener('click', function () {scene.clickEvent()}, false);
	

	this.touchstartEvent = function(e){
		e.preventDefault();
		this.mouseX = e.pageX - this.left;
        this.mouseY = e.pageY - this.top;
		spriteList.findSprite('Clicked', this.mouseX, this.mouseY);
	}
	
	this.clickEvent = function(){
		this.mouseX = this.getMouseX() - this.left;
        this.mouseY = this.getMouseY() - this.top;
		spriteList.findSprite('Clicked', this.mouseX, this.mouseY);
		
	}
	
    this.clear = function () {
        this.context.clearRect(0, 0, this.width, this.height);
    }

    this.start = function () {
        //set up keyboard reader if not a touch screen.
        if (!this.touchable) {
            this.initKeys();
            document.onkeydown = this.updateKeys;
            document.onkeyup = this.clearKeys;
        } // end if
        this.intID = setInterval(localUpdate, 50);
        document.onmousemove = this.updateMousePos;
        document.mouseClicked = false;
        document.onmousedown = function () {
            this.mouseDown = true;
            this.mouseClicked = true;
        }
        document.onmouseup = function () {
            this.mouseDown = false;
            this.mouseClicked = false;
        }
    }

    this.stop = function () {
        clearInterval(this.intID);
    }

    this.updateKeys = function (e) {
        //set current key
        currentKey = e.keyCode;
        //console.log(e.keyCode);
        keysDown[e.keyCode] = true;
    } // end updateKeys

    this.clearKeys = function (e) {
        currentKey = null;
        keysDown[e.keyCode] = false;
    } // end clearKeys

    this.initKeys = function () {
        //initialize keys array to all false
        for (keyNum = 0; keyNum < 256; keyNum++) {
            keysDown[keyNum] = false;
        } // end for
    } // end initKeys

    this.setSizePos = function (height, width, top, left) {
        //convenience function.  Cals setSize and setPos
        this.setSize(height, width);
        this.setPos(top, left);
    } // end setSizePos

    this.setSize = function (width, height) {
        //set the width and height of the canvas in pixels
        this.width = width;
        this.height = height;
        this.canvas.width = this.width;
        this.canvas.height = this.height;
    } // end setSize

    this.setPos = function (left, top) {
        //set the left and top position of the canvas
        //offset from the page
        this.left = left;
        this.top = top;

        //CSS3 transform to move elements.
        //Cross-browser compatibility would be awesome, guys...
        this.canvas.style.MozTransform = "translate(" + left + "px, " + top + "px)";
        this.canvas.style.WebkitTransform = "translate(" + left + "px, " + top + "px)";
        this.canvas.style.OTransform = "translate(" + left + "px, " + top + "px)";

    } // end setPos

    this.setBG = function (color) {
        this.canvas.style.backgroundColor = color;
    } // end this.setBG

    this.updateMousePos = function (e) {
        this.mouseX = e.pageX;
        this.mouseY = e.pageY;
    } // end function

    this.hideCursor = function () {
        this.canvas.style.cursor = "none";
    }

    this.showCursor = function () {
        this.canvas.style.cursor = "default";
    }

    this.getMouseX = function () {
        //incorporate offset for canvas position
        return document.mouseX - this.left;
    }

    this.getMouseY = function () {
        //incorporate offset for canvas position
        return document.mouseY - this.top;
    }

    this.getMouseClicked = function () {
        return document.mouseClicked;
    }

    this.hide = function () {
        this.canvas.style.display = "none";
    }

    this.show = function () {
        this.canvas.style.display = "block";
    }

    this.setSize(800, 600);
    this.setPos(10, 10);
    this.setBG("lightgray");

} // end Scene class def

function SpriteList() { 
    this.list = new Array(); 
    this.highestZ = 0; 

    this.addSprite = function (sprite) { 
        if (this.list.length > 0) { 
            for (i = 0; i < this.list.length; i++) { 
                if (sprite.z <= this.list[i].z) { 
                    this.list.splice(i, 0, sprite); 
                    break; 
                } 
                if (i == (this.list.length)) { 
                    this.list.splice(i, 0, sprite);
                    break;
                } 
            } 
        } 
        else { 
            this.list.push(sprite); 
        } 
    } 

    this.update = function () { 
        for (i = 0; i < this.list.length; i++) { 
            this.list[i].update(); 
        } 
    } 

    this.findSprite = function (event, x, y) { 
		var found = false;
        for (i = (this.list.length - 1); i >= 0; i--) { 
            if (this.list[i].isClickable(x, y) == true) { 
				found = true;
                if (typeof this.list[i].clicked == 'function') {
					this.list[i].clicked(); 
                    break; 
                } 
                else { 
                    console.log("ERROR: No clicked() function found");
                    break; 
                } 
            } 
        }
		if(found == false){
			if(typeof clicked == 'function'){
				clicked();
			}
		}
    }
	
	this.length = function() {
		return this.list.length;
	}
} 

function Sound(src) {
	this.url = src;
	this.buffer;
	this.source;
	this.request;
	var me = this;
	
	if (typeof webkitAudioContext !== 'undefined') {
			this.request = new XMLHttpRequest();
			this.request.open('GET', this.url, true);
			this.request.responseType = 'arraybuffer';
			me.request.onload = function() {
			    scene.audio_ctx.decodeAudioData(this.response, function(theBuffer) {
				me.buffer = theBuffer;
			  }, this.onError);
			}
		this.request.send();
	}
	else {
		var audioElement = document.createElement('audio');
		
		var mp3_src = document.createElement('source');
		var ogg_src = document.createElement('source');
		
		/*if(this.url.indexOf(".mp3") > -1 ) {
			mp3_src.src = this.url;
			mp3_src.type = 'audio/mp3';
			
			ogg_src.src = this.url.replace('.mp3', '.ogg');
			ogg_src.type = 'audio/ogg';
			
		} else  {
			ogg_src.src = this.url;
			ogg_src.type = 'audio/ogg';
			
			mp3_src.src = this.url.replace('.ogg', '.mp3');
			mp3_src.type = 'audio/mp3';
		}*/
		
		mp3_src.src = this.url;
		mp3_src.type = 'audio/mp3';
			
		ogg_src.src = this.url.replace('.mp3', '.ogg');
		ogg_src.type = 'audio/ogg';
		
		audioElement.appendChild(mp3_src);
		audioElement.appendChild(ogg_src);
		
		document.body.appendChild(audioElement);
		
		this.audio = audioElement;
	}
	
	this.onError = function() {
		console.log("There was an Error");
	}
	
	this.playSound = function (opt) {
		this.opt = opt || {}
		if (typeof webkitAudioContext !== 'undefined') {
			this.source = scene.audio_ctx.createBufferSource();
			this.source.buffer = this.buffer;	
			this.gain_node = scene.audio_ctx.createGainNode();
			this.source.connect(this.gain_node);
			this.gain_node.connect(scene.audio_ctx.destination);
			
			if (typeof this.opt.sound !== 'undefined'){
				this.gain_node.gain.value = this.opt.sound;
			}
			else{
				this.gain_node.gain.value = 1;
			}
		 
			if (this.opt.loop){
				this.source.loop = true;
			}
			this.source.start(0);
		}
		else {
			this.audio.play();
		}
	}
	
	this.stopSound = function () {
		if (typeof webkitAudioContext !== 'undefined') {
			this.source.stop(0);
		}
		else {
			this.audio.pause();
			this.audio.currentTime = 0;
		}
	}
}

function Joy() {
    //virtual joystick for ipad
    //console.log("joystick created");
    //when activated, document will have the following properties
    //mouseX, mouseY: touch read as mouse input
    //diffX, diffY: touch motion read as a joystick input
    //if virtKeys is set true
    //joystick inputs will be read as arrow keys

    //properties
    SENSITIVITY = 50;
    diffX = 0;
    diffY = 0;
    var touches = [];
    var startX;
    var startY;

    //define event handlers
    this.onTouchStart = function (event) {
        result = "touch: ";
        touches = event.touches;
        startX = touches[0].screenX;
        startY = touches[0].screenY;
        result += "x: " + startX + ", y: " + startY;
        //define mouse position based on touch position
        document.mouseClicked = true;
        this.mouseX = startX;
        this.mouseY = startY;
        console.log(result);
    } // end onTouchStart

    this.onTouchMove = function (event) {
        result = "move: "
        event.preventDefault();
        touches = event.touches;
        //map touch position to mouse position
        this.mouseX = touches[0].screenX;
        this.mouseY = touches[0].screenY;
        this.diffX = touches[0].screenX - startX;
        this.diffY = touches[0].screenY - startY;
        result += "dx: " + this.diffX + ", dy: " + this.diffY;

        //manage virtual keys if enabled    
        if (virtKeys) {
            THRESHHOLD = 10;
            if (this.diffX > THRESHHOLD) {
                keysDown[K_RIGHT] = true;
            } else {
                keysDown[K_RIGHT] = false;
            } // end if

            if (this.diffX < -THRESHHOLD) {
                keysDown[K_LEFT] = true;
            } else {
                keysDown[K_LEFT] = false;
            } // end if

            if (this.diffY > THRESHHOLD) {
                keysDown[K_DOWN] = true;
            } else {
                keysDown[K_DOWN] = false;
            } // end if

            if (this.diffY < -THRESHHOLD) {
                keysDown[K_UP] = true;
            } else {
                keysDown[K_UP] = false;
            } // end if

        } // end if
        console.log(result);
    } // end onTouchMove

    this.onTouchEnd = function (event) {
        result = "no touch";
        touches = event.touches;
        this.diffX = 0;
        this.diffY = 0;
        document.mouseClicked = false;

        //turn off all virtual keys
        if (virtKeys) {
            keysDown[K_LEFT] = false;
            keysDown[K_RIGHT] = false;
            keysDown[K_UP] = false;
            keysDown[K_DOWN] = false;
        }
        console.log(result);
    } // end onTouchEnd

    // add utility methods to retrieve various attributes
    this.getDiffX = function () {
        //compensate for possible null
        if (document.diffX == null) {
            document.diffX = 0;
        } // end if
        return document.diffX;
    }
    this.getDiffY = function () {
        //compensate for possible null
        if (document.diffY == null) {
            document.diffY = 0;
        } // end if
        return document.diffY;
    }

    this.getMouseX = function () {
        return document.mouseX;
    }
    this.getMouseY = function () {
        return document.mouseY;
    }

    //add event handlers if appropriate
    touchable = 'createTouch' in document;
    if (touchable) {
        document.addEventListener('touchstart', this.onTouchStart, false);
        document.addEventListener('touchmove', this.onTouchMove, false);
        document.addEventListener('touchend', this.onTouchEnd, false);
    } // end if

} // end joy class def

function Accel() {
    //virtual accelerometer

    //properties
    var ax;
    var ay;
    var az;

    var rotX;
    var rotY;
    var rotZ;

    if (window.DeviceMotionEvent == undefined) {
        console.log("This program requires an accelerometer");
    } else {
        window.ondevicemotion = function (event) {
            this.ax = event.accelerationIncludingGravity.x;
            this.ay = event.accelerationIncludingGravity.y;
            this.az = event.accelerationIncludingGravity.z;

            rotation = event.rotationRate;
            if (rotation != null) {
                this.rotX = Math.round(rotation.alpha);
                this.rotY = Math.round(rotation.beta);
                this.rotZ = Math.round(rotation.gamma);
            } // end if
        } // end event handler 
    } // end if

    //return values with utility methods

    this.getAX = function () {
        if (window.ax == null) {
            window.ax = 0;
        }
        return window.ax;
    } // end getAx

    this.getAY = function () {
        if (window.ay == null) {
            window.ay = 0;
        }
        return window.ay;
    } // end getAx

    this.getAZ = function () {
        if (window.az == null) {
            window.az = 0;
        }
        return window.az;
    } // end getAx

    this.getRotX = function () {
        return rotX;
    }
    this.getRotY = function () {
        return rotY;
    }
    this.getRotZ = function () {
        return rotZ;
    }

} // end class def

function Timer() {
    //simple timer

    this.reset = function () {
        this.date = new Date();
        this.startTime = this.date.getTime();
        this.elapsedTime = 0;
    } // end reset


    this.getCurrentTime = function () {
        this.date = new Date();
        return this.date.getTime();
    } // end getCurrentTime

    this.getElapsedTime = function () {
        current = this.getCurrentTime();
        return (current - this.startTime) / 1000;
    } // end getElapsedTime

    //make alias functions for animations...
    this.start = this.reset;
    this.getTimeElapsed = this.getElapsedTime;

    this.reset();
} // end Timer def

var AnimTimer = function () {
    //special timer for animations
    this.date = new Date();
    this.lastTime = 0;
    this.currentTime = 0;

    this.start = function () {
        this.currentTime = Date.now();
    }

    this.reset = function () {
        this.currentTime = Date.now();
    }

    this.getTimeElapsed = function () {
        this.lastTime = this.currentTime;
        this.currentTime = Date.now();
        return (this.currentTime - this.lastTime);
    }
}

function localUpdate() {
        //will be called once per frame
        //calls the update function defined by
        //the user
        update();
    } // end localUpdate

function GameButton(label) {
        /*
	This object creates a button that can be sized
	and positioned wherever you wish. The label will
	be displayed, but can be complete HTML (including
	an image tag if you wish.)  Use isClicked() to
	get the current status of the button (true or false.)
	Responds to touch events on mobile devices.
    */

        this.clicked = false;
        this.button = document.createElement("button");
        this.button.setAttribute("type", "button");
        this.button.innerHTML = label;
        this.button.style.position = "absolute";
        this.button.style.left = "0px";
        this.button.style.top = "0px";

        this.button.onmousedown = function () {
            this.clicked = true;
        } // end mousedown

        this.button.ontouchstart = function () {
            this.clicked = true;
        } // end touchstart

        this.button.onmouseup = function () {
            this.clicked = false;
        } // end onmouseup

        this.isClicked = function () {
            return this.button.clicked;
        } // end isClicked

        this.setPos = function (left, top) {
            this.button.style.left = left + "px";
            this.button.style.top = top + "px";
        } // end setPos

        this.setPosition = function (left, top) {
            //utility alias for setPos
            this.setPos(left, top);
        }

        this.setSize = function (width, height) {
            this.button.style.width = width + "px";
            this.button.style.height = height + "px";
        } // end setSize

        document.body.appendChild(this.button);
    } // end gameButton class def

function Animation(spriteSheet, imgWidth, imgHeight, cellWidth, cellHeight) {
        //Animation class by Tyler Mitchell
        //for simplicity, all cells must be the same width and height combination
        this.sheet = spriteSheet;
        this.imgWidth = imgWidth;
        this.imgHeight = imgHeight;
        this.cellWidth = cellWidth;
        this.cellHeight = cellHeight;
        this.animationLength = 1000;
        this.changeLength = false;
        this.cycles = new Array();
        this.currentCycleName = "";
        this.currentCycle = null;
        this.cyclePlaySettings = new Array(PLAY_LOOP, PLAY_LOOP, PLAY_LOOP, PLAY_LOOP);
        this.changeAnimation = false;
        this.timer = new AnimTimer();
        this.framesPerRow = 0;
        this.framesPerColumn = 0;
        this.totalCycleTime = 0;
        this.fps = 0;
        this.isPaused = false;

        this.setup = function () {
            this.timer.start();
            this.framesPerRow = this.imgWidth / this.cellWidth;
            this.framesPerColumn = this.imgHeight / this.cellHeight;
        }

        this.addCycle = function (cycleName, startingCell, frames) {
            cycle = new Array(cycleName, startingCell, frames);
            this.cycles.push(cycle);
        }

        this.drawFrame = function (ctx) { //most of the math in this function could be done only once if we want to make it faster
            this.fps += 1;
            if (!this.isPaused) {
                this.totalCycleTime += this.timer.getTimeElapsed();
            }
            if (this.changeAnimation == true) { // find the correct animation in
                for (i = 0; i < this.cycles.length; i++) {
                    if (this.cycles[i][0] == this.currentCycleName) {
                        this.currentCycle = this.cycles[i];
                    }
                }
            }
            if (this.changeAnimation || this.changeLength) {
                this.frameDelta = this.animationLength / this.currentCycle[2]; // this will be how much time should pass at a minimum before switching to the next frame 
                this.changeAnimation = false;
                this.changeLength = false;
                this.fps = 0;
            }
            //console.log("Cycletime: " + this.totalCycleTime);
            //console.log("Frame Delta: " + this.frameDelta);
            //I think the following line is the trouble spot
            //currentFrame = Math.floor( (this.totalCycleTime % this.animationLength) / this.frameDelta );
            elTime = this.totalCycleTime % this.animationLength;
            currentFrame = Math.floor(elTime / this.frameDelta);
            //console.log(elTime);

            //document.getElementById("FPS").innerHTML = this.animationLength;//for debugging
            row = Math.floor((this.currentCycle[1] + currentFrame) / this.framesPerRow);
            col = (this.currentCycle[1] + currentFrame) - (row * Math.floor(this.imgWidth / this.cellWidth));
            frameY = row * this.cellHeight;
            frameX = col * this.cellWidth;

            ctx.drawImage(this.sheet, frameX, frameY, this.cellWidth, this.cellHeight, 0 - (this.cellWidth / 2), 0 - (this.cellHeight / 2), this.cellWidth, this.cellHeight);
        }


        this.setCycle = function (cycleName) {
            this.currentCycleName = cycleName;
            this.changeAnimation = true;
            this.totalCycleTime = 0;
        }

        this.renameCycles = function (cycleNames) {
            for (i = 0; i < cycleNames.length; i++) {
                number = parseInt(this.cycles[i][0].slice(5));
                if (this.currentCycleName == this.cycles[i][0]) {
                    this.currentCycleName = cycleNames[number - 1];
                }
                this.cycles[i][0] = cycleNames[number - 1];
            }
        }

        this.play = function () {
            this.isPaused = false;
            this.timer.reset();
        }

        this.pause = function () {
            this.isPaused = true;
        }

        this.reset = function () {
            this.totalCycleTime = 0;
            this.timer.reset();
        }

        this.setAnimationSpeed = function (animLength) { //animLength is in milliseconds
            if (animLength <= 50) {
                animLength = 50;
            }
            this.animationLength = animLength;
            this.changeLength = true;
        }

    } // end of Animation class

function TextBox(scene, image, width, height){
// A simplified text box that displays text within a box.
	tTextBox = new Sprite(scene, image, width, height);
	
	tTextBox.backColor = '#FFFFFF';
	tTextBox.backAlpha = 1.0;
	tTextBox.backImage = image;
	tTextBox.backgroundImg = new Image();
	tTextBox.backStyle = NONE;
	
	if(tTextBox.backImage){
		tTextBox.backgroundImg.src = tTextBox.backImage;
	}
	
	tTextBox.text = 'Text Text';
	tTextBox.font = 'Arial';
	tTextBox.fontSize = 20;
	tTextBox.fontColor = '#000000';
	tTextBox.align = "center";
	tTextBox.autoFit = false;
	
	tTextBox.borderSize = 0;
	tTextBox.borderColor = '#000000';
	tTextBox.borderAlpha = 1.0;
	
	tTextBox.marginTop = 0;
	tTextBox.marginBottom = 0;
	tTextBox.marginRight = 0;
	tTextBox.marginLeft = 0;
	tTextBox.alpha = 1.0;
	
	tTextBox.setBackground = function(color, alpha) {
		this.backColor = color;
		this.backAlpha = alpha;
	} // end changeBackground
	
	tTextBox.setImage = function(image, style) {
		this.backImage = image;
		this.backStyle = style;
		if(this.backImage != null) {
			this.backgroundImg.src = this.backImage;
		} // end if
	} // end changeImage
	
	tTextBox.setFont = function(font, size, color) {
		this.font = font;
		this.fontSize = size;
		this.fontColor = color;
	} // end changeFont
	
	tTextBox.setBorder = function(size, color, alpha) {
		this.borderSize = size;
		this.borderColor = color;
		this.borderAlpha = alpha;
	} // end changeBorder
	
	tTextBox.setMargin = function(top, bot, rig, lef) {
		this.marginTop = top;
		this.marginBottom = bot;
		this.marginRight = rig;
		this.marginLeft = lef;
	} // end setMargin
	
	tTextBox.resize = function(width, height) {
		this.width = width;
		this.height = height;
	} // end resize
	
	tTextBox.fitText = function(){
		this.height = this.fontSize * this.textArray.length + this.fontSize;
		this.width = this.context.measureText(this.textArray[0]).width + this.fontSize;
		
		for(var i=0;i<this.textArray.length;i++){
			if(this.width < this.context.measureText(this.textArray[i]).width + this.fontSize){
				this.width = this.context.measureText(this.textArray[i]).width + this.fontSize;
			}
		}
	}
	
	tTextBox.setAlign = function(align){
		this.ctx.textAlign = align;
	}

    tTextBox.writeText = function (text, align) {
        // A simple function that allows text to be written by a sprite. The text begins offset from the
        // sprite's x and y by the given offset. It also supports very basic character wrapping given a
        // max number of characters per line.
		
		this.text = text;
		this.align = align;
		
		ctx = this.context;
		ctx.font = this.fontSize + 'px ' + this.font;
		ctx.fillStyle = this.fontColor;
		ctx.globalAlpha = this.alpha;
		ctx.textAlign = this.align;
		xOffset = this.borderSize + this.marginLeft;
		yOffset = this.borderSize + this.marginTop + this.fontSize;
		
		this.textArray = this.text.split("\n");
		
		if(this.textArray.length > 1){
			for(var i=0;i<this.textArray.length;i++){
				this.ctx.fillText(this.textArray[i], this.x + xOffset, this.y + yOffset - this.height/2 + this.fontSize/3 + this.fontSize * i);// + this.fontSize
			}
		} else {
			this.ctx.fillText(this.textArray[0], this.x + xOffset, this.y + yOffset - this.fontSize/1.5);
		}
    } // end writeText()
	
	tTextBox.drawBackground = function() {
		ctx = this.context;
		ctx.globalAlpha = 1.0;
		startX = this.x + this.borderSize;
		startY = this.y + this.borderSize - this.height/2;
		fullWidth = this.width - this.borderSize;
		fullHeight = this.height - this.borderSize;
		imgWidth = this.backgroundImg.width;
		imgHeight = this.backgroundImg.height;
		img = this.backgroundImg;
		smallestWidth = fullWidth;
		smallestHeight = fullHeight;
		if(imgWidth < fullWidth) { smallestWidth = imgWidth; }
		if(imgHeight < fullHeight) { smallestHeight = imgHeight; }
		
		
		if(this.backStyle == STRETCH) {
			ctx.drawImage(this.img, startX, startY, this.width, this.height);
		} else if(this.backStyle == TILE) {
			repeatsY = Math.ceil(fullHeight / imgHeight);
			for(var j = 0; j < repeatsY; j ++) {
				if(imgWidth < fullWidth) { smallestWidth = imgWidth; }
				if(imgHeight > fullHeight - j * imgHeight) { smallestHeight = fullHeight - j * imgHeight; }
				repeatsX = Math.ceil(fullWidth / imgWidth);
				for(var i = 0; i < repeatsX; i ++) {
					if(imgWidth > fullWidth - i * imgWidth) { smallestWidth = fullWidth - i * imgWidth; }
					ctx.drawImage(img, 0, 0, smallestWidth, smallestHeight, startX + i * imgWidth, startY + j * imgHeight, smallestWidth, smallestHeight);
				} // end for
			} // end for
		} else if(this.backStyle == TILE_X) {
			repeats = Math.ceil(fullWidth / imgWidth);
			for(var i = 0; i < repeats; i ++) {
				if(imgWidth > fullWidth - i * imgWidth) { smallestWidth = fullWidth - i * imgWidth; }
				ctx.drawImage(img, 0, 0, smallestWidth, smallestHeight, startX + i * imgWidth, startY, smallestWidth, smallestHeight);
			} // end for
		} else if(this.backStyle == TILE_Y) {
			repeats = Math.ceil(fullHeight / imgHeight);
			for(var i = 0; i < repeats; i ++) {
				if(imgHeight > fullHeight - i * imgHeight) { smallestHeight = fullHeight - i * imgHeight; }
				ctx.drawImage(img, 0, 0, smallestWidth, smallestHeight, startX, startY + i * imgHeight, smallestWidth, smallestHeight);
			} // end for
		} else if(this.backStyle == NONE) {
			ctx.drawImage(this.backgroundImg, this.x - this.width/2, this.y - this.height/2, this.width, this.height);
		} // end if
	} // end drawBackground
	
	tTextBox.draw = function () {
	
		if(this.backImage != null) {
			this.drawBackground();
		} else {
			ctx = this.context;
			ctx.save();
			// Draw the background first.
			ctx.fillStyle = this.backColor;
			ctx.globalAlpha = this.backAlpha;
			ctx.fillRect(this.x - this.width/2, this.y - this.height/2, this.width, this.height);
			if(this.backImage != null) {
				this.drawBackground();
			} // end if
			
			// Borders next.
			ctx.strokeStyle = this.borderColor;
			ctx.lineWidth = this.borderSize;
			ctx.globalAlpha = this.borderAlpha;
			ctx.strokeRect(this.x - this.width/2, this.y - this.height/2, this.width, this.height);
			
			ctx.restore();
		}
		if(this.text != ""){
			this.writeText(this.text, this.align);
		}
		if(this.autoFit == true){
			this.fitText();
		}
    } // end draw function

    tTextBox.update = function () {
        this.x += this.dx;
        this.y += this.dy;
        this.checkBounds();
        if (this.visible) {
			this.draw();
        } // end if
    } // end update
	
	return tTextBox;
} // end DialogueBox

//variable holding key being pressed
var currentKey = null;
var keysDown = new Array(256);
var virtKeys = false;

//keyboard constants
K_A = 65;
K_B = 66;
K_C = 67;
K_D = 68;
K_E = 69;
K_F = 70;
K_G = 71;
K_H = 72;
K_I = 73;
K_J = 74;
K_K = 75;
K_L = 76;
K_M = 77;
K_N = 78;
K_O = 79;
K_P = 80;
K_Q = 81;
K_R = 82;
K_S = 83;
K_T = 84;
K_U = 85;
K_V = 86;
K_W = 87;
K_X = 88;
K_Y = 89;
K_Z = 90;
K_LEFT = 37;
K_RIGHT = 39;
K_UP = 38;
K_DOWN = 40;
K_SPACE = 32;
K_ESC = 27;
K_PGUP = 33;
K_PGDOWN = 34;
K_HOME = 36;
K_END = 35;
K_0 = 48;
K_1 = 49;
K_2 = 50;
K_3 = 51;
K_4 = 52;
K_5 = 53;
K_6 = 54;
K_7 = 55;
K_8 = 56;
K_9 = 57;


//Animation Constants
SINGLE_ROW = 1;
SINGLE_COLUMN = 2;
VARIABLE_LENGTH = 3;
PLAY_ONCE = 1;
PLAY_LOOP = 2;

//Boundary action constants
WRAP = 0;
BOUNCE = 1;
STOP = 3;
DIE = 4;
CONTINUE = 5;
SEMIBOUNCE = 6;

//Text Box Constants
STRETCH = 0; TILE = 1; TILE_X = 2; TILE_Y = 3; NONE = 4;
