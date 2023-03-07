library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(nycflights13)
library(DT)
library(plotly)
library(lubridate)
library(geosphere)

#load in datasets for raw datatab
flights_df <- nycflights13::flights
airlines_df <- nycflights13::airlines
airports_df <- nycflights13::airports
planes_df <- nycflights13::planes
weather_df <-  nycflights13::weather


flights_info <- flights_df %>% full_join(planes, "tailnum")  #Joins the plane info dataset with the flights info dataset

flights_info <- 
  flights_info %>% 
  mutate(seats = replace_na(seats, round(mean(seats, na.rm = TRUE), digits=0))) #replace missings

#create date cariable
flights_info <- flights_info %>% mutate(flights_info,date=as.Date(paste('2013',month,day,sep="/")))

flights_info$date <-  as.Date(parse_date_time(flights_info$date, "%y/%m/%d"))





#start up render function

function(input, output) {
  
  #######################################################################################
  #######################################################################################
  ##CREATE MAP
  #create a reactive function that updates a dataset based on inpurs
  flight_reactive_map <- reactive({
    filter(flights_info, date >= input$daterange_map[1] & date <= input$daterange_map[2], origin %in% input$airportChoice_map) %>%
    group_by(dest) %>%
      summarise(total_count=n(),
                seats= sum(seats)) %>%
      ungroup %>%
      merge(y=airports, 
            by.x='dest', 
            by.y="faa",
            all.x=TRUE) %>%
      na.omit()
  })

  #generate a leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  #update the leaflet map based on the user input
  observe({
    
    #create spatial point data and polygon lines
    data_sp <- SpatialPoints(flight_reactive_map()[, c("lon", "lat")])
    set_point <- data.frame(lon = -77.0369, lat = 38)
    set_point_sp <- SpatialPoints(set_point)

    gc <- gcIntermediate(
      data_sp, set_point_sp, n = 10, addStartEnd = TRUE, sp = TRUE
    )
    print(gc[1])
    
    #adds circles and lines on leaflet map based on user inputs
    leafletProxy("map", data = flight_reactive_map()) %>%
      clearShapes() %>%
      addCircleMarkers(lng= ~lon, lat=~lat, radius= ~total_count/500, label=~name, layerId=~name) %>%
      addPolylines(data = gc, weight = 1)
  
    
    })

  
  
  
  # create function for information to show upon clicking an aiport

  showPopup <- function(name, lat, lng) {
     flight_info_2 <-
       flight_reactive_map()

    selectedairport <- flight_info_2[flight_info_2$name == name,]
    content <- as.character(tagList(
      tags$h3(selectedairport$name),
      tags$h5("Number of flights arriving per selected time period:", selectedairport$total_count),
      tags$h5("Number of travelers arriving per selected time period:", selectedairport$seats)))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = name)
  }

  # When airport is clicked, show a popup with airport info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_marker_click
    if (is.null(event))
      return()
    
    
    showPopup(event$id, event$lat, event$lng)
  
  })

  
  #######################################################################################
  #######################################################################################
 
  
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
    
    #filters and group required data
    flights <-
      flight_reactive_locdat() %>%
      group_by(date, origin)%>%
      summarise(seats= sum(seats)) %>%
      ungroup
    
    #create plot
    p <- ggplot(data = flights, aes(fill= origin, x= date, y= seats)) +
      geom_bar(position="dodge", stat="identity", na.rm = TRUE) +
      scale_fill_manual(values = c('JFK'= "Red", "EWR" = "Green", "LGA" = 'Blue')) +
      labs(title = 'Total number of passengers (estimated)', x = "Date", y = "Number of passengers(estimated") 
    
    #give plto output back to the render function
    p <- ggplotly(p)
    p
  })
  
  ################################################
  #create an output datatable for target location of all flights from NYC and render it
  output$targetloc_all = DT::renderDataTable({
    
    flight_info <-
      flight_reactive_dat() %>% 
      group_by(dest) %>%
      summarise(total_count=n(),
                seats= sum(seats)) %>%
      ungroup
    
    DT::datatable(flight_info,  caption = "All airports", rownames = FALSE,  filter = 'top',  options = list(orderClasses = TRUE, pageLength = 5,  order = list(1,'desc')))
  })
  
  
  #create an output datatable for target location for flight from specific NYC airports
  output$targetloc_filt = DT::renderDataTable({
    
    flight_info <-
      flight_reactive_locdat() %>% 
      group_by(origin, dest) %>%
      summarise(total_count=n(),
                seats= sum(seats)) %>%
      ungroup
    
    dt <- DT::datatable(flight_info,  caption = "Selected airports", rownames = FALSE, filter = 'top',  options = list(orderClasses = TRUE, pageLength = 5, order = list(2,'desc')))
  })
  
  ###########################################
  #Create some simple graphs to visualize delay
  
  output$delay_trend <- renderPlotly({
    
    g <- ggplot(flight_reactive_locdat(), aes(x = date, y = arr_delay, title = "Seasonality Trends")) +
        geom_smooth(color='Black') + 
        geom_smooth(aes(color=origin)) +
        labs(title = 'Smoothed delay curve', x = "Date", y = "Average Arrival Delay (minutes)") 
    
    g <- ggplotly(g)
    g
    
  })
  
  
  output$delay_carriers <- renderPlotly({
    g<- ggplot(flight_reactive_locdat(), aes(x = carrier, fill = arr_delay > 0)) +
      geom_bar() +
      labs(x = "Airline", y = "Number of Flights") +
      scale_fill_manual(values = c("red", "green"), name = "Delay", labels = c("Delayed", "On Time")) +
      ggtitle("Frequency of Delayed Flights by Airline")
    g<- ggplotly(g)
    g
  })
  
  
  

  
  
  
  #######################################################################################
  #######################################################################################
  
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