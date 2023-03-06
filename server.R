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

flights_info <- flights_info %>% mutate(flights_info,date=as.Date(paste('2013',month,day,sep="/")))

flights_info$date <-  as.Date(parse_date_time(flights_info$date, "%y/%m/%d"))







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
 
  
  #generate user-inputed graphs for analyzing
  
  #reactive dataset that filters location & date
  flight_reactive_locdat <- reactive({
    filter(flights_info, date >= input$daterange[1] & date <= input$daterange[2], origin %in% input$airportChoice)
  })
  
  #reactive dataset that filter only date
  flight_reactive_dat <- reactive({
    filter(flights_info, date >= input$daterange[1] & date <= input$daterange[2])
  })
  
  #create an output plot for passenger numbers
  output$passenger_numbers <- renderPlotly({
    
    flights <-
      flight_reactive_locdat() %>%
      group_by(date, origin)%>%
      summarise(seats= sum(seats)) %>%
      ungroup
    
    p <- ggplot(data = flights, aes(fill= origin, x= date, y= seats)) +
      geom_bar(position = 'stack', stat="identity", na.rm = TRUE)

    p <- ggplotly(p)
    p
  })
  
  
  #create an output datatable for target location of all flights from NYC
  output$targetloc_all = DT::renderDataTable({
    
    flight_info <-
      flight_reactive_dat() %>% 
      group_by(dest) %>%
      summarise(total_count=n(),
                seats= sum(seats)) %>%
      ungroup
    
    DT::datatable(flight_info, filter = 'top',  options = list(orderClasses = TRUE, pageLength = 5))
  })
  
  
  #create an output datatable for target location for flight from specific NYC airports
  output$targetloc_filt = DT::renderDataTable({
    
    flight_info <-
      flight_reactive_locdat() %>% 
      group_by(origin, dest) %>%
      summarise(total_count=n(),
                seats= sum(seats)) %>%
      ungroup
    
    DT::datatable(flight_info, filter = 'top',  options = list(orderClasses = TRUE, pageLength = 5))
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