suppressPackageStartupMessages({
  library(shiny)
  library(shinyjs)
  library(shinydashboard)
  library(shinythemes)
  #library(networkD3)
  library(curl)
  library(dygraphs)
  library(leaflet)
  library(googlesheets4)
  library(ncdf4)
  library(rgdal, quietly = T)
  library(shinyWidgets)
})
options(gargle_oob_default = TRUE, gargle_oauth_email = "alexandru.dumitrescu@gmail.com",
        gargle_oauth_cache = ".secrets")
# https://www.r-bloggers.com/visualizing-geo-spatial-data-with-sf-and-plotly/
# https://towardsdatascience.com/top-5-r-resources-on-covid-19-coronavirus-1d4c8df6d85f
# https://towardsdatascience.com/create-a-coronavirus-app-using-r-shiny-and-plotly-6a6abf66091d
# https://github.com/eparker12/nCoV_tracker
# https://deanattali.com/
# https://www.rivm.nl/en/novel-coronavirus-covid-19/current-information-about-novel-coronavirus-covid-19
#relation.cases <- jsonlite::fromJSON("https://covid19.geo-spatial.org/api/statistics/getCaseRelations")
# url <-  jsonlite::fromJSON("https://services.arcgis.com/IjJbzDQF4hOiNl87/ArcGIS/rest/services/COVID_19_tabel_view/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token=")



# latest.cases <- sheets_get("https://docs.google.com/spreadsheets/d/1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ/edit?usp=sharing_eil&ts=5e811597")
# read_sheet("https://docs.google.com/spreadsheets/d/1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ/edit?usp=sharing_eil&ts=5e811597")
#sheeturl <- "https://docs.google.com/spreadsheets/d/1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ/edit?usp=sharing_eil&ts=5e811597"
#sheets_auth(path=sheeturl)

# bring your own app via JSON downloaded from Google Developers Console
# this file has the same structure as the JSON from Google
# sheets_auth(scopes = "https://www.googleapis.com/auth/spreadsheets.readonly")

try(silent = T,
    latest.cases <- read_sheet("1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ", sheet = "Cazuri")
)

names(latest.cases)[1]  <-  "ID"

relation.cases <- readRDS("www/data/relation.cases.rds")

# conditii care trebuie indeplinite pentru a scrie fisierul
if (sum(!is.na(latest.cases$`Dată diagnostic`)) > sum(!is.na(relation.cases$`Dată diagnostic`)) |
    sum(latest.cases$Vindecat[!is.na(latest.cases$Vindecat)] == "Da") > sum(relation.cases$Vindecat[!is.na(relation.cases$Vindecat)] == "Da") |
    sum(!is.na(latest.cases$`Dată deces`)) > sum(!is.na(relation.cases$`Dată deces`))) {
  
  saveRDS(latest.cases, "www/data/relation.cases.rds")
  relation.cases <- latest.cases
} 

nodes <- relation.cases
nodes <- nodes[!is.na(nodes$ID),]

nodes <- nodes[order(nodes$ID),]
#links <- relation.cases$data$links

# situatiile cand nu sunt trecute datele
nodes <- nodes %>% dplyr::filter(!is.na(`Dată diagnostic`))
# pentru data
dats.nod <- as.Date(unique(as.character(nodes$`Dată diagnostic`)))

# days analysis -----------------------------------------------------------

source(file = "utils/days_analysis.R", local = T)

# facts data --------------------------------------------------------------

# pentru situația la zi
#infect <- length(nodes$status[nodes$status == "Confirmat"])
infect <- length(nodes$`Dată diagnostic`)
recov <- daily.cases$Vindecati[daily.cases$Data == max(daily.cases$Data)]
updd <- dats.nod[length(dats.nod)]
decs <-  daily.cases$Morti[daily.cases$Data == max(daily.cases$Data)]

# time series plots
cases.day <- aggregate(ID~`Dată diagnostic`,FUN = length, data = nodes)
cases.day$diagnostic_date <- as.Date(cases.day$`Dată diagnostic`)
cases.day <- cases.day[order(cases.day$diagnostic_date),]
names(cases.day)[2] <- "case_no"

recover.day <- nodes %>% dplyr::filter(!is.na(Vindecat), Vindecat == "Da")
recover.day <- aggregate(ID~`Dată vindecare`,FUN = length, data = recover.day)
recover.day$healing_date <- as.Date(recover.day$`Dată vindecare`)
names(recover.day)[2] <- "recover_no"

death.day <- nodes %>% dplyr::filter(!is.na(`Dată deces`),`Dată deces` <= Sys.time() & `Dată deces` >= as.POSIXct("2020-03-22"))
death.day <- aggregate(ID~`Dată deces`,FUN = length, data = death.day)
death.day$death_date <- as.Date(death.day$`Dată deces`)
names(death.day)[2] <- "death_no"

# completeaza cu toate datele petru ts plot si uneste cu toate
cases.day <- merge(cases.day, data.frame(diagnostic_date = seq(min(dats.nod) , max(dats.nod), "days")), all = T)
cases.day <- merge(cases.day, recover.day, all = T, by.x = "diagnostic_date", by.y = "healing_date")
cases.day <- merge(cases.day, death.day, all = T, by.x = "diagnostic_date", by.y = "death_date")
cases.day <- cases.day[, c("diagnostic_date","case_no","recover_no","death_no")]

# cumulative sum
cum.day <- cases.day
cum.day[is.na(cum.day)] <- 0
cum.day <- cum.day %>% 
  dplyr::mutate(cum_sum = cumsum(case_no),recover_sum = cumsum(recover_no), death_sum =  cumsum(death_no)) 


# county analysis ---------------------------------------------------------

source(file = "utils/counties_analysis.R", local = T)



# statistics and facts ----------------------------------------------------

county.first <- nodes[as.Date(nodes$`Dată diagnostic`) == "2020-02-26",]
first.case <- paste("The first infection case reported on", format(min(dats.nod), "%b %d, %Y"), "in", stringr::str_to_title(county.first$Județ),"county.")

# https://www.worldometers.info/coronavirus/coronavirus-death-rate/
cfr <- paste0("The crude fatality ratio in Romania (mortality rate) is ", round(decs * 100/infect,1), 
              "%, as computed from the data available between ", format(min(dats.nod), "%B %d, %Y"), " to ", format(max(dats.nod),"%B %d, %Y"),".")

# country of infection
countr.infection <- nodes$`Țara probabilă de infectare`
countr.infection[is.na(countr.infection)] <- "Unknown"
countr.infection[countr.infection == "Anglia"] <- "Marea Britanie"
countr.infection <- as.data.frame(table(countr.infection), stringsAsFactors = F)
names(countr.infection) <- c("Country", "Counts")

countr.inf <- countr.infection %>% dplyr::filter(!Country %in% c("Romania", "Unknown")) %>%
  dplyr::arrange(desc(Counts))


# map no2 actual ----------------------------------------------------------

omi.act <- raster::stack("www/data/OMI-Aura/OMI-Aura_L3-OMNO2d_monthly.nc")
omi.act <- omi.act/10^15  
dats.act <- as.Date(names(omi.act), "X%Y.%m.%d")

omi.act[omi.act > 8] <- 8
omi.act[omi.act < 2] <- 2
