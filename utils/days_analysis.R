

daily.cases <- readRDS("data/daily.cases.rds")

daily.latest <- read_sheet("1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ",
                          sheet =  "Cazuri noi pe zile")

# conditii care trebuie indeplinite pentru a scrie fisierul
if (daily.latest$Morti[nrow(daily.latest)] != daily.cases$Morti[nrow(daily.cases)]  |
    daily.latest$Vindecati[nrow(daily.latest)] != daily.cases$Vindecati[nrow(daily.cases)] |
    daily.latest$Cazuri[nrow(daily.latest)] != daily.cases$Cazuri[nrow(daily.cases)] ) {
  
  saveRDS(daily.latest, "data/daily.cases.rds")
  daily.cases <- daily.latest
} 


daily.cases.days <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
              dplyr::select("Data","Cazuri", "vindecati_daily", "Morti pe zi")


daily.cases.cum <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
  dplyr::select("Data","Total", "Vindecati", "Morti")

