library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)
library(plotly)
library(lubridate)
#create a navigation bar with seperate tabs
navbarPage("NYC Flights", id="nav", 
           
           #create the first panel: the Map
           tabPanel("Map",
                    
                    leafletOutput(outputId = 'map', #width="100%", height="100%"
                                  )
          ),
          
          #create second tab: data explorer
          tabPanel("NY Airports explorer",
            

            sidebarLayout(
              #create sidebar for inputs
              sidebarPanel(
                checkboxGroupInput(inputId = "airportChoice", label = h3("Which airport(s) would you like to analyze"), 
                                   choices = c("JFK", "EWR", "LGA"),
                                   selected = c("JFK", "EWR" , "LGA")
                                   ),

                dateRangeInput(inputId= "daterange", "During which time perio:",
                               start = "2013-01-01",
                               end   = "2013-12-31")
                ),
              
              #create mainpanel for outputs, e.g. graphs
              mainPanel(tabsetPanel(
                tabPanel('Number of passengers', plotlyOutput('passenger_numbers')),
                tabPanel('Destinations'),
                
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
