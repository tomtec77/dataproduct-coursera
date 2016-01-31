# This is the user-interface definition of a Shiny web application.

library(shiny)
library(plyr)
library(dplyr)
library(ggplot2)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("River Ice Breakup Explorer"),
  
  sidebarPanel(
    sliderInput("year", "Year range",
                1917, 2010, value=c(1917,2010), step=1, sep=""),
    
    uiOutput("breakpointControl"),
    
    # Help text that only appears when the data browser tab is selected  
    conditionalPanel('input.tabselect === "Data Browser"',
                     helpText("Click the column header to sort a column."))
  ),

  mainPanel(
    tabsetPanel(type="tabs", id="tabselect",
                tabPanel("About"),
                tabPanel("Plot",
                         plotOutput("distPlot")),
                tabPanel("Data Browser",
                         dataTableOutput("table1"))
                )
  )
))