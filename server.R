#### Server ####
#source("global.R", local = T)
server <- function(input, output, session) {
  
  source(file = "utils/map.R", local = T)
  
  observe({
    #url tabs
    source(file = "utils/tabs_url.R", local = T)
    
# 
#     nodes$case_no <- paste("#", nodes$case_no)
#     nodes$Group <- links$source
#     nodes$Nodesize <- 5
# 
#     links <- links - 1
#     links$value <- 4
# 
# 
#     output$force <- renderForceNetwork({
# 
#       forceNetwork(Links = links, Nodes = nodes,
#                    Source = "source", Nodesize = "Nodesize",
#                    Target = "target", Value = "value", NodeID = "case_no",
#                    Group = "source_no", zoom = T, arrows = T, legend = F,
#                    bounded = F,  linkColour = "black", opacity = 1, opacityNoHover = 1,
#                    fontSize = 14, charge = -15, fontFamily = "arial",
#                    height = 280, width = 280, linkDistance = 60)
#     })
    
    # nodes$source_no[is.na(nodes$source_no) & !is.na(nodes$country_of_infection) & nodes$country_of_infection != "România"] <- nodes$country_of_infection[is.na(nodes$source_no) & !is.na(nodes$country_of_infection) & nodes$country_of_infection != "România"]
    # 
    # tab1 <- nodes[,1:4]
    # tab1$source_no[is.na(tab1$source_no)] <- "Unknown"
    # 
    # # add leading zero
    # tab1$source_no[grep("[[:digit:]]+", tab1$source_no)] <- paste0("#",  sprintf("%03s", tab1$source_no[grep("[[:digit:]]+", tab1$source_no)]))
    # tab1$case_no <- paste0("#",sprintf("%03s",as.numeric(gsub("#", "",tab1$case_no))))
    # tab1$diagnostic_date <- as.Date(tab1$diagnostic_date, "%d-%m-%Y")
    # 
    # names(tab1) <- c("Case", "Source of infection", "Status", "Diagnostic date")
    # tab1 <- tab1[,c("Diagnostic date","Case", "Source of infection", "Status")]
    # 
    # output$table <- DT::renderDataTable(server = T, {
    #   DT::datatable(tab1, rownames = F, 
    #                 extensions = 'Buttons', 
    #                 options = list(dom = 'Bfrtip',pageLength = 15,
    #                                buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
    # })
    # 
    
    output$dygraph <- renderDygraph({
      dygraph(#main = "Romania - daily new confirmed and recovered cases of COVID-19",
        data.table::data.table(cases.day),  ylab = "Number of cases") %>%
        dySeries("case_no", label = "Cases", color = "red") %>%
        dySeries("recover_no", label = "Recovered", color  = "green") %>%
        dySeries("death_no", label = "Deaths", color  = "#636363") %>%
        dyOptions(stackedGraph = T) %>%
        dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 40, max(dats.nod)))
      
    })
    
    output$dygraph1 <- renderDygraph({
    
     
      p <- dygraph(#main = "Romania - daily new confirmed and recovered cases of COVID-19",
        data.table::data.table(cum.day[,c(1,5,6,7)])) 
       p2 <- p %>% dySeries("cum_sum", label = "Cases", color = "red") %>%
        dySeries("recover_sum", label = "Recovered", color  = "green") %>%
        dySeries("death_sum", label = "Deaths", color  = "#636363")  %>%
        dyAxis("y", drawGrid = T,  label = "Overall number of cases") %>%
        dyOptions(stackedGraph = T) %>%
        dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 40, max(dats.nod)))
      
      if (input$checkbox_logCaseEvolution) {
       p2 <-p %>% dySeries("cum_sum", label = "Cases", color = "red") %>%
         dySeries("recover_sum", label = "Recovered", color  = "green") %>%
         dySeries("death_sum", label = "Deaths", color  = "#636363")  %>%
         dyAxis("y", drawGrid = T, logscale = T, label = "Overall number of cases  (log scale)") %>%
         dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 40, max(dats.nod)))
     
      }
    
      return(p2)
    })
    
    
    # histogram
    # vertical line
    
    source(file = "utils/plotly.funct.R", local = T)
    
    x <- list(
      title = "Ages bins (five years intervals)",
      titlefont = f
    )
    y <- list(
      title = "Counts",
      titlefont = f
    )
    
    mean.cont <-  round(mean(na.omit(nodes$Vârsta)))
    output$hist <- plotly::renderPlotly({
      fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta), type = "histogram",
                             xbins = list(end = 90, size = 5, start = 1),
                             nbinsx = 10
      )
      
      fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                    shapes = list(plotly.vline(x = mean.cont, y = 0.95)),
                                    annotations = plotly.vtext(x = mean.cont, y = 20))
      fig
    })
    
    mean.recov <- round(mean(na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Da"])))
    
    output$hist.recov <- plotly::renderPlotly({
      fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Da"]), type = "histogram",
                             xbins = list( end = 90, size = 5, start = 1)
      ) 
      
      fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                    shapes = list(plotly.vline(x = mean.recov, y = 0.95)),
                                    annotations = plotly.vtext(x = mean.recov, y = 10))
      fig
    })
    
    mean.decs <- round(mean(na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Nu"])))
    
    output$hist.decs <- plotly::renderPlotly({
      fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Nu"]), type = "histogram",
                             xbins = list( end = 90,   size = 5, start = 1))
      fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                    shapes = list(plotly.vline(x = mean.decs, y = 0.95)),
                                    annotations = plotly.vtext(x = mean.decs, y = 15))
      fig
    })
    
    output$hist2 <- plotly::renderPlotly({
      # country of infection
      fig2 <- plotly::plot_ly(countr.inf[countr.inf$Country != "România",], x = ~Country, 
                              y = ~Counts, type = 'bar') %>%
        plotly::layout(
          xaxis = list(title = "", tickangle = 30,
                       categoryorder = "total descending"),
          yaxis = list(title = "Counts")
        )
      
      fig2 
    })
    
    
    cum.dayf <- cum.day %>% dplyr::filter(diagnostic_date  > as.Date("2020-02-25"))
    
    names(cum.dayf) <- c("Date", "Currently confirmed", "Recovered","Deaths", "Cumulative confirmed", "Cumulative recovered", "Cumulative deaths")
    
    output$cum <-  DT::renderDataTable(server = F, {
      DT::datatable(cum.dayf, rownames = F, 
                    extensions = 'Buttons', 
                    options = list(dom = 'Bfrtip',pageLength = 15,
                                   buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
    })
    
    
    
    
    
    
  })
  
}
