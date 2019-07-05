#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Example_App"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        radioButtons("color", label = h3("Radio buttons"),
                     choices = list("red" = "red" , "blue" = "blue", "green" = "green"), 
                     selected = 1)
                   ),
                
   mainPanel(
     plotOutput("distPlot")
   )
)
)
# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$distPlot <- renderPlot({
   
  x <- 1:10
  par(mfrow = c(1,1))
  plot(x, type = "l", col = input$color, lty = 3, pch = 13)

   
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

