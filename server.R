library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)

location_df = airports <- nycflights13::airports

function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -90.85, lat = 37.45, zoom = 3) %>%
      addCircleMarkers(lng= location_df$lon, lat=location_df$lat, radius= 1, label=location_df$name)
  })  
}