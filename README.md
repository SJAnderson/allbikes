allbikes API
========

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

# Goal
While every Bike Share program has a live JSON or XML feed, the data is presented differently thus making a universal bike share app hard to create. This project aims to convert the various data formats to a singular, easy-to-interpret format.

#Calls 

#### Implemented

```
/bikeshare/stations
```
**All Stations**
- returns a JSON array of all stations around the world

```
/bikeshare/city/:city_id
```
**Stations from a city**
- returns a JSON array of stations from a city. Reference the table above for `city_id`s, I used airport codes.

#### Planned

```
/bikeshare/stations/:closest/:lat/:long/:maxresults
```
**Closest stations**
- will return closest stations based on latitude and longitude paramaters

##### Examples coming soon. Contributions welcome.

