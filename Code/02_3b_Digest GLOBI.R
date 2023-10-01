source('Code/001_TaxizeFunctions.R')
source('Code/001_Julia functions.R')
rentrez::set_entrez_key("ec345b39079e565bdfa744c3ef0d4b03ba08")

library(tidyverse)
library(taxize)
library(magrittr)
library(vroom)
install.ncbi()

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
  unique() %>%
  mutate(VirusOriginal = Virus, # keep backups
         HostOriginal = Host) -> globi

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

globi %>% 
  mutate_cond(str_detect(Virus, "Influenza A"), Virus = "Influenza A") %>% 
  mutate_cond(str_detect(Virus, "Influenza B"), Virus = "Influenza B") %>% 
  mutate_cond(str_detect(Virus, "Influenza C"), Virus = "Influenza C")  %>% 
  mutate_cond(str_detect(Virus, "Influenza D"), Virus = "Influenza D")  -> globi

globi %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- jhdict(host.list)

globi %>% pull(Virus) %>% unique() %>% sort() -> virus.list
virus.table <- jvdict(virus.list)

globi %<>% 
  rename(HostIntermediate = 'Host') %>%
  left_join(host.table, by = c('HostIntermediate' = 'HostOriginal')) %>%
  select(-HostIntermediate) %>% 
  rename(VirusIntermediate = 'Virus') %>%
  left_join(virus.table, by = c('VirusIntermediate' = 'VirusOriginal')) %>%
  select(-c(VirusIntermediate, Host.ID, Virus.ID))

globi %<>%
  mutate_cond(is.na(HostGenus), HostGenus = word(Host, 1))

# A little cleaning
globi %<>% filter(HostClass %in% c("Actinopteri",
                        "Actinopterygii",
                        "Amphibia",
                        "Aves",
                        "Chondrichthyes",
                        "Cladistia",
                        "Hyperoartia",
                        "Lepidosauria",
                        "Mammalia",
                        "Myxini",
                        "Reptilia") | HostOrder %in% c("Testudines", "Crocodylia"))

globi %<>% filter(str_detect(VirusClass, "viricetes"))

write_csv(globi, "Intermediate/Unformatted/GLOBIUnformatted.csv")
