#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

cast_needle <- function(plane_width = 20){
  available_range <- plane_width/2 - 1 # where 1 is the length of the needle (unit)
  x_start <- runif(2, -available_range, available_range)
  angle <- runif(1, 0, 2*pi)
  x_end <- c(cos(angle), sin(angle)) + x_start # where the angles are multiplied by the needle length which is 1 in this example
  cross <- floor(x_start[2]) != floor(x_end[2])
  out <- list(start = x_start, end = x_end, cross = cross)
  out
}
buffon_experiment <- function(B = 2084, plane_width = 10, seed = NULL){
  
  if (!is.null(seed)){
    set.seed(seed)
  }
  
  X_start <- X_end <- matrix(NA, B, 2) 
  cross <- rep(NA, B)
  
  for (i in 1:B){
    inter <- cast_needle(plane_width = plane_width)
    X_start[i, ] <- inter$start
    X_end[i, ] <- inter$end
    cross[i] <- inter$cross
  }
  
  out <- list(start = X_start, end = X_end, cross = cross, plane = plane_width)
  class(out) <- "buffon_experiment"
  out
}
needle <- cast_needle(plane_width = 4)
needle
plot(NA, xlim = c(-2, 2), ylim = c(-2, 2), xlab = "x", ylab = "y")
abline(h = -2:2, lty = 3)
lines(c(needle$start[1], needle$end[1]), c(needle$start[2], needle$end[2]))
experiment <- buffon_experiment(B = 2084, plane_width = 4)
experiment
plot(NA, xlim = c(-2, 2), ylim = c(-2, 2), xlab = "x", ylab = "y")
abline(h = -2:2, lty = 3)
for (i in 1:4){
  lines(c(experiment$start[i,1], experiment$end[i,1]), 
        c(experiment$start[i,2], experiment$end[i,2]))
}
plot.buffon_experiment <- function(obj){
  cross <- obj$cross
  X_start <- obj$start
  X_end <- obj$end
  B <- length(cross)
  cols <- rev(hcl(h = seq(15, 375, length = 3), l = 65, c = 100)[1:2])
  
  title_part1 <- 'Buffon\'s needle experiment  -  '
  title_part2 <- ' = '
  pi_hat <- round(2/mean(obj$cross), 6)
  
  title <- bquote(.(title_part1) ~ hat(pi)[B] ~ .(title_part2) ~ .(pi_hat))
  
  plot(NA, xlab = "x", ylab = "y", xlim = c(-obj$plane/2, obj$plane/2), 
       ylim = c(-obj$plan/2, obj$plan/2), 
       main = title)
  abline(h = (-obj$plan):obj$plan, lty = 3)
  
  for (i in 1:B){
    lines(c(X_start[i,1], X_end[i,1]), c(X_start[i,2], X_end[i,2]), 
          col = cols[cross[i] + 1])
  }
}

experiment <- buffon_experiment(B = 2084)
plot(experiment)

converge <- function(B = 2084, plane_width = 10, seed = 1777, M = 12){
  
  if (B < 10){
    warning("B was changed to 10")
    B <- 10
  }
  
  pi_hat <- matrix(NA, B, M)
  trials <- 1:B
  cols <- rev(hcl(h = seq(15, 375, length = (M+1)), 
                  l = 65, c = 100, alpha = 1)[1:M])
  set.seed(seed)
  
  for (i in 1:M){
    cross <- buffon_experiment(B = B, plane_width = plane_width)$cross
    pi_hat[,i] <- 2*trials/cumsum(cross)
  }
  
  plot(NA, xlim = c(1,B), ylim = pi + c(-3/4, 3/4), type = "l", col = "darkblue",
       ylab = bquote(hat(pi)[j]),
       xlab = "j", main = "Buffon\'s needle experiment")
  grid()
  
  for (i in 1:M){
    lines(trials, pi_hat[,i], col = cols[i])
  }
  
  abline(h = pi, lwd = 2, lty = 2)
}

converge(B = 2084, M = 20, seed = 10)

library(shiny)

# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel(h4("Buffon\'s needle experiment - Inputs:")),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("plane", "Plane width:", 10, 6, 100),
      numericInput("B", "Number of trials:", 100, 20, 10^6),
      numericInput("M", "Number of experiments:", 1, 1, 100),
      numericInput("seed", "Simulation seed", 1777, 1, 1000000),
      actionButton("cast", "Let's cast some needles!", icon = icon("thumbs-up"))
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Experiment", plotOutput("exp")),
        tabPanel("Convergence", plotOutput("conv"))
      )
    )
  )
)

# Define server
server <- function(input, output, session) {
  
  observeEvent(input$cast,{
    updateNumericInput(session, "seed", 
                       value = round(runif(1, 1, 10^4)))
  })
  
  # Fling some needles!
  cast = eventReactive(input$cast, {
    buffon_experiment(B = input$B, plane_width = input$plane, 
                      seed = input$seed)
  })
  
  conv = eventReactive(input$cast, {
    converge(B = input$B, plane_width = input$plane, 
             seed = input$seed, M = input$M)
  })
  
  output$exp <- renderPlot({
    plot(cast())
  }, height = 620)
  
  output$conv <- renderPlot({
    conv()
  }, height = 620)
}

# Run the application 
shinyApp(ui = ui, server = server)