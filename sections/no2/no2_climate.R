
# download and load data
omi.clim <- raster::stack("data/OMI-Aura/OMI-Aura_L3-OMNO2d_ymonmean_2010_2019.nc4")
omi.clim <- omi.clim/10^15  

omi.clim[omi.clim>8] <- 8
omi.clim[omi.clim<2] <- 2

# set color palette
color_pal <- colorNumeric(c('#fff7f3','#fde0dd','#fcc5c0','#fa9fb5','#f768a1','#dd3497','#ae017e','#7a0177','#49006a'),
                          domain = c(1.9, 8.1),
                          na.color = "transparent")

map.clim <- leaflet( 
  options = leafletOptions(minZoom = 6, maxZoom = 18)) %>%
  setView(25, 46, zoom = 6) %>%
  setMaxBounds(20, 43.5, 30, 48.2) %>%

  #ddTiles(group = "OSM ") %>%
  #addProviderTiles(providers$Stamen.Toner, group = "Toner (default)") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addRasterImage(omi.clim[[1]], colors = color_pal, opacity = .8)  %>%
  # addLayersControl(
  #   baseGroups = c("Toner Lite")
  # ) %>%
  addLegend(pal = color_pal, values = 2:8, position = "bottomright",
            title = "10^15 mol/cm2", opacity = 0.8, 
            labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE)))

output$no2map_clim = renderLeaflet({
  map.clim})
reactiveRaster <- reactive({omi.clim[[input$integer.month]]})
observe({
  req(input$integer.month)
  
  leafletProxy("no2map_clim") %>%
    clearImages() %>%
    addRasterImage(reactiveRaster(), colors = color_pal, opacity = .8)
})



