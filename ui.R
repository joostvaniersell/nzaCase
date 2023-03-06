library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)

#create a navigation bar with seperate tabs
navbarPage("NYC Flights", id="nav", 
           
           #create the first panel: the Map
           tabPanel("Map",
                    
                    leafletOutput(outputId = 'map', #width="100%", height="100%"
                                  )
          ),
          
          #create second tab: data explorer
          tabPanel("Data explorer"),
          
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
