
library(tidyverse)

# setwd("~/Github/virion")

setwd(here::here())

source("./Code/00 - taxize-cleaner-clone.R")

# Read in host data

unzip("./Source/GenBank_as_Edgelist.zip", exdir = 'Source')
gb <- data.table::fread("./Source/GenBank_as_Edgelist.csv")
gb %>% as_tibble -> gb
hosts_vec <- unique(na.omit(gb$Host))
synonyms <- lapply(1:length(hosts_vec), findSyns3)
synonyms %>% bind_rows() -> host.dictionary

write_rds(host.dictionary, "./Intermediate/HostDictionary.RDS")

# Double check if the dictionary needs expansion

dict2 <- data.frame(Original = hosts_vec)
dict2 %>% 
  as_tibble %>%
  left_join(host.dictionary) -> dict2

for (i in 1:nrow(dict2)) {
if(dict2$Original[i] %in% dict2$Synonyms) {
  dict2$Accepted_name[i] <- dict2$Acepted_name[which(dict2$Synonyms == dict2$Original[i])]
  print(i)
}
}
# Didn't print any - which is a good sign!

gb2 <- left_join(gb, host.dictionary, by = c('Host' = 'Original'))

gb2 %>% filter(Selected_class %in% c("Mammalia",
                                     "Aves",
                                     "Reptilia",
                                     "Amphibia",
                                     "Chondrichthyes",
                                     "Elasmobranchii")) %>% 
  select(Species, Accepted_name, Selected_family, Selected_order, Selected_class) %>%
  dplyr::rename(Virus = Species,
                Host = Accepted_name,
                HostFamily = Selected_family,
                HostOrder = Selected_order,
                HostClass = Selected_class) %>%
  unique() -> gb2


data.table::fwrite(gb2, './Intermediate/GenBank-Taxized.csv')
zip(zipfile = './Intermediate/GBTaxized.zip', files = './Intermediate/GenBank-Taxized.csv') 


# Greg Edits for dates ####

unzip(zipfile = './Intermediate/GBTaxized.zip', exdir = './Intermediate') 
