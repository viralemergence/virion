
# 01_Setup ####

rm(list = ls())

library(tidyverse); library(taxize); library(magrittr); library(fs); library(zip)

if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

if(!file.exists("Source/sequences.csv")){
  unzip("Source/GenBank.zip", exdir = 'Source')
}

gb <- data.table::fread("Source/sequences.csv") %>% 
  as_tibble

gb %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- hdict(host.list)
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
                          "Reptilia") | HostOrder == "Testudines")

gb %>% pull(Species) %>% unique() %>% sort() -> virus.list
virus.table <- vdict(virus.list)
write_csv(virus.table, 'Intermediate/GBVirusTax.csv')

gb %<>% rename(VirusOriginal = "Species") %>%
  left_join(virus.table)

vroom_write(gb, "Intermediate/Unformatted/GenBankUnformatted.csv.gz")
