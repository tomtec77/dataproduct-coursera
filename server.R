# This is the server logic for a Shiny web application.
library(shiny)
library(plyr)
library(dplyr)
library(ggplot2)

# Download the Nenana River data if necessary, then load it into a
# data frame
if (!file.exists("nenana.csv")) {
  fileUrl <- "http://people.stat.sfu.ca/~cschwarz/Stat-AirQuality/Examples/Nenana/nenana.csv"
  download.file(fileUrl, destfile="nenana.csv", method="curl")
}
df <- read.table("nenana.csv", header=TRUE, sep=",")

shinyServer(function(input, output) {
  
  # Filter the data to only keep years in the selected range
  dfsel <- reactive({ 
    dfsel <- filter(df, Year>=input$year[1], Year<=input$year[2])
    colnames(dfsel) <- c("Year", "Julian.Date", "Date.Time")
    dfsel })
  
  # Create a slider to select a breakpoint for the segmented linear model.
  # This breakpoints needs to be within the selected year range
  output$breakpointControl <- renderUI({
    sliderInput("breakpoint", "Segmented model break point",
                input$year[1]+1, input$year[2]-1,
                floor((input$year[1]+input$year[2])/2), step=1, sep="")
  })
  
  # Create a table of the data
  output$table1 <- renderDataTable({ dfsel() })
  
  # Create a plot of the data points in the selected year range
  output$distPlot <- renderPlot({
    
    dfplot <- dfsel()
    
    fig <- ggplot(dfplot, aes(x=Year, y=Julian.Date))
    fig <- fig + geom_point(size=2)
    fig <- fig + xlim(input$year)
    
    print(fig)
  })
  
})
