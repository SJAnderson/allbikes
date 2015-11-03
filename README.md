# allbikes API [![NPM Version](http://img.shields.io/npm/v/allbikes.svg)](https://www.npmjs.org/package/allbikes) [![BuildStatus](http://img.shields.io/travis/SJAnderson/allbikes.svg)](https://travis-ci.org/SJAnderson/allbikes)

allbikes is an API that provides live station information for Bixi-built Bike Share programs around the world.

Stations currently supported and their respective API reference codes (city code).

| Bike Share | City | city_id | Active
| ----- | ------ |------ |
| Aspen WE-cycle | Aspen, CO | ASE | Yes
| Barclay's Cycle Hire | London, UK| LHR | Yes
| Bay Area Bike Share | San Francisco, CA | SFO | Yes
| Bike Chattanooga | Chattanooga, TN | CHA | Yes
| Capital Bike Share | Washington, D.C.| DCA | Yes
| Citi Bike | New York City, NY | JFK | Yes
| Citi Bike | Miami, FL| MIA | No
| CoGo | Columbus, OH | CMH | Yes
| Deco Bike | San Diego, CA| SAN | No
| Divvy | Chicago, IL | ORD | Yes
| Hubway | Boston, MA | BOS | Yes
| Melbourne Bike Share| Melbourne, Vic | MEL | Yes
| Montreal Bixi | Montreal, QC | YUL | Yes
| Nice Ride | Minneapolis, MN| MSP | Yes
| Ottawa Bixi | Ottawa, Ont| YOW | No
| Pronto Cycle Share | Seattle, WA| SEA | No
| Toronto Bixi |Toronto, Ont | YYZ | Yes

# goal
While every Bike Share program has a live JSON or XML feed, the data is presented differently thus making a universal bike share app difficult to create. This project aims to provide a easy-to-use solution for all bike-share data queries from around the world.

# implemented

### all stations
```
/bikeshare/stations
```
**Example**: http://www.sjanderson.org/bikeshare/stations

Returns a JSON array of all stations around the world.


### stations from a city
```
/bikeshare/city/:city_id
```
**Example**: http://www.sjanderson.org/bikeshare/city/SFO

Returns a JSON array of stations from a city. Reference the table above for `city_id`s, I used airport codes.

### all stations sorted from closest to farthest
```
/bikeshare/stations/:lat/:long/
```
**Example**: http://www.sjanderson.org/bikeshare/stations/37.42/-122.13

Returns a JSON array of all stations sorted by closest to farthest.

### stations from a city sorted from closest to farthest
```
/bikeshare/city/:city/:lat/:long/
```
Returns a JSON array of stations from a city sorted by closest to farthest.

**Example**: http://www.sjanderson.org/bikeshare/city/SFO/37.42/-122.13


## contact
Twitter: [@SJAndersonLA](twitter.com/sjandersonla)
