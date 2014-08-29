// Generated by CoffeeScript 1.7.1
(function() {
  var action, app, bikeShare, bodyParser, endpoints, express, middleware, morgan, point, utils, ware, _i, _len;

  bodyParser = require('body-parser');

  express = require('express');

  morgan = require('morgan');

  bikeShare = require('./lib/bikeShare.js');

  utils = require('./lib/utils.js');

  endpoints = {
    '/bikeshare/stations': function(req, res) {
      return bikeShare.allStations(req, res);
    },
    '/bikeshare/city/:city': function(req, res) {
      return bikeShare.cityStations(req, res);
    }
  };

  middleware = [morgan('dev'), bodyParser.json(), utils.allowCrossDomain, express["static"]("" + __dirname + "/public")];

  app = express();

  for (point in endpoints) {
    action = endpoints[point];
    app.get(point, action);
  }

  for (_i = 0, _len = middleware.length; _i < _len; _i++) {
    ware = middleware[_i];
    app.use(ware);
  }

  app.listen(8080);

  console.log('server running');

}).call(this);
