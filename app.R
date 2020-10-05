source("helpers.R")
source("modDrop.R")


ui <- semanticPage(
    flow_layout(
    uiOutput("maxd"),
    uiOutput("totd"),
    uiOutput("maxtime"),
    uiOutput("tottime"), cell_width = "250px"),
    tabset(tabs = list(
            list(menu = "Distance map", content = leafletOutput("map")),
            list(menu = "Current ship statistics",
                 content = 
                 div(class = "ui horizontal segments",
                     div(class = "ui segment",
                         plotlyOutput("hist")
                         ),
                     div(class = "ui segment",
                         plotlyOutput("ts", width = "200%")
                         )
                     )),
            list(menu = "Overal statistics",
                 content = plotlyOutput("bar"))
           )),
    uiDropdown("dropdown1", "dropdown #1"),
)

server <- function(input, output, session) {
    # define reactive values
    values <- reactiveValues()
    # one value for each stat, max distance, total distance, max time and total time
    values$maxd <- 0
    values$totd <- 0
    values$maxtime <- 0
    values$tottime <- 0
    values$dtmax <- data.table()
    ship_info <- serverDropdown("dropdown1")

    # initialize stat info

    output$maxd <- renderUI({
        div(class = "ui small statistic",
        div(class = "value", paste(values$maxd)),
        div(class = "label", "Max distance (m)")
        )
    })

    output$totd <- renderUI({
        div(class = "ui small statistic",
            div(class = "value",  paste(values$totd)),
        div(class = "label", "Total distance (m)")
        )
    })

    output$maxtime <- renderUI({
        div(class = "ui small statistic",
            div(class = "value", timeformat(values$maxtime)),
            div(class = "label", "Time of max distance")
        )
    })

    output$tottime <- renderUI({
        div(class = "ui small statistic",
        div(class = "value", timeformat(values$tottime)),
        div(class = "label", "Total observation time")
        )
    })

    # map plot
    
    output$map <- renderLeaflet({
        # if necessary to prevent errors when no vessel type selected
        if((ship_info()[["type"]] != "")&&(ship_info()[["name"]] != "NA")) {
            dt <- shipsraw[ship_type == ship_info()[["type"]],]
            # also this if needed to prevent temporary error in dt
            if(ship_info()[["name"]] %in% dt[, SHIPNAME]) {
                dt <- dt[SHIPNAME == ship_info()[["name"]],]
                dtmax <- maxdistance(dt)
                # change reactive values to change stat info
                values$maxd <- dtmax[1, distance] 
                values$totd <- sum(dtmax[, distance])
                values$maxtime <- abs(as.numeric(difftime(dtmax[1,
                    datetime2], dtmax[1, datetime1], units = "secs")))
                values$tottime <- abs(as.numeric(difftime(max(dtmax[,
                    datetime2]), min(dtmax[, datetime1]), units = "secs")))
                values$dtmax = dtmax
                # plot map
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

    # observe changes in ship name to reflect changes in stats
    # max distance
    observeEvent(values$maxd, {
        output$maxd <- renderUI({
            div(class = "ui red small statistic",
                div(class = "value",       
                    format(values$maxd, nsmall = 2)),
                div(class = "label", "Max distance (m)")
                )
        })
    })
    # total distance
    observeEvent(values$totd, {
        output$totd <- renderUI({
            div(class = "ui small statistic",
                div(class = "value",       
                    format(values$totd, nsmall = 2)),
                div(class = "label", "Total distance (m)")
                )
        })
    })
    # max distance time
    observeEvent(values$maxtime, {
        output$maxtime <- renderUI({
            div(class = "ui small statistic",
                div(class = "value", timeformat(values$maxtime)),
                div(class = "label", "Time of max distance")
                )
        })
    })
    # total observation time 
    observeEvent(values$tottime, {
        output$tottime <- renderUI({
            div(class = "ui small statistic",
                div(class = "value", timeformat(values$tottime)),
                div(class = "label", "Total observation time")
                )
        })
    })

    # histogram with distance distribution
    output$hist <- renderPlotly({
        if((ship_info()[["type"]] != "")&&(ship_info()[["name"]] != "NA")) {
            dt <- shipsraw[ship_type == ship_info()[["type"]],]
            # also this if needed to prevent temporary error in dt
            if(ship_info()[["name"]] %in% dt[, SHIPNAME]) {
                dt <- dt[SHIPNAME == ship_info()[["name"]],]
                dtmax <- maxdistance(dt)
                fig <- plot_ly(type = "histogram",
                     x = ~dtmax[,distance], name = "distance") %>%
                    layout(title = paste("Distance histogram for",
                        ship_info()[["name"]]),
                        yaxis = list(title = "counts"),
                        xaxis = list(title = "Distance (m) between consecutive observations"))
            }
        }
    })

    output$ts <- renderPlotly({
        dtmax <- values$dtmax
        if(nrow(dtmax) != 0) {
            fig <- plot_ly() %>%
                    add_lines(x = ~dtmax[order(datetime1),datetime1],
                        y = ~dtmax[order(datetime1),speed],
                        mode = "lines", name = "speed" ,
                        type = "scatter") %>%
                    add_lines(x = ~dtmax[order(datetime1),datetime1],
                        y = ~dtmax[order(datetime1), distance],
                        mode = "lines", name = "distance (m)",
                        type = "scatter",
                        yaxis = "y2") %>%
                    layout(
                        title = paste(
                            "Speed and distance time series for",
                            ship_info()[["name"]]),
                        yaxis = list(title = "Speed (km/h)"),
                        yaxis2 = list(title = "distance (m)",
                            overlaying = "y",
                            side = "right"),
                        xaxis = list(title = "Time & Date",
                            ticks = dtmax[order(datetime1), datetime1])
                    )
                fig
            }
    })

    output$bar <- renderPlotly({
        nships <- vapply(unique(shipsraw[,ship_type]), function(x) {
            dtemp <- shipsraw[ship_type == x,]
            return(length(unique(dtemp[,SHIPNAME])))
        }, 1)
        dtbar1 <- data.table(shipname = names(nships),
            value = as.numeric(nships),
            color = rep(brewer.pal(3, "Set2")[1], length(nships)))
        dtbar1[shipname == ship_info()[["type"]], color:= brewer.pal(3, "Set2")[2]]
        bar <- plot_ly(x = dtbar1[,shipname], y = dtbar1[,value], type = "bar", marker = list(color = dtbar1[,color])) %>%
            layout(title = "Number of ships per ship type")
    })
}

shinyApp(ui, server)




