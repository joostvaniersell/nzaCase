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
          
          
          tabPanel("Data explorer")
           
)
