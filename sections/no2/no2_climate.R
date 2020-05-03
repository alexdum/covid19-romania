
# download and load data
omi.clim <- raster::stack("data/OMI-Aura/OMI-Aura_L3-OMNO2d_ymonmean_2015_2019.nc4")
omi.clim <- omi.clim/10^15  

omi.clim[omi.clim > 8] <- 8
omi.clim[omi.clim < 2] <- 2

# set color palette
color_pal <- colorNumeric(rev(c('#0A0615','#190D3D','#a50026','#d73027','#f46d43','#fdae61','#fee090','#ffffbf','#e0f3f8','#abd9e9','#74add1','#4575b4')),
                          domain = c(1.9, 8.1),
                          na.color = "transparent")

map.clim <- leaflet( 
  options = leafletOptions(minZoom = 5, maxZoom = 18)) %>%
  setView(25, 46, zoom = 6) %>%
  setMaxBounds(18.5, 41.5, 31, 51) %>%
  
  #ddTiles(group = "OSM ") %>%
  #addProviderTiles(providers$Stamen.Toner, group = "Toner (default)") %>%
  addProviderTiles(providers$Stamen.TonerLite) %>%
  addRasterImage(omi.clim[[1]], colors = color_pal, opacity = .8)  %>%
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

output$no2map_clim = renderLeaflet({
  map.clim})
reactiveRaster <- reactive({omi.clim[[which(month.abb %in% input$no2.month)]]})
observe({
  req(input$no2.month)
  
  leafletProxy("no2map_clim") %>%
    clearImages() %>%
    addProviderTiles(providers$Stamen.TonerLite) %>%
    addRasterImage(reactiveRaster(), colors = color_pal, opacity = .8) %>%
    addProviderTiles(providers$Stamen.TonerLabels) %>%
    addProviderTiles(providers$OpenMapSurfer.AdminBounds) 
})



