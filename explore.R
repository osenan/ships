library(data.table)

shipsraw <- fread("ships.csv")

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



