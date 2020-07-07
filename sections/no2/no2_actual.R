
# data vezi in global
# omi.act <- raster::stack("data/OMI-Aura/OMI-Aura_L3-OMNO2d_monthly.nc")
# omi.act <- omi.act/10^15  
# dats.act <- as.Date(names(omi.act), "X%Y.%m.%d")
# 
# omi.act[omi.act > 8] <- 8
# omi.act[omi.act < 2] <- 2

# output$mapno2_act.text <- renderText(paste0("Satellite Observed Tropospheric NO₂ Concentration - montlhy means January 01, 2020 - ", 
#                                             format(max(dats.act), "%B %d, %Y")))

output$mapno2_act.text <- renderText(paste0("Satellite Observed Tropospheric NO₂ Concentration - montlhy means January 01, 2020 - ", 
                                            format(as.Date("2020-07-05"), "%B %d, %Y")))

# set color palette
color_pal <- colorNumeric(rev(c('#0A0615','#190D3D','#a50026','#d73027','#f46d43','#fdae61','#fee090','#ffffbf','#e0f3f8','#abd9e9','#74add1','#4575b4')),
                          domain = c(1.9, 8.1),
                          na.color = "transparent")

map.act <- leaflet( 
  options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
  setView(25, 46, zoom = 6) %>%
  setMaxBounds(18.5, 41.5, 31, 51) %>%
  
  #ddTiles(group = "OSM ") %>%
  #addProviderTiles(providers$Stamen.Toner, group = "Toner (default)") %>%
  addProviderTiles(providers$Stamen.TonerLite) %>%
  addRasterImage(omi.act[[1]], colors = color_pal, opacity = .8)  %>%
  addProviderTiles(providers$Stamen.TonerLabels) %>%
  addProviderTiles(providers$OpenMapSurfer.AdminBounds) %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-home", title = "Reset zoom",
    onClick = JS("function(btn, map){ map.setView([46, 25], 6); }")))
#%>%
# addLayersControl(
#   baseGroups = c("Toner Lite")
# ) 

# addLegend(pal = color_pal, values = 2:8, position = "topright",
#           title = "mol./cm2", opacity = 0.8)

output$no2map_act = renderLeaflet({map.act})

reactiveAct <- reactive({omi.act[[which(format(dats.act, "%b %Y") %in% input$no2.act)]]})
observe({
  req(input$no2.act)
  
  leafletProxy("no2map_act") %>%
    clearImages() %>%
    addProviderTiles(providers$Stamen.TonerLite) %>%
    addRasterImage(reactiveAct(), colors = color_pal, opacity = .8) %>%
    addProviderTiles(providers$Stamen.TonerLabels) %>%
    addProviderTiles(providers$OpenMapSurfer.AdminBounds) 
  

  
})



