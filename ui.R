#### UI ####
source("sections/ui_about.R", local = T)
#source("sections/ui_spread.R", local = T)
source("sections/ui_facts.R", local = T)
source("sections/ui_maps.R", local = T)
#source("sections/general_statistics.R")
ui <- shinyUI(
  
  ui <- function(req) { 
    fluidPage(
      tags$head(includeHTML(("google-analytics.html"))),
      
    
      
      navbarPage("Romania COVID-19", collapsible = T, fluid = T,id = "tabs",
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
