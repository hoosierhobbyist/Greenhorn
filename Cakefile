fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

compile = (source, destination, callback) ->
    coffee = spawn 'coffee', ['-c', '-b', '-o', "#{destination}", "#{source}"]

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
        <script type='text/javascript' src='../lib/Greenhorn.js'></script>
        <script type='text/javascript' src='../lib/jquery-1.11.1.min.js'></script>
        <script type='text/javascript' src='#{source}'></script>
        <script type='text/javascript'>
          function loadSource(){
              $('#gh-footer').html('\\\\/ Checkout the source code below \\\\/');
              $('#gh-main').css('background', 'url(\"../images/gh_tile.png\") 0 0');

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
        <div id='content'>
          <h2 id='code' class='title'><strong>SOURCE CODE</strong></h2>
          <h3 class='title float-left'>Original CoffeeScript</h3>
          <h3 class='title float-right'>Compiled JavaScript</h3>
          <pre id='coffee' class='source float-left'></pre>
          <pre id='java' class='source float-right'></pre>
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

task 'build:examples', 'Build the example HTML5 pages', ->
    compile './examples/coffee', './examples/java', ->
        build 'examples', ->
            console.log 'Examples built successfully'
