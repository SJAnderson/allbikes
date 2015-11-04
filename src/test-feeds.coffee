async = require('async')
assert = require('assert')
feeds = require('../lib/feeds.json')
utils = require('../lib/utils.js')
require('it-each') testPerIteration: true
describe 'Test Active Feeds', ->
  it 'should have feeds', (done) ->
    assert true, ! !feeds.length
    done()
    return
  it.each feeds, 'Testing feed for %s', [ 'id' ], (city, next) ->
    if(typeof city.active isnt 'undefined' && city.active is false)
        assert true, true, 'Skipping Not Active'
        return next()
    else
      utils.get city, (err, result) ->
        if !result
          assert.fail err, 'result'
        else
          assert true, !!result
        next()
    return
  return
return
