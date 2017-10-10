library(httr)
library(jsonlite)
library(tidyverse)
stopID <- c(FlinderSt="3058", Flagstaff="3064", QueensburySt="3068", RCH="3074", Zoo="2255")

tramtrackerURL <- "http://www.yarratrams.com.au/base/tramTrackerController/TramInfoAjaxRequest"

getStopData <- function(the.stop, Route=NULL, URL=tramtrackerURL)
{
  if (is.null(Route)) {
    B <- list(StopID=the.stop, LowFloorOnly="false")
  } else {
    B <- list(StopID=the.stop, Route=Route, LowFloorOnly="false")
  }
  track <- POST(URL, body=B)
  tt <- fromJSON(content(track, type="text", encoding = "UTF-8"))

  if (is.null(tt$errorMessage)) {
    ## Disruption message is a data frame - recently added - get rid of it
    arrivals <- map(tt$TramTrackerResponse$ArrivalsPages, ~select(.x, -DisruptionMessage))
    res <- dplyr::bind_rows(arrivals)
    res$StopID <- the.stop
    return(res)
  } else {
    return(NULL)
  }
}

this.query <- lapply(stopID, getStopData)

this.query <- dplyr::bind_rows(this.query)

dd <- format(Sys.time(), "%Y%m%d")
thefile <- file.path("Data", paste0("queries_58_", dd, ".Rda"))

queries58 <- NULL
if (file.exists(thefile)) {
  load(thefile)
}
queries58 <- dplyr::bind_rows(queries58, this.query)
save(queries58, file=thefile)

function()
{
  ## functions that fix up the date
  g <- mutate(queries58, Predicted=as.numeric(gsub("/Date\\(([[:digit:]]+)\\+1000\\)/", "\\1", PredictedArrivalDateTime))/1000,
              Predicted=as.POSIXct(Predicted, origin="1970-01-01")
  )
}
