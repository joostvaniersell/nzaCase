library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)
library(plotly)
library(lubridate)

#load in datasets for raw datatab
flights_df <- nycflights13::flights
airlines_df <- nycflights13::airlines
airports_df <- nycflights13::airports
planes_df <- nycflights13::planes
weather_df <-  nycflights13::weather


flights_info <- flights_df %>% full_join(planes, "tailnum")  #Joint de plane info dataset met de flights info dataset

flights_info <- 
  flights_info %>% 
  mutate(seats = replace_na(seats,mean(seats, na.rm = TRUE))) #replace missings



flights <-
  flights_info %>%
  group_by(month, origin, day)%>%
  summarise(seats= sum(seats)) %>%
  ungroup

flights <- flights %>% mutate(flights,date=as.Date(paste('2013',month,day,sep="/")))

flights$date <-  as.Date(parse_date_time(flights$date, "%y/%m/%d"))



#start up render function

function(input, output) {
  
  ###############################################
  #add a leaflet map for output
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -90.85, lat = 37.45, zoom = 3) %>%
      addCircleMarkers(lng= airports_df$lon, lat=airports_df$lat, radius= 1, label=airports_df$name)
  })  
  

  
  ###############################################
 
  
  #generate user-inputed graphs for analzying
  
  
  flight_reactive <- reactive({
    filter(flights, date >= input$daterange[1] & date <= input$daterange[2], origin %in% input$airportChoice)
  })
  
  output$passenger_numbers <- renderPlotly({
    
    
    p <- ggplot(data = flight_reactive(), aes(fill= origin, x= date, y= seats)) +
      geom_bar(position = 'stack', stat="identity", na.rm = TRUE)

    p <- ggplotly(p)
    p
  })
  
  
  
  
  
  
  
  ###########################################
  
  #generate datatables for raw data output
  output$flights = DT::renderDataTable({
    DT::datatable(flights_df, filter = 'top',  options = list(orderClasses = TRUE))
  })
  
  output$airlines = DT::renderDataTable({
    DT::datatable(airlines_df, filter = 'top',  options = list(orderClasses = TRUE))
  })
  
  output$airports = DT::renderDataTable({
    DT::datatable(airports_df, filter = 'top',  options = list(orderClasses = TRUE))
  })
  
  output$planes = DT::renderDataTable({
    DT::datatable(planes_df, filter = 'top',  options = list(orderClasses = TRUE))
  })
  
  output$weather = DT::renderDataTable({
    DT::datatable(weather_df, filter = 'top',  options = list(orderClasses = TRUE))
  })
}