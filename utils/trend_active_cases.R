trend.cases <- cases.day

trend.cases[is.na(trend.cases)] <- 0


trend.cases <- trend.cases %>% 
  dplyr::mutate(active_no = case_no - recover_no - death_no)  %>%
  dplyr::mutate(gain_no  = dplyr::lag(active_no, default = 0))




gain <- trend.cases$active_no
for (i in 2:length(gain)) {
  
  gain[i] <- gain[i] - gain[i -  1]
  
  #ifelse(gain.i > 0, gain[i] <- gain.i, gain[i] <- gain[i - 1])
  
}



plot(gain, type = "l")
lines(trend.cases$death_no)
