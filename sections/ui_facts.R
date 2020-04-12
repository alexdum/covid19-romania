facts_ui <- tabPanel("Statistics & Facts", icon = icon("bar-chart"), value = "#facts", id =  "#facts",
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
                                    #             max = 1, step = .1),,
                                    # submitButton("Apply Changes",icon("refresh")),
                                    
                       ),
                       mainPanel(
                         tabsetPanel(
                           tabPanel("Plots",
                                    fluidRow(
                                      h3("Romania COVID-19 Statistics & Facts"),
                                      h5(first.case),
                                      h5("The first death cases reported on Mar 22, 2020."),
                                      h5(cfr),
                                      column(6,
                                             
                                             h4("Daily confirmed, recovered and death cases", style = "text-align:center;"),
                                             
                                             dygraphOutput("dygraph")
                                             
                                      ),
                                   
                                        column(6, align = "center",
                                               h4("Overall confirmed, recovered and death cases", style = "text-align:center;"),
                                               dygraphOutput("dygraph1"),
                                         
                                        checkboxInput("checkbox_logCaseEvolution", label = "Logarithmic Y-Axis", value = T)
                                        )  ,
                                        helpText("The graph is fully interactive: as your mouse moves over 
                                                       the series individual values are displayed. You can also select regions 
                                                       of the graph to zoom into (double-click zooms out).",style = "text-align:center;")
  
                                    ),
                                    fluidRow(
                                      
                                      column(6,
                                             
                                             h4("Age of contaminated", style = "text-align:center;"),
                                             plotly::plotlyOutput("hist"),
                                             
                                      ),
                                      column(6,
                                             h4("Age of recovered", style = "text-align:center;"),
                                             plotly::plotlyOutput("hist.recov")
                                             
                                      )  
                                    ) ,
                                    fluidRow(
                                      
                                      column(6,
                                             
                                             h4("Age of deaths", style = "text-align:center;"),
                                             plotly::plotlyOutput("hist.decs")
                                             
                                             
                                      ),
                                      column(6,
                                             h4("Country source of infection", style = "text-align:center;"),
                                             plotly::plotlyOutput("hist2")
                                             
                                      )  
                                    ),
                           ),
                           tabPanel("Data",
                                    
                                    h3("Number of novel coronavirus COVID-19 infection, death and recovery cases in Romania"),
                                    DT::dataTableOutput("cum")
                           )
                         )
                       )
                     )
)