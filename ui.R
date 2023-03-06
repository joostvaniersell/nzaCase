library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)
library(plotly)
library(lubridate)
#create a navigation bar with seperate tabs
fluidPage(
  navbarPage("NYC Flights", id="nav", 
           
           #create the first panel: the Map
           tabPanel("Map",
                    
                    leafletOutput(outputId = 'map', width="1000", height="1000"
                                  )
          ),
          
          #create second tab: data explorer
          tabPanel("NY Airports explorer",
            

            sidebarLayout(
              #create sidebar for inputs
              sidebarPanel(
                #checkbox for airports to analyze
                checkboxGroupInput(inputId = "airportChoice", label = h3("Which airport(s) would you like to analyze"), 
                                   choices = c("JFK", "EWR", "LGA"),
                                   selected = c("JFK", "EWR" , "LGA")
                                   ),
                
                #range for time period
                dateRangeInput(inputId= "daterange", h3("During which time period:"),
                               start = "2013-01-01",
                               end   = "2013-12-31")
                ),
              
              #create mainpanel for outputs, e.g. graphs
              mainPanel(tabsetPanel(
                tabPanel('Number of passengers', plotlyOutput('passenger_numbers')),
                tabPanel('Destinations', DT::dataTableOutput("targetloc_all"), DT::dataTableOutput("targetloc_filt")),
                
              )
              )
          )
          ),
          
          
          #create third tab: raw data explorer
          
          tabPanel("Raw Data explorer",
            tabsetPanel(
              tabPanel("Flights", DT::dataTableOutput("flights")),
              tabPanel("Airlines", DT::dataTableOutput("airlines")),
              tabPanel("Airports", DT::dataTableOutput("airports")),
              tabPanel("Planes", DT::dataTableOutput("planes")),
              tabPanel("Weather", DT::dataTableOutput("weather"))
            )
          ),
          
          tabPanel("Read Me",
                   includeMarkdown("readme.Rmd"))
            
           
)

)