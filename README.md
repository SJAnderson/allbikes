# allbikes API
![](http://img.shields.io/npm/v/allbikes.svg)


allbikes is an API that provides live station information for Bixi-built Bike Share programs around the world. 

Stations currently supported and their respective API reference codes (city code).

| Bike Share | City | city_id |
| ----- | ------ |------ |
| Aspen WE-cycle| Aspen, CO | ASE |
| Barclay's Cycle Hire| London, UK| LHR |
| Bay Area Bike Share| San Francisco, CA | SFO |
| Bike Chattanooga | Chattanooga, Tennessee | CHA |
| Capital Bike Share| Washington DC| DCA |
| Citi Bike| New York City, NY | JFK |
| CoGo | Columbus, Ohio | CMH |
| Divvy | Chicago, Illinois | ORD |
| Hubway | Boston, Massachusetts | BOS |
| Melbourne Bike Share| Melbourne, Victoria | MEL |
| Montreal Bixi | Montreal | YUL |
| Nice Ride| Minneapolis, Minnesota| MSP |
| Ottawa Bixi| Ottawa, Ontario| YOW |
| Toronto Bixi|Toronto, Ontraio | YYZ |

# goal
While every Bike Share program has a live JSON or XML feed, the data is presented differently thus making a universal bike share app difficult to create. This project aims to provide a easy-to-use solution for all bike-share data queries from around the world.

# implemented

### all stations
```
/bikeshare/stations
```
Returns a JSON array of all stations around the world.
**Example**: http://www.sjanderson.org/bikeshare/stations


### stations from a city
```
/bikeshare/city/:city_id
```
Returns a JSON array of stations from a city. Reference the table above for `city_id`s, I used airport codes.
**Example**: http://www.sjanderson.org/bikeshare/city/SFO

# planned

### closest stations
`/bikeshare/stations/:closest/:lat/:long/:maxresults`
Will return closest stations based on latitude and longitude paramaters.

## contact
Twitter: [@SJAndersonLA](twitter.com/sjandersonla)


