uiDropdown <- function(id, label = "dropdown") {
    ns <- NS(id)
    semanticPage(
        div(class = "ui horizontal segments",
            div(class = "ui segment",
                p("Select vessel type"),
                dropdown_input(ns("shiptype"),
                    unique(shipsraw[,ship_type]),
            #value = unique(shipsraw[,ship_type])[1],
                    default_text = "No vessel selected")
            ),
            div(class = "ui segment",
                p("Select ship name"),
                uiOutput(ns("dropdown_sname"))
                ),
            div(class = "ui segment",
                p("Filter data"),
                checkbox_input(ns("outliers"), "remove outliers",
                    is_marked = TRUE))
            )
    )
}

serverDropdown <- function(id) {
    moduleServer(id,
        function(input, output, session) {
            ns <- NS(id)
            dt <- reactive({
                req(input$shiptype)
                return(shipsraw[ship_type == input$shiptype,])
            })

            output$dropdown_sname <- renderUI(
                dropdown_input(ns("shipname"), unique(dt()[,SHIPNAME]),
                    value = unique(dt()[,SHIPNAME])[1],
                    default_text = "No ship name selected"))
            return(reactive({list(type = input$shiptype, name = input$shipname, outliers = input$outliers)}))
        }
        )
}    
