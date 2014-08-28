# feeds = require './feeds.json'
bodyParser = require 'body-parser'
express = require 'express'
morgan = require 'morgan'

# utilities
bikeShare = require './lib/bikeShare.js'
utils = require './lib/utils.js'

# endpoints
endpoints =
  '/bikeshare/stations': (req, res) ->
    bikeShare.allStations req, res

# middleware
middleware = [
  morgan 'dev'
  bodyParser.json()
  utils.allowCrossDomain
  express.static "#{__dirname}/public"
]

app = express()
app.get point, action for point, action of endpoints
app.use ware for ware in middleware
app.listen 8080
console.log 'server running'
