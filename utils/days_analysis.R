

daily.cases <- readRDS("data/daily.cases.rds")

daily.latest <- read_sheet("1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ",
                          sheet =  "Cazuri noi pe zile")

# conditii care trebuie indeplinite pentru a scrie fisierul
if (sum(!is.na(daily.latest$Data)) > sum(!is.na(daily.cases$Data)) |
    sum(!is.na(daily.latest$Vindecati)) > sum(!is.na(daily.latest$Vindecati)) |
    sum(!is.na(daily.latest$Cazuri)) > sum(!is.na(daily.cases$Cazuri)) ) {
  
  saveRDS(daily.latest, "data/daily.cases.rds")
  daily.cases <- daily.latest
} 


daily.cases.days <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
              dplyr::select("Data","Cazuri", "vindecati_daily", "Morti pe zi")


daily.cases.cum <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
  dplyr::select("Data","Total", "Vindecati", "Morti")

