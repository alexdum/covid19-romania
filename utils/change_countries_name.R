
# # ajusteaza tu data primul deces
# nodes$death_date <- as.Date("2020-03-21") + as.numeric(gsub("-", "", substr(nodes$death_date,1,2)))
# mean(nodes$age[nodes$status == "Death"])
# https://www.hotnews.ro/stiri-coronavirus-23756088-coronavirus-romania-numarul-deceselor-ajuns-24-ultimul-pacient-femeie-80-ani-din-bacau.htm


# schimba numele tarilor din engleza in romana
# unique(nodes$country_of_infection)
#nodes[nodes$status == "Decedat",]

nodes[nodes$case_no == 572,"death_date"] <- "2020-03-29"
nodes[nodes$case_no == 1029,"death_date"] <- "2020-03-29"


cori <- c("Austria?", "România", "Italia", "Israel", "Marea Britanie","Germania", "Polonia", "SUA","Dubai","Franța", "Norvegia","Spania" ,"Romania", "Franta","Belgia")
cnew <- c("Austria", "Romania","Italy","Israel","UK", "Germany", "Polond", "USA" ,"Dubai", "France", "Norway","Spain","Romania","France", "Belgium")

# cbind(cori, cnew)

for (i in 1:length(cori)) nodes$country_of_infection[nodes$country_of_infection == cori[i]] <- cnew[i]


unique(nodes$status)
nodes$status[nodes$status == "Confirmat"] <- "Confirmed"
nodes$status[nodes$status == "Vindecat"] <- "Recovered"
nodes$status[nodes$status == "Decedat"] <- "Death"

