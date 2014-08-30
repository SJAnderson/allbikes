APIeasy = require "api-easy"
async = require 'async'
assert = require "assert"
feeds = require "../lib/feeds.json"
station = APIeasy.describe "/bikeshare/stations"

codes = (city.id for city in feeds)

station.use "localhost", 8080
  .setHeader "Content-Type", "application/json"
  .followRedirect(false)
  .discuss 'Testing station'
  .get '/bikeshare/stations'
    .expect 200
  .undiscuss()
  .discuss 'Test bad endpoint'
  .get '/bikeshare/spiderman'
    .expect 404

for code in codes
  station.discuss "testing city #{code}"
    .get "/bikeshare/city/#{code}"
    .expect 200
    .undiscuss()

station.export module
