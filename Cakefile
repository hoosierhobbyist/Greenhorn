fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

compile = (source, destination, callback) ->
    coffee = spawn 'coffee', [-c, -o, "#{destination}", "#{source}"]
    
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
        <script type='text/javascript' src='../lib/Greenhorn.js'>
        <script type='text/javascript' src='#{source}'>
      </head>
      <body onload='init()'>
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