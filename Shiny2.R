library(shiny)
library(ggplot2)

ui <- fluidPage(
  fileInput("file", "Upload Data File"),
  selectInput("xvar", "Select X Variable", choices = NULL),
  selectInput("yvar", "Select Y Variable", choices = NULL),
  selectInput("group1", "Group by Variable 1", choices = c("", NULL)),
  selectInput("group2", "Group by Variable 2", choices = c("", NULL)),
  selectInput("group3", "Group by Variable 3", choices = c("", NULL)),
  selectInput("group4", "Group by Variable 4", choices = c("", NULL)),
  checkboxGroupInput("geoms", "Select Geoms",
                     choices = c("Boxplot" = "boxplot",
                                 "Violin Plot" = "violin",
                                 "Scatter Plot" = "point",
                                 "Histogram" = "histogram",
                                 "Density Plot" = "density")),
  plotOutput("plot")
)

server <- function(input, output, session) {
  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  observeEvent(data(), {
    updateSelectInput(session, "xvar", choices = names(data()))
    updateSelectInput(session, "yvar", choices = names(data()))
    updateSelectInput(session, "group1", choices = c("", names(data())))
    updateSelectInput(session, "group2", choices = c("", names(data())))
    updateSelectInput(session, "group3", choices = c("", names(data())))
    updateSelectInput(session, "group4", choices = c("", names(data())))
  })
  
  output$plot <- renderPlot({
    req(input$xvar, input$yvar)
    df <- data()
    p <- ggplot(df, aes_string(x = input$xvar, y = input$yvar))
    
    if (input$group1 != "") {
      p <- p + aes_string(color = input$group1)
    }
    if (input$group2 != "") {
      p <- p + aes_string(fill = input$group2)
    }
    if (input$group3 != "") {
      p <- p + aes_string(linetype = input$group3)
    }
    if (input$group4 != "") {
      p <- p + aes_string(shape = input$group4)
    }
    
    if ("boxplot" %in% input$geoms) {
      p <- p + geom_boxplot()
    }
    if ("violin" %in% input$geoms) {
      p <- p + geom_violin()
    }
    if ("point" %in% input$geoms) {
      p <- p + geom_point()
    }
    if ("histogram" %in% input$geoms) {
      p <- p + geom_histogram()
    }
    if ("density" %in% input$geoms) {
      p <- p + geom_density()
    }
    
    print(p)
  })
}

shinyApp(ui, server)