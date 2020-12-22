
library(tidyverse)
setwd("/nfs/ccarlson-data/virion-main")

source("00 - taxize-cleaner-clone.R")

# Read in host data

unzip("GenBank_as_Edgelist.zip", exdir = getwd())
gb <- data.table::fread("GenBank_as_Edgelist.csv")
gb %>% as_tibble -> gb
hosts_vec <- unique(na.omit(gb$Host))
synonyms <- lapply(1:length(hosts_vec), findSyns3)
synonyms %>% bind_rows() -> host.dictionary

write_rds(host.dictionary, "HostDictionary.RDS")

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


#data.table::fwrite(gb2, 'GenBank-Taxized.csv')
#zip(zipfile = 'GBTaxized.zip', files = 'GenBank-Taxized.csv') 
