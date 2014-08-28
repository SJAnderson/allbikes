{exec} = require 'child_process'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

    exec 'rm -f lib/app.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

  exec 'coffee --compile --output ./ src/app.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

  exec 'cson2json src/config.cson > lib/config.json', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

  exec 'cson2json src/feeds.cson > lib/feeds.json', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
