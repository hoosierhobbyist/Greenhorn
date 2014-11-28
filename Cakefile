fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

concat = (callback) ->
    exec '(while read file; do cat src/$file; echo "\n\n"; done < src/.index.txt;) > src/Greenhorn.coffee', (error) ->
        if error?
            console.log "exec error: #{error}"
        else
            callback?()

build = (callback) ->
    coffee = spawn 'coffee', ['-c', '-o', 'lib/', 'src/Greenhorn.coffee']
    
    coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
        print data.toString()
    coffee.on 'exit', (code) ->
        callback?() if code is 0

clean = (callback) ->
    exec 'rm src/Greenhorn.coffee', (error) ->
        if error?
            console.log "exec error: #{error}"
        else
            callback?()

task 'build:library', 'Build lib/Greenhorn.js from src/', ->
    concat ->
        build ->
            clean ->
                console.log 'successfully built library'
