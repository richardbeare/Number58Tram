# Route 58

The number 58 tram route was introduced on 1st May 2017 by merging routes 55 and 8. I was a regular
user of the 55 tram between Flagstaff station and the Royal Children's Hospital. After the
change the tram arrival appeared more clustered, with waits a lot longer than the scheduled
5 to 8 minutes, and a long wait usually followed by several trams arriving in quick succession.

Unfortunately I didn't think to attempt logging data prior to the change, but thought it might be
fun to try afterwards, just to see how bad things really are.

The data in this repository has been scraped from the TramTracker service for a few months, with
queries sent every 5 minutes. Only a few stops of interest are queried.

The data is in reasonably raw form, and thus offers some useful training in preprocessing and tidying,
as well as a visualization challenge.

## Data outline

The scaping is performed in _tramtracker.R_. I query 5 stops at 5 minute intervals. The tracker data
includes a tram ID (_VehicalNo_) and predicted arrival date/time.

Each Rda file (in the Data directory) contains data from one day.

A simple sample script I used for sanity checking and basic plotting is __. It does some
culling of redundant information (for example keeping only the shortest prediction of arrival time
for each vehicle at each stop), but there are probably better ways of doing this.