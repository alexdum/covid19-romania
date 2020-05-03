no2_ui <- tabPanel("NO₂", icon = icon("industry"), value = "#maps_no2",
                   sidebarLayout(fluid = T,
                                 
                                 sidebarPanel(width = 2,
                                              h3(format(updd, "%b %d, %Y")),
                                              h4(paste(infect, "Cases"),  style = "color:red"),
                                              h4(paste(recov, "Recovered"), style = "color:green"),
                                              h4(paste(decs, "Deaths"), style = "color:#636363"),      
                                              
                                 ),
                                 mainPanel(
                                   tabsetPanel(id = "maps_no2clim",
                                               tabPanel("NO₂ Climatology",
                                                        fluidRow(
                                                          h3("Satellite Observed Tropospheric NO₂ Concentration - montlhy multiannual means 2010 - 2019"),
                                                          leafletOutput("no2map_clim"),
                                                          HTML('<strong style="font-size:12px"><center>10<sup>15</sup>molecules/cm<sup>2</sup></center></strong>'),
                                                          HTML('<center><img src="no2_legend_clim.png" height=35 width="127"></center>'),
                                                          sliderTextInput(
                                                            inputId = "no2.month", 
                                                            label = p(tags$b("Select month")), 
                                                            choices = month.abb, selected = month.abb[1], 
                                                            grid = TRUE,
                                                            width = "100%",
                                                            animate = T
                                                          ),
                                                          helpText("Press the play button for animation.", 
                                                                   style = "text-align:right;")
                                                        )
                                               ),
                                               
                                               tabPanel("Data",
                                                        includeMarkdown("sections/no2/no2_text.md")
                                               ),
                                               
                                               tabPanel("NO₂ 2020",
                                                        h4("TBA")
                                               )
                                               
                                   )
                                 )
                   )
)
