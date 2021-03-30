
library(tidyverse)
library(taxize)

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

# Now, only pull in names that are resolved enough to make sense of, and none of the messy names

globi %>% mutate(is.flu = str_detect(Virus, "Influenza A")) %>%
  rowwise() %>%
  mutate(Virus = ifelse(is.flu==TRUE, 'Influenza A', Virus)) %>%
  select(-is.flu) -> globi

globi %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- (jncbi(host.list, type = 'host') %>% filter(matched == TRUE))

globi %>% pull(Virus) %>% unique() %>% sort() -> virus.list
virus.table <- (jncbi(virus.list, type = 'virus') %>% filter(matched == TRUE))

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

virion <- read_csv("~/Github/virion/Virion/Virion-Master.csv")
virion %>% select(Host, Virus) %>%
  mutate(Host = tolower(Host),
         Virus = tolower(Virus)) %>%
  unique() -> virion
