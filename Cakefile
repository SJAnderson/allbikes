{exec} = require 'child_process'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log 'Coffee compiled to JS...'

    exec 'rm -f lib/app.js', (err, stdout, stderr) ->
      throw err if err
      console.log 'app.js removed from lib...'

    exec 'rm -f lib/test.js', (err, stdout, stderr) ->
      throw err if err
      console.log 'test.js removed from lib...'

  exec 'coffee --compile --output ./ src/app.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log 'app.js placed in lib...'

  exec 'coffee --compile --output test/ src/test.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log 'test.js placed in lib...'

  exec 'cson2json src/config.cson > lib/config.json', (err, stdout, stderr) ->
    throw err if err
    console.log 'config compiled to json...'

  exec 'cson2json src/feeds.cson > lib/feeds.json', (err, stdout, stderr) ->
    throw err if err
    console.log 'feeds compiled to json...'
