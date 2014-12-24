###
Greenhorn Cakefile
Written by Seth Bullock
sedabull@gmail.com

In order to build a single .js file from many
.coffee files, a file called src/.index.txt
indicates the order in which to concatenate
all src/*.coffee files into one large file
called src/Greenhorn.coffee. That one large
file is then feed to the coffeeScript compiler
which creates lib/Greenhorn.js. Afterwards,
the temporary file src/Greenhorn.coffee is removed.
To create lib/GreenhornStyle.css, src/style.less
is fed into lessc and the output is redirected.
###

{print} = require 'sys'
{spawn, exec} = require 'child_process'

concat = (callback) ->
    cmd =
        '(while read file; do cat src/$file; echo "\n\n"; done < src/.index.txt;) > src/Greenhorn.coffee'
    exec cmd, (error) ->
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

lessc = (callback) ->
    exec 'lessc src/style.less > lib/GreenhornStyle.css', (error) ->
        if error?
            console.log "exec error: #{error}"
        else
            callback?()

task 'build:all', 'Build lib/Greenhorn.js and lib/GreenhornStyle.css from src/', ->
    invoke 'build:style'
    invoke 'build:library'

task 'build:style', 'Build lib/GreenhornStyle.css from src/style.less', ->
    lessc ->
        console.log 'Built GreenhornStyle.css successfully'

task 'build:library', 'Build lib/Greenhorn.js from src/*.coffee', ->
    concat ->
        build ->
            clean ->
                console.log 'Built Greenhorn.js successfully'