library(shiny)
library(shiny.semantic)

ui <- semanticPage(
    title = "Ships",
    dropdown_input("shiptype", unique(shipsraw[,ship_type]),
      default_text = "Select vessel type"),
    uiOutput("dropdown_sname")
    )

server <- function(input, output, session) {

    dt <- reactive({
        return(shipsraw[ship_type == input$shiptype,])
    })

    output$dropdown_sname <- renderUI(
        dropdown_input("shipname", unique(dt()[,SHIPNAME]),
            default_text = "Select ship name"))
}

shinyApp(ui, server)
    
