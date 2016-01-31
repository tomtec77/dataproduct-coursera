# This is the server logic for a Shiny web application.
library(shiny)
library(plyr)
library(dplyr)
library(ggplot2)
library(AICcmodavg)

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
  
  # Fit a linear model to the selected data
  fit.linear <- reactive({
    if ("linear" %in% input$fitselect) {
      my.fit <- lm(Julian.Date ~ Year,
                   data=filter(df, Year>=input$year[1], Year<=input$year[2]))
      my.fit
    }
  })
  
  # Fit a segmented model
  # With the selected breakpoint, we create a variable that is either
  # 0 or 1 if the year is before or after the breakpoint, respectively
  fit.segment <- reactive({
    if ("segment" %in% input$fitselect) {
      dfit <- filter(dfsel(), Year>=input$year[1], Year<=input$year[2])
      dfit$Year.Break <- pmax(0, dfit$Year-input$breakpoint)
      my.fit <- lm(Julian.Date ~ Year + Year.Break, data=dfit)
      my.fit
    }
  })
  
  # Print the summaries of the fitted models
  model.summary <- reactive({
    if ("linear" %in% input$fitselect) {
      linear.summary <- summary(fit.linear())
    } else {
      linear.summary <- "Not selected"
    }
    if ("segment" %in% input$fitselect) {
      segment.summary <- summary(fit.segment())
    } else {
      segment.summary <- "Not selected"
    }
    list("Linear trend"=linear.summary, "Segmented trend"=segment.summary)
  })
  output$fitsummary <- renderPrint(model.summary())
  
  # Compare the models
  model.comparison <- reactive({
    if (!("linear" %in% input$fitselect & "segment" %in% input$fitselect)) {
      comp.out <- "Only one model selected"
    } else {
      comp.out <- aictab(list(fit1=fit.linear(), fit2=fit.segment()),
                         modnames=c("Linear","Segmented"), sort=TRUE)   
    }
    comp.out
  })
  output$modelcomp <- renderPrint(model.comparison())
  
  # Create a plot of the data points in the selected year range
  output$distPlot <- renderPlot({
    
    dfplot <- dfsel()
    
    fig <- ggplot(dfplot, aes(x=Year, y=Julian.Date))
    fig <- fig + geom_point(size=2)
    fig <- fig + xlim(input$year)
    fig <- fig + xlab("Year")
    fig <- fig + ylab("Julian Date")
    
    # Add the linear fit plot if selected
    if ("linear" %in% input$fitselect) {
      fig <- fig + geom_smooth(method="lm", se=FALSE, size=1.5)
    }
    
    # Add the segmented fit plot if selected
    if ("segment" %in% input$fitselect) {
      dfplot$Year.Break <- pmax(0, dfplot$Year-input$breakpoint)
      dfplot$SegmentPred <- predict.lm(fit.segment(), dfplot)
      fig <- fig + geom_line(data=dfplot, aes(x=Year, y=SegmentPred), size=1.5,
                             colour="firebrick")
    }
    
    print(fig)
  })
  
})
