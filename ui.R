#### UI ####
source("sections/ui_about.R", local = T)
#source("sections/ui_spread.R", local = T)
source("sections/ui_facts.R", local = T)
source("sections/ui_maps.R", local = T)
#source("sections/general_statistics.R")

# meta tags https://rdrr.io/github/daattali/shinyalert/src/inst/examples/demo/ui.R
ui <- shinyUI(
  
  ui <- function(req) { 
    fluidPage(theme = shinytheme("cosmo"),
              tags$head(
                includeHTML("google-analytics.html"),
                tags$style(type = "text/css", "body {padding-top: 70px;}"),
                # pentru leaflet
                tags$meta(charset = "UTF-8"),
                tags$meta(name = "description", content = "Relevant facts and statistics about COVID-19 spread in Romania."),
                tags$meta(name = "keywords", content = "COVID-19, Romania, spread maps, relevant graphs"),
                tags$meta(name = "author", content = "Alexandru Dumitrescu"),
                tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0")
              ),
              useShinyjs(),
              navbarPage("Romania COVID-19", collapsible = T, fluid = T, id = "tabs", position =  "fixed-top",
                         selected = "#about",
                         
                         # Statistics & Facts ------------------------------------------------------
                         facts_ui,
                         
                         # maps ------------------------------------------------------
                         maps_ui,
                         
                         # Spread network ----------------------------------------------------------
                         # spread_ui,
                         
                         # About -------------------------------------------------------------------
                         about_ui
              )
    )
  }
)
