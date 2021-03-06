// Generated by CoffeeScript 1.7.1
(function() {
  var addDistance, async, config, db, feeds, filterCity, getCities, getCity, host, listenToStations, mongo, open, port, prepareResources, remapData, remapErrors, remapLatLong, remapProperty, run, saveAllStations, server, translateData, update, updateData, updateFeeds, updateStations, utils, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  async = require('async');

  mongo = require('mongodb');

  utils = require('./utils');

  feeds = require('./feeds.json');

  config = require('./config.json');

  _ref = config.mongo, host = _ref.host, port = _ref.port;

  server = new mongo.Server(host, port, {
    auto_reconnect: true
  });

  db = new mongo.Db('BikeShare', server, {
    journal: true
  });

  open = function(next) {
    return db.open(next);
  };

  prepareResources = function(db, done) {
    return async.waterfall([
      function(next) {
        return db.collection('feeds').find({}, next);
      }, function(data, next) {
        return data.toArray(next);
      }
    ], function(err, cities) {
      var id, url, urls;
      urls = (function() {
        var _i, _len, _ref1, _results;
        _results = [];
        for (_i = 0, _len = cities.length; _i < _len; _i++) {
          _ref1 = cities[_i], url = _ref1.url, id = _ref1.id;
          _results.push({
            url: url,
            id: id
          });
        }
        return _results;
      })();
      return done(err, urls);
    });
  };

  remapErrors = function(station) {
    var locked, statusKey, statusValue;
    statusKey = station.statusKey, statusValue = station.statusValue, locked = station.locked;
    switch (locked) {
      case 'true':
        station.statusKey = config.statusKey.notInService;
        station.statusValue = 'Not In Service';
        break;
      case 'false':
        station.statusKey = config.statusKey.inService;
        station.statusValue = 'In Service';
    }
    delete station.locked;
    return station;
  };

  remapLatLong = function(station) {
    var latitude, longitude, prop, properties, _i, _len;
    properties = ['lat', 'longitude', 'latitude', 'long'];
    latitude = parseFloat(station.lat || station.latitude);
    longitude = parseFloat(station.long || station.longitude);
    station.location = {
      type: 'Point',
      coordinates: [longitude, latitude]
    };
    for (_i = 0, _len = properties.length; _i < _len; _i++) {
      prop = properties[_i];
      if (station[prop]) {
        delete station[prop];
      }
    }
    return station;
  };

  remapProperty = function(station, primary, secondary) {
    var value;
    if (primary === 'name') {
      station[primary] = station[primary] || station[secondary];
    } else {
      value = station[primary] || station[secondary];
      value = parseInt(value || 0);
      station[primary] = value;
    }
    if (secondary) {
      delete station[secondary];
    }
    return station;
  };

  remapData = function(station, done) {
    var field, _i, _len, _ref1;
    station = remapErrors(station);
    station = remapLatLong(station);
    station = remapProperty(station, 'availableBikes', 'nbBikes');
    station = remapProperty(station, 'availableDocks', 'nbEmptyDocks');
    station = remapProperty(station, 'name', 'stationName');
    station.lastUpdated = Date.now();
    station.totalDocks = station.availableDocks + station.availableBikes;
    _ref1 = utils.unused_fields;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      field = _ref1[_i];
      delete station[field];
    }
    return done(null, station);
  };

  translateData = function(stations, next) {
    return async.map(stations, remapData, next);
  };

  update = function(db, collection, query, update, next) {
    collection = db.collection(collection);
    return collection.ensureIndex({
      location: '2dsphere'
    }, function(err) {
      var options;
      options = {
        safe: true,
        upsert: true
      };
      return collection.update(query, update, options, next);
    });
  };

  updateFeeds = function(db, done) {
    return async.eachSeries(feeds, (function(feed, next) {
      var query;
      query = {
        id: feed.id
      };
      return update(db, 'feeds', query, feed, next);
    }), done);
  };

  updateFeeds = function(done) {
    return async.eachSeries(feeds, (function(feed, next) {
      var query;
      query = {
        id: feed.id
      };
      return update(db, 'feeds', query, feed, next);
    }), done);
  };

  saveAllStations = function(db, stations, done) {
    return async.eachSeries(stations, (function(station, next) {
      var query;
      query = {
        name: station.name
      };
      return update(db, 'stations', query, station, next);
    }), done);
  };

  getCities = function(endpoints, next) {
    return async.concat(endpoints, getCity, next);
  };

  getCity = function(endpoint, next) {
    return utils.get(endpoint, next);
  };

  updateStations = function(db, done) {
    return async.waterfall([
      function(next) {
        return prepareResources(db, next);
      }, function(endpoints, next) {
        return getCities(endpoints, next);
      }, function(stations, next) {
        return translateData(stations, next);
      }, function(stations, next) {
        return saveAllStations(db, stations, next);
      }
    ], function(err) {
      return done(err);
    });
  };

  listenToStations = function(done) {
    return async.forever((function(next) {
      return updateStations(db, function(err) {
        var log, time;
        time = Date.now();
        log = {
          err: err,
          time: time
        };
        return update(db, 'logs', log, log, function(err, results) {
          var pingAgain;
          if (err) {
            return next(err);
          }
          console.log("Stations updated at " + (Date.now()));
          pingAgain = function() {
            return next(err);
          };
          return setTimeout(pingAgain, 300000);
        });
      });
    }), done);
  };

  updateData = function(done) {
    return async.series([
      function(next) {
        return updateFeeds(next);
      }, function(next) {
        return listenToStations(next);
      }
    ], done);
  };

  run = function() {
    return async.waterfall([
      function(next) {
        return open(next);
      }, function(next) {
        return updateData(next);
      }
    ], function(err) {
      return console.log("Error " + err + ", stopped updating stations");
    });
  };

  run();

  filterCity = function(stations, city, next) {
    var cities, err, feed;
    if (!city) {
      return next(null, stations);
    }
    cities = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = feeds.length; _i < _len; _i++) {
        feed = feeds[_i];
        _results.push(feed.id.toUpperCase());
      }
      return _results;
    })();
    city = city.toUpperCase();
    if (__indexOf.call(cities, city) >= 0) {
      stations = stations.filter(function(station) {
        return station.city_id === city;
      });
      return next(null, stations);
    } else {
      err = "City ID not recognized. Valid IDs: " + (cities.join(', ')) + ".";
      err += " Documentation: https://github.com/SJAnderson/allbikes.";
      return next(err);
    }
  };

  addDistance = function(stations, coords, next) {
    var coordinates, lat, long, station, station_loc, user_loc, _i, _len;
    lat = coords.lat, long = coords.long;
    for (_i = 0, _len = stations.length; _i < _len; _i++) {
      station = stations[_i];
      coordinates = station.location.coordinates;
      station_loc = {
        lat: coordinates[1],
        long: coordinates[0]
      };
      user_loc = {
        lat: lat,
        long: long
      };
      station.distance = utils.calcDistance(user_loc, station_loc);
    }
    return next(null, stations);
  };

  module.exports = {
    allStations: function(req, res) {
      var stations;
      stations = db.collection('stations');
      return async.waterfall([
        function(next) {
          return stations.find({}, next);
        }, function(results, next) {
          return results.toArray(next);
        }
      ], function(err, stations) {
        if (err) {
          return res.send('Database error');
        }
        return res.send(stations);
      });
    },
    cityStations: function(req, res) {
      var cities, city, err, feed, stations;
      cities = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = feeds.length; _i < _len; _i++) {
          feed = feeds[_i];
          _results.push(feed.id.toUpperCase());
        }
        return _results;
      })();
      city = req.params.city.toUpperCase();
      if (__indexOf.call(cities, city) >= 0) {
        stations = db.collection('stations');
        return async.waterfall([
          function(next) {
            return stations.find({
              city_id: city
            }, next);
          }, function(results, next) {
            return results.toArray(next);
          }
        ], function(err, stations) {
          if (err) {
            return res.send('Database error');
          }
          return res.send(stations);
        });
      } else {
        err = "City ID not recognized. Valid IDs: " + (cities.join(', ')) + ".";
        err += " Documentation: https://github.com/SJAnderson/allbikes.";
        return res.send({
          error: err
        });
      }
    },
    closestStations: function(req, res) {
      var city, coord, lat, long, query, stations, _ref1, _ref2;
      _ref1 = req.params, city = _ref1.city, lat = _ref1.lat, long = _ref1.long;
      _ref2 = [parseFloat(lat), parseFloat(long)], lat = _ref2[0], long = _ref2[1];
      stations = db.collection('stations');
      coord = {
        type: "Point",
        coordinates: [long, lat]
      };
      query = {
        location: {
          $near: {
            $geometry: coord
          }
        }
      };
      return async.waterfall([
        function(next) {
          return stations.find(query, next);
        }, function(results, next) {
          return results.toArray(next);
        }, function(stations, next) {
          return addDistance(stations, {
            lat: lat,
            long: long
          }, next);
        }, function(stations, next) {
          return filterCity(stations, city, next);
        }
      ], function(err, stations) {
        if (err) {
          return res.send({
            error: "Database error - " + err
          });
        }
        return res.send(stations);
      });
    }
  };

}).call(this);
