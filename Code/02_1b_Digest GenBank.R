
# 01_Setup ####

rm(list = ls())

library(tidyverse); library(taxize); library(magrittr); library(fs); library(zip)
rentrez::set_entrez_key("ec345b39079e565bdfa744c3ef0d4b03ba08")

if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

if(!file.exists("Source/sequences.csv")){
  unzip("Source/GenBank.zip", exdir = 'Source')
}

gb <- data.table::fread("Source/sequences.csv") %>% 
  as_tibble

gb %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- sleepy.hdict(host.list)
write_csv(host.table, 'Intermediate/GBHostTax.csv')

gb %<>% rename(HostOriginal = "Host") %>%
  left_join(host.table) %>%
  filter(HostClass %in% c("Actinopteri",
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
 # Reptilia is defunct but left in case GLOBI has something on it or it's reinstituted or something weird

gb %>% pull(Species) %>% unique() %>% sort() -> virus.list
virus.table <- sleepy.vdict(virus.list)
write_csv(virus.table, 'Intermediate/GBVirusTax.csv')

gb %<>% rename(VirusOriginal = "Species") %>%
  left_join(virus.table)

vroom_write(gb, "Intermediate/Unformatted/GenBankUnformatted.csv.gz")
