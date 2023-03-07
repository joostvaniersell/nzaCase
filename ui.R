library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)
library(plotly)
library(lubridate)
library(geosphere)
#create a navigation bar with seperate tabs


fluidPage(
  navbarPage("NYC Flights", id="nav", 
             
           #######################################################################################
           #######################################################################################
           #create the first panel: the Map
        
           tabPanel("Map",
                    
                    tags$head(
                      # Include our custom CSS
                      includeCSS("styles.css")),
                      
                    
                    leafletOutput(outputId = 'map', height="1000" ),
                    
                    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                  draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                  width = 330, height = "auto",
                                  
                                  checkboxGroupInput(inputId = "airportChoice_map", label = h3("Which airport(s) would you like to analyze"), 
                                                     choices = c("JFK", "EWR", "LGA"),
                                                     selected = c("JFK", "EWR" , "LGA")
                                  ),
                                  
                                  #range for time period
                                  dateRangeInput(inputId= "daterange_map", h3("During which time period:"),
                                                 start = "2013-01-01",
                                                 end   = "2013-12-31")
                                  )
                                  
          
          ),
          
          
          #######################################################################################
          #######################################################################################
          
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
                               end   = "2013-01-30")
                ),
              
              #create mainpanel for outputs, e.g. graphs
              mainPanel(tabsetPanel(
                tabPanel('Number of passengers', plotlyOutput('passenger_numbers')),
                tabPanel('Destinations', DT::dataTableOutput("targetloc_all"), DT::dataTableOutput("targetloc_filt")),
                tabPanel('Seasonal delay trend', plotlyOutput('delay_trend')),
                tabPanel('Delay per carrier', plotlyOutput('delay_carriers'))
              )
              )
          )
          ),
          
          
          
          
          #######################################################################################
          #######################################################################################
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
          
          
          
          #######################################################################################
          #######################################################################################
          #Readme file
          
          tabPanel("Read Me",
                   includeMarkdown("readme.Rmd"))
            
           
)

)