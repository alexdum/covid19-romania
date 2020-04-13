counties <- read.csv("data/counties_centroids.csv", stringsAsFactors = F)
names(counties)[c(3,16,17)] <- c("county", "longitude", "latitude")
counties <- counties %>% dplyr::select(c("county", "longitude", "latitude")) 

# cases -------------------------------------------------------------------

cases.day.county <- nodes %>% dplyr::filter(!is.na(`ID`), `Dată diagnostic` <= Sys.time() & `Dată diagnostic` >= as.POSIXct("2020-02-26"))
cases.day.county <- aggregate(ID~`Dată diagnostic`+Județ, FUN = length, data = cases.day.county)
names(cases.day.county) <- c("case_date","county", "case_no")

# toate cazurile chiar cand nu ai mai avut caz raportat in ziua respectiva
cases.indexing <- tidyr::crossing(case_date = seq(min(cases.day.county$case_date),max(cases.day.county$case_date) , "days"),
                                                      county = cases.day.county$county)
cases.day.county <- dplyr::full_join(cases.day.county,cases.indexing, by = c("case_date", "county")) %>%
  dplyr::mutate(case_no =  ifelse(is.na(case_no),0, case_no))

cases.day.county <- cases.day.county[order(cases.day.county$case_date, cases.day.county$county ),]
cases.day.county.f <- cases.day.county %>% dplyr::group_by(county) %>%
  dplyr::mutate(case_sum =  cumsum(case_no)) 

# deceased--------------------------------------------------------------

death.day.county <- nodes %>% dplyr::filter(!is.na(`Dată deces`), `Dată deces` <= Sys.time() & `Dată deces` >= as.POSIXct("2020-03-22"))
death.day.county <- aggregate(ID~`Dată deces`+Județ, FUN = length, data = death.day.county)
names(death.day.county) <- c("death_date","county", "death_no")

death.indexing <- tidyr::crossing(death_date = death.day.county$death_date, county = death.day.county$county)
death.day.county <- dplyr::full_join(death.day.county, death.indexing, by = c("death_date", "county")) %>%
  dplyr::mutate(death_no =  ifelse(is.na(death_no),0, death_no))

death.day.county <- death.day.county[order(death.day.county$death_date, death.day.county$county ),]
death.day.county.f <- death.day.county %>% dplyr::group_by(county) %>%
  dplyr::mutate(death_sum =  cumsum(death_no)) 



# final file ---------------------------------------------s-----------------
# counties <- merge(counties, death.day.county.f, by.x = "name", by.y = "county")

counties <- counties %>%
  dplyr::left_join(cases.day.county.f, by = "county") %>%
  dplyr::left_join(death.day.county.f, by = c("county" = "county", "case_date" = "death_date")) %>%
  dplyr::mutate(death_no =  ifelse(is.na(death_no), 0, death_no)) %>%
  dplyr::mutate(death_sum =  ifelse(is.na(death_sum),0, death_sum)) %>%
  dplyr::mutate(case_date = as.Date(case_date)) 
# %>%
#   
counties2 <- counties %>% dplyr::filter(case_date >= as.Date("2020-03-22") & case_date <= as.Date(max(nodes$`Dată deces`, na.rm = T)))


# counties <- counties[counties$death_sum > 0,]
counties.latest <- counties[counties$case_date == max(counties$case_date), ]

# for deceased map
counties.latest2 <- counties2[counties2$case_date == as.Date(max(nodes$`Dată deces`, na.rm = T)), ]




