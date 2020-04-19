maps_ui <- tabPanel("Maps", icon = icon("layer-group"), value = "#maps",
                    sidebarLayout(fluid = T,
                                  
                                  sidebarPanel(width = 2,
                                               h3(format(updd, "%b %d, %Y")),
                                               h4(paste(infect, "Cases"),  style = "color:red"),
                                               h4(paste(recov, "Recovered"), style = "color:green"),
                                               h4(paste(decs, "Deaths"), style = "color:#636363"),      
                                               
                                  ),
                                  mainPanel(
                                    tabsetPanel(id = "maps_tab",
                                                tabPanel("Confirmed",
                                                         fluidRow(
                                                           h3(textOutput("maps.text")),
                                                           leafletOutput("overview_map"),
                                                           sliderInput(
                                                             "timeSlider",
                                                             label      = "Select date for the map",
                                                             min        = min(counties$case_date),
                                                             max        = max(counties$case_date),
                                                             value      = max(counties$case_date),
                                                             width      = "100%",
                                                             timeFormat = "%d.%m.%Y",
                                                             animate    = animationOptions(loop = F)
                                                             
                                                           ),
                                                           class = "slider",
                                                           width = 12,
                                                           style = 'padding-left:15px; padding-right:15px;',
                                                           helpText("Press the play button for animation.", 
                                                                    style = "text-align:right;")
                                                         )
                                                ),
                                                tabPanel("Deceased",
                                                         fluidRow(
                                                           h3(textOutput("maps.text2")),
                                                           leafletOutput("overview_map2"),
                                                           sliderInput(
                                                             "timeSlider2",
                                                             label      = "Select date for the map",
                                                             min        = min(counties2$case_date),
                                                             max        = max(counties2$case_date),
                                                             value      = max(counties2$case_date),
                                                             width      = "100%",
                                                             timeFormat = "%d.%m.%Y",
                                                             animate    = animationOptions(loop = F)
                                                           ),
                                                           class = "slider",
                                                           width = 12,
                                                           style = 'padding-left:15px; padding-right:15px;',
                                                           helpText("Press the play button for animation.",
                                                                    style = "text-align:right;")
                                                         )
                                                ),
                                                tabPanel("Data",
                                                         h3(textOutput("tabs.text")),
                                                         DT::dataTableOutput("maps_data")
                                                )
                                                
                                    )
                                  )
                    )
)
