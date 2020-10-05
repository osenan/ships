uiDropdown <- function(id, label = "dropdown") {
    ns <- NS(id)
    semanticPage(
        p("Select vessel type"),
        dropdown_input(ns("shiptype"), unique(shipsraw[,ship_type]),
            default_text = "No vessel selected"),
        p("Select ship name"),
        uiOutput(ns("dropdown_sname"))
    )
}

serverDropdown <- function(id) {
    moduleServer(id,
        function(input, output, session) {
            ns <- NS(id)
            dt <- reactive({
                return(shipsraw[ship_type == input$shiptype,])
            })

            output$dropdown_sname <- renderUI(
                dropdown_input(ns("shipname"), unique(dt()[,SHIPNAME]),
                    value = unique(dt()[,SHIPNAME])[1],
                    default_text = "No ship name selected"))
            return(reactive({list(type = input$shiptype, name = input$shipname)}))
        }
        )
}    
