library(shiny)
library(networkD3)
library(curl)
library(dygraphs)
# https://www.r-bloggers.com/visualizing-geo-spatial-data-with-sf-and-plotly/
# https://towardsdatascience.com/top-5-r-resources-on-covid-19-coronavirus-1d4c8df6d85f
# https://towardsdatascience.com/create-a-coronavirus-app-using-r-shiny-and-plotly-6a6abf66091dij
# https://github.com/eparker12/nCoV_tracker

relation.cases <- jsonlite::fromJSON("https://covid19.geo-spatial.org/api/statistics/getCaseRelations")

nodes <- relation.cases$data$nodes$properties 



# ajusteaza datele  dcs și schimba tarile in engleza
source(file = "R/change_countries_name.R", local = T)

nodes <- nodes[order(nodes$case_no),]
links <- relation.cases$data$links
# pentru data
dats.nod <- unique(as.Date(nodes$diagnostic_date, "%d-%m-%Y"))

# pentru situația la zi
#infect <- length(nodes$status[nodes$status == "Confirmat"])
infect <- length(nodes$status)
recov <- length(nodes$status[nodes$status == "Recovered"])
updd <- dats.nod[length(dats.nod)]
decs <- length(nodes$status[nodes$status == "Death"])



# time series plots
cases.day <- aggregate(case_no~diagnostic_date,FUN = length, data = nodes)
cases.day$diagnostic_date <- as.Date(cases.day$diagnostic_date, "%d-%m-%Y")
cases.day <- cases.day[order(cases.day$diagnostic_date),]

recover.day <- nodes[nodes$status == "Recovered",]
recover.day <- aggregate(case_no~healing_date,FUN = length, data = recover.day)
recover.day$healing_date <- as.Date(recover.day$healing_date, "%d-%m-%Y")
names(recover.day)[2] <- "recover_no"

death.day <- nodes[nodes$status == "Death",]
death.day <- aggregate(case_no~death_date,FUN = length, data = death.day)
death.day$death_date <- as.Date(death.day$death_date, "%d-%m-%Y")
names(death.day)[2] <- "death_no"

# completeaza cu toate datele petru ts plot si un este cu toate
cases.day <- merge(cases.day, data.frame(diagnostic_date = seq(min(dats.nod) - 1, max(dats.nod), "days")), all = T)
cases.day <- merge(cases.day, recover.day, all = T, by.x = "diagnostic_date", by.y = "healing_date")
cases.day <- merge(cases.day, death.day, all = T, by.x = "diagnostic_date", by.y = "death_date")


# cumulative sum
cum.day <- cases.day
cum.day[is.na(cum.day)] <- 0
cum.day <- cum.day %>% 
    dplyr::mutate(cum_sum = cumsum(case_no),recover_sum = cumsum(recover_no), death_sum =  cumsum(death_no)) 


# statistics and facts
county.first <- nodes[nodes$diagnostic_date == "26-02-2020",]
first.case <- paste("First case confirmed on", format(min(dats.nod), "%b %d, %Y"), "in", stringr::str_to_title(county.first$county),"county.")

# country of infection
countr.infection <- nodes$country_of_infection
countr.infection[is.na(countr.infection)] <- "Unknown"
countr.infection <- as.data.frame(table(countr.infection), stringsAsFactors = F)
names(countr.infection) <- c("Country", "Counts")
countr.inf <- countr.infection %>% dplyr::filter(!Country %in% c("Romania", "Unknown")) %>%
    dplyr::arrange(desc(Counts))


