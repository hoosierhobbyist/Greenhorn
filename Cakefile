fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

concat = (callback) ->
    exec '(while read file; do cat ./src/$file; echo "\n\n"; done < ./src/.index.txt;) > ./build/Greenhorn.coffee', (error) ->
        if error?
            console.log "exec error: #{error}"
        else
            callback?()

build = (callback) ->
    coffee = spawn 'coffee', ['-c', '-o', 'lib', 'build']
    
    coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
        print data.toString()
    coffee.on 'exit', (code) ->
        callback?() if code is 0

clean = (callback) ->
    exec 'rm ./lib/* ./build/*', (error) ->
        if error?
            console.log "exec error: #{error}"
        else
            console.log callback?()

task 'build:library', 'Build lib/Greenhorn.js from src/', ->
    concat ->
        build(-> 'build complete')

task 'clean', 'Clean the build/ and lib/ directories', ->
    clean(-> 'cleaning complete')
