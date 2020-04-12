spread_ui <- tabPanel("Spread network",
                     sidebarLayout(
                       
                       sidebarPanel(width = 2,
                                    h3(format(updd, "%b %d, %Y")),
                                    h4(paste(infect, "Cases"),  style = "color:red"),
                                    h4(paste(recov, "Recovered"), style = "color:green"),
                                    h4(paste(decs, "Deaths"), style = "color:#636363"),         
                                    # dateRangeInput("daterange", "Date range:",
                                    #                start = min(dats.nod),
                                    #                end   = max(dats.nod),
                                    #                min = as.character(min(dats.nod)),
                                    #                max = as.character(max(dats.nod))),
                                    
                                    # sliderInput("opacity", "Opacity", 0.8, min = 0.1,
                                    #             max = 1, step = .1),
                                    # submitButton("Apply Changes",icon("refresh")),
                                    
                       ),
                       mainPanel(
                         tabsetPanel(
                           #tabPanel("Force Network", simpleNetworkOutput("simple"))#s,
                           tabPanel("Source network graph", 
                                    h3("The network structure of COVID-19 spread in Romania"),
                                    helpText("scroll wheel to zoom in and out, and click to drag"),
                                    forceNetworkOutput("force", width = "100%", height = "1000px")),
                           tabPanel(
                             "Data",
                             h3("The source table of COVID-19 spread in Romania"),
                             DT::dataTableOutput("table")
                           )
                         )
                       )
                     )
)