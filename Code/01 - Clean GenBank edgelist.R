
# 01_Setup ####

library(tidyverse); library(taxize); library(magrittr)

# setwd("~/Github/virion")
# setwd(here::here())

source("Code/00 - taxize-cleaner-clone.R")

# Read in host data ####

# Downloaded from NCBI Virus on 19th January 2021 by GFA
# https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?VirusLineage_ss=Viruses,%20taxid:10239&SeqType_s=Nucleotide
# Includes the following selected columns:
# Accession, Release Date, Species, Host, Collection Date

if(!file.exists("Source/sequences.csv")){
  
  unzip("Source/GenBank.zip", exdir = 'Source')
  
}

gb <- data.table::fread("Source/sequences.csv") %>% 
  as_tibble

# Removing GenBank entries with only one word names ####

if(0){
  
  gb %>% mutate(NWords = str_count(Host, " ")) %>% 
    filter(NWords>1) -> gb
  
}

hosts_vec <- unique(na.omit(gb$Host))

# Taxizing ####

host.dictionary <- readRDS("Intermediate/HostDictionary.RDS")

NotInDictionary <- hosts_vec %>% # Identify host names not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

if(length(NotInDictionary)>0){ 
  
  synonyms <- NotInDictionary %>% # Go through these names and Taxize them 
    lapply(findSyns3)
  
  # synonyms %>% 
  #   seq_along %>% 
  #   map(~ifelse(is.null(synonyms[[.x]]), 
  #               data.frame(Original = NotInDictionary[.x]),
  #               synonyms[[.x]])) ->
  #   synonyms
  
  synonyms %>% bind_rows() %>% # Attach those taxized names to the dictionary
    bind_rows(host.dictionary) -> 
    host.dictionary
  
  host.dictionary %<>% arrange(Original) # arrange by name
  
  write_rds(host.dictionary, "Intermediate/HostDictionary.RDS")
  
}

StillNotInDictionary <- hosts_vec %>% # Identify host names STILL not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

data.frame(Original = StillNotInDictionary) %>% 
  bind_rows(host.dictionary, .) ->
  host.dictionary

# Double check if the dictionary needs expansion ####

# if(1){ # Set to not run

dict2 <- data.frame(Original = hosts_vec)

dict2 %>% 
  as_tibble %>%
  left_join(host.dictionary) -> dict2

for (i in 1:nrow(dict2)) {
  if(dict2$Original[i] %in% dict2$Synonyms) {
    dict2$Accepted_name[i] <- dict2$Accepted_name[which(dict2$Synonyms == dict2$Original[i])]
    print(i)
  }
}

host.dictionary <- dict2

# }

# Making the cleaned dataset ####

host.dictionary %>% # Adding the Taxize information to the data frame
  dplyr::select(-c(Submitted, Synonyms)) %>% 
  unique %>% #nrow %>% 
  left_join(gb, ., by = c('Host' = 'Original')) ->
  gb2 # <- left_join(gb, host.dictionary, by = c('Host' = 'Original'))

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

data.table::fwrite(gb2, 'Intermediate/GenBank-Taxized.csv')

zip(zipfile = 'Intermediate/GBTaxized.zip', 
    files = 'Intermediate/GenBank-Taxized.csv') 
