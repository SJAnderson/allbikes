# modules
async = require 'async'
request = require 'request'
xml2js = require 'xml2js'

# tools
parser = new xml2js.Parser {explicitArray: false}


module.exports =
  allowCrossDomain: (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type'

    if 'OPTIONS' is req.method
      res.send 200
    else
      next()

  get: (url, next) ->
    async.waterfall [
      (next) -> request {method: 'GET', url: url}, next
      (resp, body, next) ->
        return next 'resp is undefined. uh oh.' unless resp

        # check for bad status code
        if resp.statusCode < 200 or resp.statusCode > 302
          return next "bad #{body}"

        parseJSON = ->
          try
            body = JSON.parse body
            {stationBeanList} = body
            body = stationBeanList if stationBeanList
            return next null, body
          catch err
            return next err

        parseXML = ->
          parser.parseString body, (err, result) ->
            body = result.stations.station
            next null, body

        switch resp.headers['content-type']
          when 'application/json', 'application/json; charset=utf-8'
            parseJSON()

          when 'text/html; charset=UTF-8', 'text/html'
            parseJSON()

          when 'application/xml', 'text/xml'
            parseXML()

          when 'text/javascript; charset=utf-8'
            body = body.replace /\\/g, ''
            parseJSON()

          else
            next "Unknown content type | #{url}"
    ], (err, body) ->
      next err, body

  unused_fields: [
    'altitude'
    'city'
    'installDate'
    'installed'
    'landMark'
    'lastCommunicationTime'
    'lastCommWithServer'
    'latestUpdateTime'
    'location'
    'postalCode'
    'public'
    'removalDate'
    'stAddress1'
    'stAddress2'
    'testStation'
    'terminalName'
    'temporary'
  ]

