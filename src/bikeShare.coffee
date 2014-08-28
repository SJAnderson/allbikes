#! /usr/local/bin/node
async = require 'async'
mongo = require 'mongodb'
utils = require './utils'

# constants
feeds = require './feeds.json'
config = require './config.json'

# set up server
{host, port} = config.mongo
server = new mongo.Server host, port, auto_reconnect: true
db = new mongo.Db 'BikeShare', server, journal: true

# open db
open = (next) ->
  db.open (err, db) ->
    return next err if err
    next null, db

# arrange URLs into array
prepareResources = (db, done) ->
  async.waterfall [
    (next) -> db.collection('feeds').find {}, next
    (data, next) -> data.toArray next
  ], (err, cities) ->
    urls = ({url, type} for {url, type} in cities)
    done err, urls

remapErrors = (station) ->
  {statusKey, statusValue, locked} = station
  switch locked
    when 'true'
      station.statusKey = config.statusKey.notInService
      station.statusValue = 'Not In Service'
    when 'false'
      station.statusKey = config.statusKey.inService
      station.statusValue = 'In Service'
  delete station.locked
  return station

remapLatLong = (station) ->
  properties = ['lat', 'longitude', 'latitude', 'long']
  coordinates = {}
  coordinates.latitude = parseFloat station.lat or station.latitude
  coordinates.longitude = parseFloat station.long or station.longitude
  (delete station[prop] if station[prop]) for prop in properties
  station.coordinates = coordinates
  station.id = coordinates.latitude + coordinates.latitude
  return station

remapProperty = (station, primary, secondary) ->
  if primary is 'name'
    station[primary] = station[primary] or station[secondary]
  else
    value = station[primary] or station[secondary]
    value = parseInt value or 0
    station[primary] = value
  delete station[secondary] if secondary
  return station

remapData = (station, done) ->
  station = remapErrors station
  station = remapLatLong station
  station = remapProperty station, 'availableBikes', 'nbBikes'
  station = remapProperty station, 'availableDocks', 'nbEmptyDocks'
  station = remapProperty station, 'name', 'stationName'
  station.totalDocks = station.availableDocks + station.availableBikes
  delete station[field] for field in utils.unused_fields
  done null, station

translateData = (stations, next) ->
  async.map stations, remapData, next

# DB update shortcut
update = (db, collection, query, update, next) ->
  collection = db.collection collection
  options = {safe: true, upsert: true}
  collection.update query, update, options, next

# update feeds collection
updateFeeds = (db, done) ->
  async.eachSeries feeds, ((feed, next) ->
    query = {id: feed.id}
    update db, 'feeds', query, feed, next
  ), done

updateFeeds = (db, done) ->
  async.eachSeries feeds, ((feed, next) ->
    query = {id: feed.id}
    update db, 'feeds', query, feed, next
  ), done

saveAllStations = (db, stations, done) ->
  async.eachSeries stations, ((station, next) ->
    query = {name: station.name}
    update db, 'stations', query, station, next
  ), done

getCities = (endpoints, next) ->
  async.concat endpoints, getCity, next

getCity = (endpoint, next) ->
  {url} = endpoint
  utils.get url, next

updateStations = (db, done) ->
  resources = []
  async.waterfall [
    (next) -> prepareResources db, next
    (endpoints, next) -> getCities endpoints, next
    (stations, next) -> translateData stations, next
    (stations, next) -> saveAllStations db, stations, next
  ], (err) ->
    done err

run = ->
  async.waterfall [
    (next) -> open next
    (db, next) ->
      async.series [
        (next) -> updateFeeds db, next
        (next) -> updateStations db, next
      ], (err) ->
        time = Date.now()
        log = {err, time}
        update db, 'logs', log, log, next

  ], (err) ->
    console.log "Error: #{err}" if err
run()

module.exports =
  allStations: (req, res) ->
    stations = db.collection 'stations'

    async.waterfall [
      (next) -> stations.find {}, next
      (results, next) -> results.toArray next
    ], (err, stations) ->
      return res.send 'Database error' if err
      res.send stations
