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
open = (next) -> db.open next

# arrange URLs into array
prepareResources = (db, done) ->
  async.waterfall [
    (next) -> db.collection('feeds').find {'active':{$ne:false}}, next
    (data, next) -> data.toArray next
  ], (err, cities) ->
    urls = ({url, id} for {url, id} in cities)
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
  properties = ['lat', 'longitude', 'latitude', 'long', 'la', 'la', 'Latitude', 'Longitude']
  latitude = parseFloat station.lat or station.latitude or station.Latitude or station.la
  longitude = parseFloat station.long or station.longitude or station.Longitude or station.lo
  station.location = {type: 'Point', coordinates: [longitude, latitude]}
  (delete station[prop] if station[prop]) for prop in properties
  return station

remapProperty = (station, primary, secondary) ->
  a = 0
  while a < secondary.length
    if station[secondary[a]]
      if primary is 'name'
        station[primary] = station[secondary[a]]
      else
        station[primary] = parseInt station[secondary[a]] or 0, 10
        delete station[secondary[a]]
      break
    a++
  return station

remapData = (station, done) ->
  station = remapErrors station
  station = remapLatLong station
  station = remapProperty station, 'availableBikes', ['nbBikes','Bikes','ba']
  station = remapProperty station, 'availableDocks', ['nbEmptyDocks','Dockings','da']
  station = remapProperty station, 'name', ['name','stationName','s','Address']
  station.lastUpdated = Date.now()
  station.totalDocks = station.availableDocks + station.availableBikes
  delete station[field] for field in utils.unused_fields
  done null, station

translateData = (stations, next) ->
  async.map stations, remapData, next

# DB update shortcut
update = (db, collection, query, update, next) ->
  collection = db.collection collection
  collection.ensureIndex {location: '2dsphere'}, (err) ->
    options = {safe: true, upsert: true}
    collection.update query, update, options, next

# update feeds collection
updateFeeds = (db, done) ->
  async.eachSeries feeds, ((feed, next) ->
    query = {id: feed.id}
    update db, 'feeds', query, feed, next
  ), done

updateFeeds = (done) ->
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
  utils.get endpoint, next

updateStations = (db, done) ->
  async.waterfall [
    (next) -> prepareResources db, next
    (endpoints, next) -> getCities endpoints, next
    (stations, next) -> translateData stations, next
    (stations, next) -> saveAllStations db, stations, next
  ], (err) ->
    done err

listenToStations = (done) ->
  async.forever (
    (next) ->
      updateStations db, (err) ->
        time = Date.now()
        log = {err, time}
        update db, 'logs', log, log, (err, results) ->
          return next err if err
          console.log "Stations updated at #{Date.now()}"
          pingAgain = ->
            next err
          setTimeout pingAgain, 300000
  ), done

updateData = (done) ->
  async.series [
    (next) -> updateFeeds next
    (next) -> listenToStations next
  ], done

run = ->
  async.waterfall [
    (next) -> open next
    (next) -> updateData next
  ], (err) ->
    console.log "Error #{err}, stopped updating stations"
run()

filterCity = (stations, city, next) ->
  return next null, stations unless city
  cities = (feed.id.toUpperCase() for feed in feeds)
  city = city.toUpperCase()
  if city in cities
    stations = stations.filter (station) ->
      station.city_id is city
    next null, stations
  else
    err = "City ID not recognized. Valid IDs: #{cities.join ', '}."
    err += " Documentation: https://github.com/SJAnderson/allbikes."
    return next err

addDistance = (stations, coords, next) ->
  {lat, long} = coords
  for station in stations
    {coordinates} = station.location
    station_loc = {lat: coordinates[1], long:coordinates[0]}
    user_loc = {lat: lat, long: long}
    station.distance = utils.calcDistance user_loc, station_loc
  next null, stations

module.exports =
  allStations: (req, res) ->
    stations = db.collection 'stations'

    async.waterfall [
      (next) -> stations.find {}, next
      (results, next) -> results.toArray next
    ], (err, stations) ->
      return res.send 'Database error' if err
      res.send stations

  cityStations: (req, res) ->
    cities = (feed.id.toUpperCase() for feed in feeds)
    city = req.params.city.toUpperCase()
    if city in cities
      stations = db.collection 'stations'
      async.waterfall [
        (next) -> stations.find {city_id: city}, next
        (results, next) -> results.toArray next
      ], (err, stations) ->
        return res.send 'Database error' if err
        res.send stations
    else
      err = "City ID not recognized. Valid IDs: #{cities.join ', '}."
      err += " Documentation: https://github.com/SJAnderson/allbikes."
      res.send {error: err}

  closestStations: (req, res) ->
    {city, lat, long} = req.params
    [lat, long] = [parseFloat(lat), parseFloat(long)]
    stations = db.collection 'stations'
    coord = {type: "Point", coordinates: [long, lat]}
    query = {location: {$near: {$geometry: coord}}}
    async.waterfall [
      (next) -> stations.find query, next
      (results, next) -> results.toArray next
      (stations, next) -> addDistance stations, {lat, long}, next
      (stations, next) -> filterCity stations, city, next
    ], (err, stations) ->
      return res.send {error: "Database error - #{err}"} if err
      res.send stations
