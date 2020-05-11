#### Server ####
#source("global.R", local = T)
server <- function(input, output, session) {
  # shinyjs::addClass(id = "tabs", class = "navbarpage-right")
  
  source(file = "sections/maps/map.R", local = T)
  # no 2 maps
  source(file = "sections/no2/no2_actual.R", local = T)
  source(file = "sections/no2/no2_climate.R", local = T)
 
  
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
        data.table::data.table(daily.cases.days),  ylab = "Number of cases") %>%
        dySeries("Cazuri", label = "Cases", color = "red", stepPlot   = T, strokeWidth = 2) %>%
        dySeries("vindecati_daily", label = "Recovered", color  = "green", stepPlot   = T, strokeWidth = 2) %>%
        dySeries("Morti pe zi", label = "Deaths", color  = "#636363", stepPlot   = T, strokeWidth = 2) %>%
        dyOptions(stackedGraph = T) %>%
        dyLegend(show = "follow") %>%
        dyRangeSelector(height = 40, dateWindow = c(max(as.Date(daily.cases.days$Data)) - 70, as.Date(max(daily.cases.days$Data))))
      
    })
    
    output$dygraph1 <- renderDygraph({
      
      p <- dygraph(#main = "Romania - daily new confirmed and recovered cases of COVID-19",
        data.table::data.table(daily.cases.cum))
      p2 <- p %>% dySeries("Total", label = "Cases", color = "red", strokeWidth = 2) %>%
        dySeries("Vindecati", label = "Recovered", color  = "green", strokeWidth = 2) %>%
        dySeries("Morti", label = "Deaths", color  = "#636363", strokeWidth = 2)  %>%
        dyAxis("y", drawGrid = T,  label = "Overall number of cases") %>%
        dyEvent("2020-03-05", "The first recovered cases reported", labelLoc = "top") %>%
        dyEvent("2020-03-22", "The first death cases reported", labelLoc = "top") %>%
        dyOptions(stackedGraph = T, mobileDisableYTouch  = T) %>%
        dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 70, max(dats.nod)))
      
      if (input$checkbox_logCaseEvolution) {
        p2 <- p %>% dySeries("Total", label = "Cases", color = "red", fillGraph = T,  strokeWidth = 2) %>%
          dySeries("Vindecati", label = "Recovered", color  = "green", fillGraph = T,  strokeWidth = 2) %>%
          dySeries("Morti", label = "Deaths", color  = "#636363", fillGraph = T,  strokeWidth = 2)  %>%
          dyLegend(show = "follow") %>%
          # dyHighlight(highlightCircleSize = 5, 
          #             highlightSeriesBackgroundAlpha = 0.2,
          #             hideOnMouseOut = FALSE) %>%
          dyAxis("y", drawGrid = T, logscale = T, label = "Overall number of cases  (log scale)") %>%
          dyEvent("2020-03-05", "The first recovered cases reported", labelLoc = "top") %>%
          dyEvent("2020-03-22", "The first death cases reported", labelLoc = "top") %>%
          dyRangeSelector(height = 40, dateWindow = c(max(dats.nod) - 70, max(dats.nod))) 
      }
      
      return(p2)
    })
    
    
    # histogram
    # vertical line
    
    source(file = "utils/plotly.funct.R", local = T)
    
    x <- list(
      title = "Ages bins (five years intervals)",
      titlefont = f,
      fixedrange = TRUE
    )
    y <- list(
      title = "Counts",
      titlefont = f,
      fixedrange = TRUE
    )
    
    mean.cont <-  round(mean(na.omit(nodes$Vârsta)))
    output$hist <- plotly::renderPlotly({
      fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta), type = "histogram",
                             xbins = list(end = 90, size = 5, start = 1),
                             nbinsx = 10,
                             marker = list(colors = c( "#fc4e2a","#e31a1c", "green","#636363"),
                                           line = list(color = '#FFFFFF', width = 1))
      )
      
      fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                    shapes = list(plotly.vline(x = mean.cont, y = 0.95)),
                                    annotations = plotly.vtext(x = mean.cont, y = 60)) %>%
        plotly::config(displaylogo = FALSE,
        modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d", "lasso2d","handleCartesian",
                                   "select2d", "autoScale2d", "resetScale2d", "hoverClosestCartesian"))
      
      fig
    })
    
    mean.recov <- round(mean(na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Da"])))
    
    # output$hist.recov <- plotly::renderPlotly({
    #   fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Da"]), type = "histogram",
    #                          xbins = list( end = 90, size = 5, start = 1)
    #   ) 
    #   
    #   fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
    #                                 shapes = list(plotly.vline(x = mean.recov, y = 0.95)),
    #                                 annotations = plotly.vtext(x = mean.recov, y = 15))
    #   fig
    # })
    
    
    daily.cases.pie <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
      dplyr::select("Data","Total", "Vindecati", "Morti", "Terapie intensiva") %>%
      dplyr::filter_all(dplyr::all_vars(!is.na(.)))
    
    plotly.pie <- daily.cases.pie[nrow(daily.cases.pie),]
    plotly.pie$Active <- plotly.pie$Total - plotly.pie$Vindecati - plotly.pie$Morti - plotly.pie$`Terapie intensiva`
    plotly.pie <- as.data.frame(t(cbind(Active = plotly.pie$Active, Critical = plotly.pie$`Terapie intensiva`, Recovered = plotly.pie$Vindecati, Deceased = plotly.pie$Morti)))
    names(plotly.pie) <- "cases"
    
    
    fig.pie <- plotly.pie %>% plotly::plot_ly(labels = c( "Active", "Active Critical (intensive care)","Recovered", "Deceased"), values = ~cases,
                                      marker = list(colors = c( "#fc4e2a","#e31a1c", "green","#636363"),
                                                    line = list(color = '#FFFFFF', width = 1))) %>% 
      plotly::add_pie(hole = 0.6) %>% 
      plotly::layout(legend = list(orientation = "h",   # show entries horizontally
                           xanchor = "center",  # use center of legend as anchor
                           x = 0.5),
                     annotations = list(text = paste("Total cases", sum(plotly.pie$cases)), "showarrow" = F,
                                        font = list(color = 'red'))
                    )
    output$pie_breakdown <- plotly::renderPlotly({
      fig.pie
    })
    
    
    
    
    mean.decs <- round(mean(na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Nu"])))
    
    output$hist.decs <- plotly::renderPlotly({
      fig <- plotly::plot_ly(x = na.omit(nodes$Vârsta[!is.na(nodes$Vindecat) & nodes$Vindecat == "Nu"]), type = "histogram",
                             xbins = list( end = 90,   size = 5, start = 1),
                             marker = list(colors = c( "#fc4e2a","#e31a1c", "green","#636363"),
                                           line = list(color = '#FFFFFF', width = 1)))
      fig <- fig %>% plotly::layout(xaxis = x, yaxis = y,
                                    shapes = list(plotly.vline(x = mean.decs, y = 0.95)),
                                    annotations = plotly.vtext(x = mean.decs, y = 60)) %>%
        plotly::config(displaylogo = FALSE,
                       modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d", "lasso2d","handleCartesian",
                                                  "select2d", "autoScale2d", "resetScale2d", "hoverClosestCartesian"))
      
      fig
    })
    
    output$hist2 <- plotly::renderPlotly({
      # country of infection
      fig2 <- plotly::plot_ly(countr.inf[countr.inf$Country != "România",], x = ~Country, 
                              y = ~Counts, type = 'bar',
                              marker = list(colors = c( "#fc4e2a","#e31a1c", "green","#636363"),
                                            line = list(color = '#FFFFFF', width = 1))) %>%
        plotly::layout(
          xaxis = list(title = "", tickangle = 30,
                       categoryorder = "total descending",
                       fixedrange = TRUE),
          yaxis = list(title = "Counts", fixedrange = TRUE)) %>%
        plotly::config(displaylogo = FALSE,
                       modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d", "lasso2d","handleCartesian",
                                                  "select2d", "autoScale2d", "resetScale2d", "hoverClosestCartesian"))
      
        
      
      fig2 
    })
    
    
    cum.dayf <- dplyr::left_join(daily.cases.days, daily.cases.cum, by = "Data") %>%
                dplyr::mutate(Data = as.Date(Data))
      
    
    names(cum.dayf) <- c("Date", "Currently confirmed", "Recovered","Deaths", "Cumulative confirmed", "Cumulative recovered", "Cumulative deaths")
    
    output$cum <-  DT::renderDataTable(server = F, 
                                       DT::datatable(cum.dayf, rownames = F, 
                                                     extensions = c('Buttons',"Responsive"), 
                                                     options = list(dom = 'Bfrtip',pageLength = 15,
                                                                    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
    )
    
    
    
  })
  
  
}
