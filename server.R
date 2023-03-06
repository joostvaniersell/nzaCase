library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)

#load in datasets for raw datatab
flights_df <- nycflights13::flights
airlines_df <- nycflights13::airlines
airports_df <- nycflights13::airports
planes_df <- nycflights13::planes
weather_df <-  nycflights13::weather



#start up render function

function(input, output) {
  
  #add a leaflet map for output
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -90.85, lat = 37.45, zoom = 3) %>%
      addCircleMarkers(lng= airports_df$lon, lat=airports_df$lat, radius= 1, label=airports_df$name)
  })  
  

  
  
  
  
  #generate datatables for raw data output
  output$flights = DT::renderDataTable({
    datatable(flights_df, filter = 'top')
  })
  
  output$airlines = DT::renderDataTable({
    datatable(airlines_df, filter = 'top')
  })
  
  output$airports = DT::renderDataTable({
    datatable(airports_df, filter = 'top')
  })
  
  output$planes = DT::renderDataTable({
    datatable(planes_df, filter = 'top')
  })
  
  output$weather = DT::renderDataTable({
    datatable(weather_df, filter = 'top')
  })
}