#### Server ####
server <- function(input, output, session) {
    
    observe({
        
        
        
        nodes$case_no <- paste("#", nodes$case_no)
        nodes$Group <- links$source
        nodes$Nodesize <- 5
        
        links <- links - 1
        links$value <- 4
        
        
        output$force <- renderForceNetwork({
            
            forceNetwork(Links = links, Nodes = nodes, 
                         Source = "source", Nodesize = "Nodesize",
                         Target = "target", Value = "value", NodeID = "case_no",
                         Group = "source_no", zoom = T, arrows = T, legend = F,
                         bounded = F,  linkColour = "black", opacity = 1, opacityNoHover = 1,
                         fontSize = 14, charge = -15, fontFamily = "arial",
                         height = 280, width = 280, linkDistance = 60)
        })
        
        nodes$source_no[is.na(nodes$source_no) & !is.na(nodes$country_of_infection) & nodes$country_of_infection != "România"] <- nodes$country_of_infection[is.na(nodes$source_no) & !is.na(nodes$country_of_infection) & nodes$country_of_infection != "România"]
        
        tab1 <- nodes[,1:4]
        tab1$source_no[is.na(tab1$source_no)] <- "Unknown"
        
        # add leading zero
        tab1$source_no[grep("[[:digit:]]+", tab1$source_no)] <- paste0("#",  sprintf("%03s", tab1$source_no[grep("[[:digit:]]+", tab1$source_no)]))
        tab1$case_no <- paste0("#",sprintf("%03s",as.numeric(gsub("#", "",tab1$case_no))))
        tab1$diagnostic_date <- as.Date(tab1$diagnostic_date, "%d-%m-%Y")
        
        names(tab1) <- c("Case", "Source of infection", "Status", "Diagnostic date")
        tab1 <- tab1[,c("Diagnostic date","Case", "Source of infection", "Status")]
        
        output$table <- DT::renderDataTable(server = T, {
            DT::datatable(tab1, rownames = F, 
                          extensions = 'Buttons', 
                          options = list(dom = 'Bfrtip',pageLength = 15,
                                         buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
        })
        
        
        output$dygraph <- renderDygraph({
            dygraph(#main = "Romania - daily new confirmed and recovered cases of COVID-19",
                data.table::data.table(cases.day),  ylab = "Number of cases") %>%
                dySeries("case_no", label = "Cases", color = "red") %>%
                dySeries("recover_no", label = "Recovered", color  = "green") %>%
                dySeries("death_no", label = "Deaths", color  = "#636363") %>%
                dyOptions(stackedGraph = T) %>%
                dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 25, max(dats.nod)))
        })
        
        output$dygraph1 <- renderDygraph({
            dygraph(#main = "Romania - daily new confirmed and recovered cases of COVID-19",
                data.table::data.table(cum.day[,c(1,5,6,7)]),  ylab = "Overall number of cases") %>%
                dySeries("cum_sum", label = "Cases", color = "red") %>%
                dySeries("recover_sum", label = "Recovered", color  = "green") %>%
                dySeries("death_sum", label = "Deaths", color  = "#636363") %>%
                dyOptions(stackedGraph = T) %>%
                dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 25, max(dats.nod)))
        })
        
        
        # histogram
        # vertical line
        
        source(file = "R/plotly.funct.R", local = T)
        
        x <- list(
            title = "Ages bins (five years intervals)",
            titlefont = f
        )
        y <- list(
            title = "Counts",
            titlefont = f
        )
        
        mean.cont <-  round(mean(na.omit(nodes$age)))
        output$hist <- plotly::renderPlotly({
            fig <- plotly::plot_ly(x = na.omit(nodes$age), type = "histogram",
                                   xbins = list(end = 90, size = 5, start = 1),
                                   nbinsx = 10
                                   )
            
            fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                          shapes = list(plotly.vline(x = mean.cont, y = 0.95)),
                                          annotations = plotly.vtext(x = mean.cont, y = 10))
            fig
        })
        
        mean.recov <- round(mean(na.omit(nodes$age[nodes$status == "Recovered"])))
        
        output$hist.recov <- plotly::renderPlotly({
            fig <- plotly::plot_ly(x = na.omit(nodes$age[nodes$status == "Recovered"]), type = "histogram",
                                   xbins = list( end = 90, size = 5, start = 1)
                                   ) 
            
            fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                          shapes = list(plotly.vline(x = mean.recov, y = 0.95)),
                                          annotations = plotly.vtext(x = mean.recov, y = 2))
            fig
        })
        
        mean.decs <- round(mean(na.omit(nodes$age[nodes$status == "Death"])))
        
        output$hist.decs <- plotly::renderPlotly({
            fig <- plotly::plot_ly(x = na.omit(nodes$age[nodes$status == "Death"]), type = "histogram",
                                   xbins = list( end = 90,   size = 5, start = 1))
            fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                          shapes = list(plotly.vline(x = mean.decs, y = 0.95)),
                                          annotations = plotly.vtext(x = mean.decs, y = 1))
            fig
        })
        
        output$hist2 <- plotly::renderPlotly({
            # country of infection
            fig2 <- plotly::plot_ly(countr.inf, x = ~Country, 
                                    y = ~Counts, type = 'bar') %>%
                plotly::layout(
                    xaxis = list(title = "",
                                 categoryorder = "total descending"),
                    yaxis = list(title = "Counts")
                )
            
            fig2 
        })
        
        
        cum.dayf <- cum.day %>% dplyr::filter(diagnostic_date  > as.Date("2020-02-25"))
        
        names(cum.dayf) <- c("Date", "Currently confirmed", "Recovered","Deaths", "Cumulative confirmed", "Cumulative recovered", "Cumulative deaths")
        
        output$cum <-  DT::renderDataTable(server = T, {
            DT::datatable(cum.dayf, rownames = F, 
                          extensions = 'Buttons', 
                          options = list(dom = 'Bfrtip',pageLength = 15,
                                         buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
        })
        
    
    })
    
}

#### UI ####

ui <- shinyUI(
    
    ui <- function(req) { 
        fluidPage(
            tags$head(includeHTML(("google-analytics.html"))),
            
            navbarPage("Romania COVID-19", collapsible = T, fluid = T,
                       
                       tabPanel("Statistics & Facts",
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
                                            tabPanel("Plots",
                                                     fluidRow(
                                                         h3("Romania COVID-19 Statistics & Facts"),
                                                         h4(first.case),
                                                         column(6,
                                                                
                                                                h4("Daily confirmed, recovered and death cases", style = "text-align:center;"),
                                                                
                                                                dygraphOutput("dygraph"),
                                                                
                                                         ),
                                                         column(6,
                                                                h4("Overall confirmed, recovered and death cases", style = "text-align:center;"),
                                                                dygraphOutput("dygraph1")
                                                                
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
                       ),
                       tabPanel("Spread network",
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
                       ),
                       
                       tabPanel("About",
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
                                        
                                    ),mainPanel(
                                        p("This web site aims to provide accurate and relevant facts and statistics about COVID-19 spread in Romania."),
                                        ("The analysis is based on data provided by covid19.geo-spatial.org.")
                                        
                                        
                                    )
                                )
                       )   )
        )
    }
)

#### Run ####





shinyApp(ui = ui, server = server)