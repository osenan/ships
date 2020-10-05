source("explore.R")
source("modDrop.R")

library(shiny)
library(shiny.semantic)
library(shinydashboard)
library(leaflet)

ui <- semanticPage(
    uiDropdown("dropdown1", "dropdown #1"),
    card(class = "red",
         div(class == "content",
             div(class = "header", "9878 meters"),
             div(class = "meta", "Max distance ship 1")
             ), style = "color:red;"),
    leafletOutput("map")
    
        )
)

server <- function(input, output, session) {
    ship_info <- serverDropdown("dropdown1")
    output$map <- renderLeaflet({
        # if necessary to prevent errors when no vessel type selected
        if((ship_info()[["type"]] != "")&&(ship_info()[["name"]] != "NA")) {
            dt <- shipsraw[ship_type == ship_info()[["type"]],]
            # also this if needed to prevent temporary error in dt
            if(ship_info()[["name"]] %in% dt[, SHIPNAME]) {
                dt <- dt[SHIPNAME == ship_info()[["name"]],]
                dtmax <- maxdistance(dt)
                m <- leaflet() %>%
                    addTiles() %>%
                    addAwesomeMarkers(lat = dtmax[1, lat1],
                        icon = iconred, group = "Max distance",
                        lng = dtmax[1, lon1], label = "Beggining") %>%
                    addAwesomeMarkers(lat = dtmax[1,lat2],
                        icon = iconred, group = "Max distance",
                        lng = dtmax[1, lon2], label = "End") %>%
                    addPolylines(lat = dtmax[2:(.N), lat1],
                        lng = dtmax[2:(.N),lon2], color = "gray",
                        weight = 3, fillOpacity = 0.1,
                        group = "All points") %>%
                    addPolylines(lat = c(dtmax[1, lat1], dtmax[1,lat2]),
                        lng = c(dtmax[1, lon1], dtmax[1, lon2]),
                        color = "red", group = "Max distance") %>%
                    addLayersControl(
                        overlayGroups = c("Max distance", "All points"),
                        options =
                            layersControlOptions(collapsed = FALSE)) %>%
                    addLegend(colors = c("gray","red"),
                              labels = c("All points", "Max distance"))
            }
        }
    })
}

shinyApp(ui, server)




