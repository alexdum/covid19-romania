library("htmltools")

addLabel <- function(data) {
  data$label <- paste0(
    '<b>',data$county, '</b><br>
    <table style="width:100px;">
    <tr><td>Cases:</td><td align="right">', data$case_sum, '</td></tr>
    <tr><td>Deceased:</td><td align="right">', data$death_sum, '</td></tr>
    
    </table>'
  )
  data$label <- lapply(data$label, HTML)
  
  return(data)
}



# confirmed ---------------------------------------------------------------

map <-  leaflet( 
                options = leafletOptions(minZoom = 6, maxZoom = 18)) %>%
  setView(25, 46, zoom = 6) %>%
  setMaxBounds(20, 43.5, 30, 48.2) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Light") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satellite") %>%
  addLayersControl(
    baseGroups    = c("Light", "Satellite"),
    #overlayGroups = c("Cases", "Deceased")
  ) %>% #hideGroup("Deceased") %>%
  
  
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-home", title = "Reset zoom",
    onClick = JS("function(btn, map){ map.setView([46, 25], 6); }"))) 
# %>%
#   addEasyButton(easyButton(
#     icon    = htmltools::span(class = "star", htmltools::HTML("&target;")),title = "Locate Me",
#     onClick = JS("function(btn, map){ map.locate({setView: true, maxZoom: 6}); }"))) 

observe({
  req(input$timeSlider, input$overview_map_zoom)
  zoomLevel <- input$overview_map_zoom
  
  data.sub <- counties[which(counties$case_date == input$timeSlider),] %>%
    dplyr::distinct() %>%
    dplyr::filter(case_sum > 0) %>% 
    addLabel() 
  
  leafletProxy("overview_map", data = data.sub) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng          = ~longitude,
      lat          = ~latitude,
      radius       = ~log((case_sum + 3)^(zoomLevel / 2.2)),
      stroke       = FALSE,
      color        = "red",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Cases"
    )
  # %>%
  # addCircleMarkers(
  #   lng          = ~longitude,
  #   lat          = ~latitude,
  #   radius       = ~log(death_sum^((zoomLevel)-1)),
  #   stroke       = FALSE,
  #   color        = "#636363",
  #   fillOpacity  = 0.5,
  #   label        = ~label,
  #   labelOptions = labelOptions(textsize = 15),
  #   group        = "Deceased"
  # ) 
  output$maps.text <- renderText(paste("Romania COVID-19 map number of confirmed cases by counties ",format(input$timeSlider,  "%b %d, %Y")))
  output$tabs.text <- renderText(paste("Romania COVID-19 number of confirmed and deceased cases ",format(input$timeSlider,  "%b %d, %Y")))
  
  output$maps_data <-  DT::renderDataTable(server = T, {
    DT::datatable(data.sub[order(data.sub$case_sum, decreasing = T), c("county","case_date","case_no", "case_sum", "death_no", "death_sum" )], rownames = F, 
                  colnames = c("County", "Date", "Number of cases", "Overall number of cases", "Number of deaths", "Overall number of deaths"),
                  extensions = c('Buttons',"Responsive"), 
                  options = list(dom = 'Bfrtip', pageLength = 41,
                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
  })
})

output$overview_map <- renderLeaflet(
  return(map)
)



# decesed -----------------------------------------------------------------


map2 <-  leaflet( 
                 options = leafletOptions(minZoom = 6, maxZoom = 18) ) %>%
  setView(25, 46, zoom = 6) %>%
  setMaxBounds(20, 43.5, 30, 48.2) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Light") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satellite") %>%
  addLayersControl(
    baseGroups    = c("Light", "Satellite"),
    #overlayGroups = c("Cases", "Deceased")
  ) %>% #hideGroup("Deceased") %>%
  
  
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-home", title = "Reset zoom",
    onClick = JS("function(btn, map){ map.setView([46, 25], 6); }"))) 
# %>%
#   addEasyButton(easyButton(
#     icon    = htmltools::span(class = "star", htmltools::HTML("&target;")),title = "Locate Me",
#     onClick = JS("function(btn, map){ map.locate({setView: true, maxZoom: 6}); }"))) 

observe({
  req(input$timeSlider2, input$overview_map2_zoom)
  zoomLevel <- input$overview_map2_zoom
  
  data.sub <- counties2[which(counties2$case_date == input$timeSlider2),] %>%
    dplyr::distinct() %>%
    dplyr::filter(death_sum > 0) %>% 
    addLabel() 
  
  leafletProxy("overview_map2", data = data.sub) %>%
    clearMarkers() %>%
    # addCircleMarkers(
    #   lng          = ~longitude,
    #   lat          = ~latitude,
    #   radius       = ~log((case_sum + 3)^(zoomLevel / 2.2)),
    #   stroke       = FALSE,
    #   color        = "red",
    #   fillOpacity  = 0.5,
    #   label        = ~label,
    #   labelOptions = labelOptions(textsize = 15),
    #   group        = "Cases"
    # )
  # %>%
  addCircleMarkers(
    lng          = ~longitude,
    lat          = ~latitude,
    radius       = ~log((death_sum + 3)^(zoomLevel)/2),
    stroke       = FALSE,
    color        = "#636363",
    fillOpacity  = 0.5,
    label        = ~label,
    labelOptions = labelOptions(textsize = 15),
    group        = "Deceased"
  )
  output$maps.text2 <- renderText(paste("Romania COVID-19 map number of deceased by counties ",format(input$timeSlider2,  "%b %d, %Y")))
  output$tabs.text <- renderText(paste("Romania COVID-19 number of confirmed and deceased cases by counties ",format(input$timeSlider2,  "%b %d, %Y")))
  
  output$maps_data <-  DT::renderDataTable(server = T, {
    DT::datatable(data.sub[order(data.sub$death_sum, decreasing = T), c("county","case_date","case_no", "case_sum", "death_no", "death_sum" )], rownames = F, 
                  colnames = c("County", "Date", "Number of cases", "Overall number of cases", "Number of deaths", "Overall number of deaths"),
                  extensions = c('Buttons',"Responsive"), 
                  options = list(dom = 'Bfrtip', pageLength = 41,
                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
  })
})

output$overview_map2 <- renderLeaflet(
  return(map2)
)

