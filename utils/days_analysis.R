

daily.cases <- readRDS("data/daily.cases.rds")

daily.latest <- read_sheet("1YxwFui0_HdcCT5ej6TuXACUUk42sButQfC563m0aPlQ",
                           sheet =  "Cazuri noi pe zile")

# conditii care trebuie indeplinite pentru a scrie fisierul
if (daily.latest$Morti[sum(!is.na(daily.latest$Morti))] != daily.cases$Morti[sum(!is.na(daily.cases$Morti))]  |
    daily.latest$Vindecati[sum(!is.na(daily.latest$Vindecati))] != daily.cases$Vindecati[sum(!is.na(daily.cases$Vindecati))] |
    daily.latest$Cazuri[sum(!is.na(daily.latest$Cazuri))] != daily.cases$Cazuri[sum(!is.na(daily.cases$Cazuri))] ) {
  
  saveRDS(daily.latest, "data/daily.cases.rds")
  daily.cases <- daily.latest
} 

daily.cases <- daily.cases %>% dplyr::filter(!is.na(Data))

daily.cases.days <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
                  dplyr::select("Data","Cazuri", "vindecati_daily", "Morti pe zi") %>%
                dplyr::filter_all(dplyr::all_vars(!is.na(.))) # elimina randurile cu NA


daily.cases.cum <- daily.cases %>% dplyr::mutate(vindecati_daily = Vindecati - dplyr::lag(Vindecati, default = Vindecati[1]) ) %>%
  dplyr::select("Data","Total", "Vindecati", "Morti") %>%
  dplyr::filter_all(dplyr::all_vars(!is.na(.))) # elimina randurile cu NA

