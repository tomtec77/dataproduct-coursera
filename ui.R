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
    
    conditionalPanel('input.tabselect == "Plot" | input.tabselect == "Summary"',                     
                     checkboxGroupInput("fitselect",
                                        "Select models to fit",
                                        list("Linear trend"="linear",
                                             "Segmented trend"="segment")),
                     uiOutput("breakpointControl")),
    
    # Help text that only appears when the data browser tab is selected  
    conditionalPanel('input.tabselect === "Data Browser"',
                     helpText("Click the column header to sort a column."))
  ),

  mainPanel(
    tabsetPanel(type="tabs", id="tabselect",
                tabPanel("About",
                         h2("About the app"),
                         p(
"This app lets you explore the effects of climate change by looking at ice
breakup data for the Nenana river in Alaska, USA. This river usually
freezes over during October and November and generally breaks up in late
April or early May. With this app you can explore ice breakup data from
1917 to 2010 to assess whether climate change has been causing a trend
towards earlier breakup dates."),
                        p(
"The main input is the 'Year range' slider where you can change the range
of years to analyze."
                        ),
                        h3("Plot"),
                        p(
"Select this tab to see a plot of the ice breakup data. Addtional inputs
will also show up. You can select up to two models to fit to the data: one
linear and one segmented model. The last model is to consider the
possibility that the trend may be changing at some particular breakpoint
year, which you can choose using the 'Segmented break point year' slider.
Selected models will be shown in the plot with lines. If you select both,
a text box will appear below the plot comparing them via the AIC
criterion."
                        ),
                        h3("Summary"),
                        p(
"If you select any of the models, this tab will show the summaries of the
model fits."
                        ),
                        h3("Data Browser"),
                        p(
"This tab allows you to browse the data for the selected range of years.
You can sort the columns by clicking the column headers or use the search
box to find a particular row of data."
                        )
                ),
                tabPanel("Plot",
                         plotOutput("distPlot"),
                         verbatimTextOutput("modelcomp")),
                tabPanel("Summary",
                         verbatimTextOutput("fitsummary")),
                tabPanel("Data Browser",
                         dataTableOutput("table1")),
                tabPanel("Acknowledgements",
                         br(),
                         p(
                           "This app was created based on materials from the course
'A (Very) Short Course On The Analysis Of Air Quality Data' by Prof. Carl
Schwarz from Simon Fraser University, Canada."
                         ),
                         p(
                           "Course materials are available online at this URL:"
                         ),
                         div(
                           "http://people.stat.sfu.ca/~cschwarz/Stat-AirQuality/",
                           style="color:blue"
                         ))
                )
  )
))