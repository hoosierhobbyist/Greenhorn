fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

compile = (source, destination, callback) ->
    coffee = spawn 'coffee', ['-c', '-o', "#{destination}", "#{source}"]

    coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
        print data.toString()
    coffee.on 'exit', (code) ->
        callback?() if code is 0

makeHTML = (source) ->
    """
    <!DOCTYPE html>
    <html lang='en-US'>
      <head>
        <meta charset='UTF-8'>
        <meta name='author' content='Seth David Bullock'>
        <meta name='description' content='Greenhorn Gaming Engine Example'>
        <meta name='keywords' content='Greenhorn, Gaming, CoffeeScript, HTML5, canvas'>
        <link rel='stylesheet' href='./exampleStyle.css'>
        <link rel='stylesheet' href='../lib/GreenhornStyle.css'>
        <script type='text/javascript' src='../lib/Greenhorn.js'></script>
        <script type='text/javascript' src='../lib/jquery-1.11.1.min.js'></script>
        <script type='text/javascript' src='#{source}'></script>
        <script type='text/javascript'>
          function loadSource(){
              $('#gh-footer').html('\\\\/ Checkout the source code below \\\\/');

              $.get('#{source.replace('java', 'coffee').replace('.js', '.coffee')}', function(data){
                  while(data.match(/[<>]/)){
                      data = data.replace('<', '&lt');
                      data = data.replace('>', '&gt');
                  }//end while

                  $('#coffee').html('\\n' + data);
              }, 'text');//end get coffeescript source

              $.get('#{source}', function(data){
                  while(data.match(/[<>]/)){
                      data = data.replace('<', '&lt');
                      data = data.replace('>', '&gt');
                  }//end while

                  $('#java').html('\\n' + data);
              }, 'text');//end get javascript source
          }//end loadSource
        </script>
      </head>
      <body onload='loadSource()'>
        <div class='gh'>
          <h1 id='desc' class='title'><strong>GREENHORN GAMING: EXAMPLES</strong></h1>
          <h2 id='author' class='title'><em>by Seth David Bullock</em></h2>
        </div>
        <div class='code float-left'>
          <h3 class='title'>Original CoffeeScript</h3>
          <pre id='coffee' class='source'></pre>
        </div>
        <div class='code float-right'>
          <h3 class='title'>Compiled JavaScript</h3>
          <pre id='java' class='source'></pre>
        </div>
      </body>
    </html>
    """

build = (what, callback) ->
    fs.readdir "./#{what}/java", (err, files) ->
        if err
            console.log err
        else
            for file in files
                fs.writeFileSync("./#{what}/#{file.replace('.js', '.html')}", makeHTML("./java/#{file}"))
            callback?()

clean = (what, callback) ->
    exec "rm ./#{what}/*.html; rm ./#{what}/java/*.js", (err) ->
        if err?
            console.log "exec error: #{err}"
        else
            callback?()

task 'build:examples', 'Build the example HTML5 pages', ->
    compile './examples/coffee', './examples/java', ->
        build 'examples', ->
            console.log 'Examples built successfully'

task 'clean:examples', 'Remove the HTML and JavaScript from ./examples', ->
    clean 'examples', ->
        console.log 'Examples cleaned successfully'