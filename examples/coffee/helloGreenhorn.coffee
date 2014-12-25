###
helloGreenhorn.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#name the document
document.title = 'Hello Greenhorn!'

#bring in needed classes
{env, Greenhorn, TextSprite} = gh

#setup the environment
env.ENGINE.rightHeader = 'BUTTONS'
env.ENGINE.leftHeader = 'INFORMATION'

#define helloWorld scripts
scripts =
    helloC:
        '''
        /*helloWorld.c*/
        #include <stdio.h>
        int main(){
            printf("Hello World!\\n");
            return(0);
        }/*end main*/
        '''
    helloCPP:
        '''
        //helloWorld.cpp
        #include <iostream>
        int main(){
            std::cout << "Hello World!" << endl;
            return 0;
        }//end main
        '''
    helloPHP:
        '''
        <!-- helloWorld.php -->
        <html>
          <body>
            <?php echo 'Hello World!'; ?>
          </body>
        </html>
        '''
    helloJava:
        '''
        //HelloWorld.java
        public class HelloWorld{
            public static void main(String[] args){
                System.out.println("Hello World!");
            }//end main
        }//end HelloWorld class
        '''
    helloRuby:
        '''
        #helloWorld.rb
        puts "Hello World!"
        '''
    helloPython:
        '''
        #helloWorld.py
        print "Hello World!"
        '''
    helloJavaScript:
        '''
        //helloWorld.js
        alert("Hello World!");
        '''
    helloCoffeeScript:
        '''
        #helloWorld.coffee
        console.log 'Hello World!'
        '''

#declare global
helloWorld = null

#define init() to setup the document
gh.init = ->
    #start the engine
    Greenhorn.start()
    
    #initialize TextSprite
    helloWorld = new TextSprite
        dx: 50
        dy: 50
        text: scripts.helloC
        fontSize: 16
        fontName: 'monospace'
        boundAction: 'BOUNCE'
    
    #add buttons
    Greenhorn.addButton label: 'C', onclick: ->
        helloWorld.set 'text', scripts.helloC
    Greenhorn.addButton label: 'CPP', onclick: ->
        helloWorld.set 'text', scripts.helloCPP
    Greenhorn.addButton label: 'PHP', onclick: ->
        helloWorld.set 'text', scripts.helloPHP
    Greenhorn.addButton label: 'Java', onclick: ->
        helloWorld.set 'text', scripts.helloJava
    Greenhorn.addButton label: 'Ruby', onclick: ->
        helloWorld.set 'text', scripts.helloRuby
    Greenhorn.addButton label: 'Python', onclick: ->
        helloWorld.set 'text', scripts.helloPython
    Greenhorn.addButton label: 'JavaScript', onclick: ->
        helloWorld.set 'text', scripts.helloJavaScript
    Greenhorn.addButton label: 'CoffeeScript', onclick: ->
        helloWorld.set 'text', scripts.helloCoffeeScript
    
    #add information
    $('#gh-left-panel').append(
        '''
        <h4 class='gh-sub-h'>Instructions</h4>
        <p class='gh-p'>
        Use the buttons on the right-hand side to
        display a few example "Hello World!" programs.
        </p>
        <h4 class='gh-sub-h'>Discussion</h4>
        <p class='gh-p'>
        The TextSprite class is a direct extention of the
        Sprite class, meaning that anything a Sprite can
        do, the TextSprite can also do. The only difference
        is that string data, instead of image data, is
        what's being displayed. As you can see by switching
        between a few examples, the TextSprite automatically
        resizes itself whenever it's content changes.
        </p>
        ''')

#define update() to be called once per frame
gh.update = ->
    #highlight current language
    current = helloWorld.get 'text'
    $('.gh-button').each ->
        if scripts["hello#{@innerHTML}"] is current
            @style.color = '#006400'
        else
            @style.color = '#C0C0C0'