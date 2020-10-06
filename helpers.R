library(data.table)
library(shiny)
library(shiny.semantic)
library(leaflet)
library(plotly)
library(RColorBrewer)

shipsraw <- readRDS("shipsraw.rds")
iconred <- makeAwesomeIcon(icon= "flag", markerColor = "red", library = "fa")

gdistance <- function(lat1, lat2, lon1, lon2) {
    # function based on Haversine formula for computing geographical distances
    # http://www.movable-type.co.uk/scripts/gis-faq-5.1.html

    # 1 transform coordenades from degrees to radians
    lat1 <- lat1*pi/180
    lat2 <- lat2*pi/180
    lon1 <- lon1*pi/180
    lon2 <- lon2*pi/180
    # 2 compute mean coordenades
    dlat <- lat2 - lat1
    dlon <- lon2 - lon1
    # 3 compute geographical distance using trigonometry
    R <- 6373000 # radius in meters
    a <- sin(dlat/2)^2 + cos(lat1)*cos(lat2)*sin(dlon/2)^2
    c <- 2*asin(min(1, sqrt(a)))
    d <- R*c
    return(d)
}

maxdistance <- function(dt, outliers) {
    dtuse <- data.table(lat1 = dt[1:(.N-1),LAT],
        lat2 = dt[2:(.N),LAT],
        lon1 = dt[1:(.N-1),LON],
        lon2 = dt[2:(.N),LON],
        datetime1 = as.POSIXct(dt[1:(.N-1), DATETIME]),
        datetime2 = as.POSIXct(dt[2:(.N), DATETIME]),
        speed = dt[1:(.N -1), SPEED])
    # skip gdistance calculation for some rows which distance is 0 
    # to improve performance
    dtuse <- dtuse[!(lat1 == lat2 & lon1 == lon2),]
    if(outliers == TRUE) {
        out <- abs(as.numeric(
            difftime(dtuse[,datetime2], dtuse[,datetime1],
                     units = "secs")))%/%86400
        # if true, remove data with intervals bigger than one day
        dtuse <- dtuse[out == 0,]
    }
    d <- vapply(1:nrow(dtuse), function(x) {
        gdistance(dtuse[x,lat1], dtuse[x, lat2],
            dtuse[x, lon1], dtuse[x, lon2])}, 0.0)
    dtuse[,distance := d]
    # now sort dtuse by distance in descending order and by datetime
    # in ascending order
    dtuse <- dtuse[order(-distance, datetime1)]
    return(dtuse)
}

timeformat <- function(secs) {
    # function to export time difference and format
    days <- secs %/% 86400
    hours <- secs %% 86400 %/% 3600
    minutes <- secs %% 3600 %/% 60
    seconds <- secs %% 60

    formatUnit <- function(value, unit) {
        if(value > 0) {
            dprint <- paste(value, unit, " ", sep = "")
        } else {
            dprint <- ""
        }
        return(dprint)
    }

    pday <- formatUnit(days, "d")
    phour <- formatUnit(hours, "h")
    pminute <- formatUnit(minutes, "m")
    psecond <- formatUnit(seconds, "s")
    return(sub(" $","",paste0(pday, phour, pminute, psecond)))
}
