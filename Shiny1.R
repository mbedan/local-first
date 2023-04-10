library(shiny)
library(readxl)
library(writexl)
library(officer)

ui <- fluidPage(
  fileInput("file", "Upload Excel File"),
  tableOutput("table"),
  plotOutput("plot"),
  downloadButton("download_excel", "Download Excel"),
  downloadButton("download_word", "Download Word")
)

server <- function(input, output) {
  data <- reactive({
    req(input$file)
    read_excel(input$file$datapath)
  })
  
  output$table <- renderTable({
    df <- data()
    # Select 24 variables from the dataframe
    df[,1:24]
  })
  
  output$plot <- renderPlot({
    df <- data()
    # Run calculations and plot results
    plot(df[,16], df[,17])
  })
  
  output$download_excel <- downloadHandler(
    filename = function() {
      paste("results", ".xlsx", sep = "")
    },
    content = function(file) {
      write_xlsx(data(), file)
    }
  )
  
  output$download_word <- downloadHandler(
    filename = function() {
      paste("results", ".docx", sep = "")
    },
    content = function(file) {
      my_doc <- read_docx()
      body_add_table(my_doc, data())
      print(my_doc, target = file)
    }
  )
}

shinyApp(ui, server)
