no2_ui <- tabPanel("NO2 Analysis", icon = icon("industry"), value = "#maps_no2",
                    sidebarLayout(fluid = T,
                                  
                                  sidebarPanel(width = 2,
                                               h3(format(updd, "%b %d, %Y")),
                                               h4(paste(infect, "Cases"),  style = "color:red"),
                                               h4(paste(recov, "Recovered"), style = "color:green"),
                                               h4(paste(decs, "Deaths"), style = "color:#636363"),      
                                               
                                  ),
                                  mainPanel(
                                    tabsetPanel(id = "maps_no2clim",
                                                tabPanel("NO2 Climatology",
                                                         fluidRow(
                                                           h3("Satellite Observed Tropospheric NO2 Concentration - montlhy multiannual means 2010 - 2019"),
                                                           leafletOutput("no2map_clim"),
                                                           sliderInput("integer.month", "Months",
                                                                        min        = 1,
                                                                        max        = 12,
                                                                        value      = 1,
                                                                        step =     1,
                                                                        width      = "100%",
                                                                         ticks = T, animate = T),
                                                           class = "slider",
                                                           width = 12,
                                                           style = 'padding-left:15px; padding-right:15px;',
                                                           helpText("Press the play button for animation.", 
                                                                    style = "text-align:right;")
                                                         )
                                                ),
                                                
                                                tabPanel("Data",
                                                         includeMarkdown("sections/no2/no2_text.md")
                                                )
                                                
                                    )
                                  )
                    )
)
