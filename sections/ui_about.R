about_ui <- tabPanel("About",icon = icon("question-circle"), value = "#about", id = "#about",
                     
                     sidebarLayout(
                       
                       sidebarPanel(
                         width = 2,
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
                         p("This web site aims to provide accurate and relevant facts and statistics about COVID-19 spread in Romania."),
                         p("The analysis is based on data provided by covid19.geo-spatial.org."),
                         p("The dashboard is structured in two main sections:"),
                         tags$ul(
                           tags$li("key figures and plots:", tags$a(href="https://covid-19.shinyapps.io/romania/#facts",target="_blank", "https://covid-19.shinyapps.io/romania/#facts")), 
                           tags$li("relevant maps:", tags$a(href="https://covid-19.shinyapps.io/romania/#maps",target="_blank", "https://covid-19.shinyapps.io/romania/#maps")), 
                           
                           
                           
                         )
                       )
                     )
) 