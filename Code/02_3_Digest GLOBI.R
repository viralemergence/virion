
if(!exists('jncbi')) {source('Code/001_Julia functions.R')}
if(!exists('findSyns3')) {source('Code/002_TaxiseCleaner.R')}

library(tidyverse)
library(taxize)

if(!file.exists("Intermediate/GLOBI-parsed.csv")) {
  
globi <- read_csv('Source/GLOBI-raw.csv')

globi %>% 
  select(source_taxon_external_id,
         source_taxon_name,
         target_taxon_external_id,
         target_taxon_name) %>%
  rename(Virus.ID = 'source_taxon_external_id',
         Virus = 'source_taxon_name',
         Host.ID = 'target_taxon_external_id',
         Host = 'target_taxon_name') %>%
  unique() -> globi

# How much is already set up for NCBI?

globi %>% 
  filter(str_detect(Host.ID, 'NCBI')) %>%
  filter(str_detect(Virus.ID, 'NCBI')) -> 
  ncbi.strict

# So these are the things that we can double triple check for errors

globi %>% pull(Host.ID) %>% sapply(function(x) {word(string = x, 1, sep = ":")}) %>% table()
globi %>% pull(Virus.ID) %>% sapply(function(x) {word(string = x, 1, sep = ":")}) %>% table()

#### Actually call NCBI 
# Only pull in names that are resolved enough to make sense of, and none of the messy names

globi %>% mutate(is.flu = str_detect(Virus, "Influenza A")) %>%
  rowwise() %>%
  mutate(Virus = ifelse(is.flu==TRUE, 'Influenza A', Virus)) %>%
  select(-is.flu) -> globi

globi %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- (jncbi(host.list, type = 'host') %>% filter(matched == TRUE))

globi %>% pull(Virus) %>% unique() %>% sort() -> virus.list
virus.table <- (jncbi(virus.list, type = 'virus')) #%>% filter(matched == TRUE))

host.table %>% select(Name, match) %>%
  rename(Host_Original = 'Name',
         Host = 'match') %>%
  mutate(Host_Original = tolower(Host_Original),
         Host = tolower(Host)) -> host.table

virus.table %>% select(Name, match) %>%
  rename(Virus_Original = 'Name',
         Virus = 'match') %>% 
  mutate(Virus_Original = tolower(Virus_Original),
         Virus = tolower(Virus)) -> virus.table

globi %>% rename(Virus_Original = 'Virus',
                 Host_Original = 'Host') %>%
  mutate(Virus_Original = tolower(Virus_Original),
         Host_Original = tolower(Host_Original)) %>% 
  left_join(host.table) %>%
  left_join(virus.table) %>%
  select(-Virus.ID) %>%
  select(-Host.ID) %>%
  unique() %>%
  na.omit() %>%
  select(Host, Virus, Host_Original, Virus_Original) -> globi

globi %<>% rename(Host_Intermediate = "Host",
                  Virus_Intermediate = "Virus")

##### Grab the higher taxonomy

globi %>% pull(Virus_Intermediate) %>% unique() %>% sort() -> ncbi.names

ncbi.tax.virus <- data.frame(Virus_Intermediate = ncbi.names,
                             Virus = ncbi.names,
                             VirusGenus = NA, 
                             VirusFamily = NA, 
                             VirusOrder = NA,
                             VirusClass = NA)

for (i in 1:nrow(ncbi.tax.virus)) {
  
  ncbi.tax.virus$Virus[i] <- str_squish(str_replace(ncbi.tax.virus$Virus[i], " sp\\.", ""))
  
  ncbi.num <- taxize::get_uid(ncbi.tax.virus$Virus[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  
  match = 0 
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
    match = 1
  }
  
  if(match == 0){
    ncbi.num <- taxize::get_uid(ncbi.tax.virus$Virus[i], rank_query = c("genus"))
    ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
    if(!is.na(ncbi.high[[1]][1])){
      if("genus" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
      if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
      if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
      if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
      match = 1
      ncbi.tax.virus$Virus[i] <- NA
    }
  }
  
  if(match == 0){
    ncbi.num <- taxize::get_uid(ncbi.tax.virus$Virus[i], rank_query = c("family"))
    ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
    if(!is.na(ncbi.high[[1]][1])){
      if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
      if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
      if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.virus$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
      match = 1
      ncbi.tax.virus$Virus[i] <- NA
    }
  }
}

globi %>% pull(Host_Intermediate) %>% unique() %>% sort() -> ncbi.names

ncbi.tax.host <- data.frame(Host_Intermediate = ncbi.names,
                       Host = ncbi.names,
                       HostGenus = NA, 
                       HostFamily = NA, 
                       HostOrder = NA,
                       HostClass = NA)

for (i in 1:nrow(ncbi.tax.host)) {
  
  match = 0
  ncbi.tax.host$Host[i] <- str_squish(str_replace(ncbi.tax.host$Host[i], " sp\\.", ""))
  ncbi.tax.host$Host[i] <- str_squish(str_replace(ncbi.tax.host$Host[i], " gen\\.", ""))
  if(str_count(ncbi.tax.host$Host[i], " ")>1) {
    ncbi.tax.host$Host[i] = word(ncbi.tax.host$Host[i], start = 1, end = 2)
  }
  
  ncbi.num <- taxize::get_uid(ncbi.tax.host$Host[i], rank_query = c("species"))
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
    match = 1
  }
  
  if(match == 0){
    ncbi.num <- taxize::get_uid(ncbi.tax.host$Host[i], rank_query = c("genus"))
    ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
    if(!is.na(ncbi.high[[1]][1])){
      if("genus" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
      if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
      if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
      if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
      match = 1
      ncbi.tax.host$Host[i] <- NA
    }
  }
  
  if(match == 0){
    ncbi.num <- taxize::get_uid(ncbi.tax.host$Host[i], rank_query = c("family"))
    ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
    if(!is.na(ncbi.high[[1]][1])){
      if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
      if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
      if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
      match = 1
      ncbi.tax.host$Host[i] <- NA
    }
  }
  
  if(match == 0){
    ncbi.num <- taxize::get_uid(ncbi.tax.host$Host[i], rank_query = c("order"))
    ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
    if(!is.na(ncbi.high[[1]][1])){
      if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
      if("class" %in% ncbi.high[[1]]$rank) {ncbi.tax.host$HostClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
      match = 1
      ncbi.tax.host$Host[i] <- NA
    }
  }
}

# NEED TO ADD A STEP TO BIND IN THE TAXONOMY

globi %>% 
  left_join(ncbi.tax.host) %>%
  left_join(ncbi.tax.virus) %>%
  select(-Host_Intermediate) %>%
  select(-Virus_Intermediate) %>% 
  unique() -> globi

write_csv(globi, "Intermediate/GLOBI-parsed.csv")

}

##### Bind into VIRION

globi <- read_csv("Intermediate/GLOBI-parsed.csv")

virion <- read_csv('Intermediate/Virion-Temp.csv')

virion <- bind_rows(virion, globi) %>% 
  arrange(Host, Virus)

write_csv(virion, 'Intermediate/Virion-Temp.csv')
