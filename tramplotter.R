#k<-load("queries_58_20170529.Rda")
library(tidyverse)

loadOne <- function(fl)
{
  load(fl)
  return(queries58)
}

qq <- list.files(pattern="queries_58_[[:digit:]]+.Rda", path="Data", full.names=TRUE)

alldat <- bind_rows(lapply(qq, loadOne))


cleanDF <- function(tram.df, sampleinterval=5, returnthresh=30)
{
  ## Takes a df with one stop and produces arrival times
  ## Fix the times. There's probably something fancier that can be done with lubridate etc. And I'm not 
  ## entirely sure what will happen with daylight saving, which has just kicked in. Daylight saving
  ## is the reason for the +1[10]00 part.
  tram.df <- mutate(tram.df, Predicted=as.numeric(gsub("/Date\\(([[:digit:]]+)\\+1[10]00\\)/", "\\1", PredictedArrivalDateTime))/1000,
                    Predicted=as.POSIXct(Predicted, origin="1970-01-01"),
                    Arrival=gsub("NOW", "0", Arrival))
  ## Discard those larger than our sampling
  tram.df <- subset(tram.df, as.numeric(Arrival) < (sampleinterval+1))
  
  returnthreshseconds <- 3600*returnthresh/60
  tram.nest <- nest(group_by_(tram.df, "VehicleNo"))
  tram.nest <- mutate(tram.nest, AtDest=map(data, ~c(diff(.x$Predicted), returnthreshseconds)),
                      Arrival=map2(data, AtDest, ~.x$Predicted[.y>=returnthreshseconds]))
  return(tram.nest)
}

flagstaff <- cleanDF(subset(alldat, StopID=="3064"))

flagstaff <- unnest(flagstaff, Arrival, .drop=TRUE)

## Now add columns for date and time (Time is given a dummy day)
flagstaff <- mutate(flagstaff, 
                    Date=as.Date(Arrival, tz ="Australia/Melbourne") 
)
TOD <- as.POSIXlt(flagstaff$Arrival)
TOD$mday <- TOD$mday[1]
TOD$mon <- TOD$mon[1]

flagstaff <- mutate(flagstaff, TimeOfDay = as.POSIXct(TOD))

ff <- subset(flagstaff, TimeOfDay > as.POSIXct("2017-05-24 08:30:00 AEST") & TimeOfDay < as.POSIXct("2017-05-24 11:00:00 AEST"))
#ggplot(ff, aes(x=TimeOfDay, y=Date, colour=factor(VehicleNo))) + geom_point()

ggplot(ff, aes(x=TimeOfDay, y=Date)) + geom_jitter(height=0.1) + ggtitle("Number 58 arrival at Flagstaff")
#ggsave("Flagstaff58.pdf")

ff <- arrange(ff, Arrival)
ffg <- nest(group_by(ff, Date))
ffg <- mutate(ffg, delta=map(data, ~diff(.x$Arrival)))
deltas <- data.frame(deltaT=as.numeric(do.call(c, ffg$delta)/60))

ggplot(deltas, aes(x=deltaT)) + geom_freqpoly() + ggtitle("Number 58 arrival interval - 0900-1100, 24-29 May")
#ggsave("arrivalinterval.pdf")
