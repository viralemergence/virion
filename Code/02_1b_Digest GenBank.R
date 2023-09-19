#' Genback processing
#' 
#' There's some cleaning to do, and that's done here
#' 

# set up =======================================================================
rm(list = ls())

library(dplyr)
library(taxize)
library(magrittr)
library(fs)
library(zip)
library(vroom)
library(rentrez)

# this is necessary for using the NCBI records of more than 10
rentrez::set_entrez_key("ec345b39079e565bdfa744c3ef0d4b03ba08")

# get the functions to do all the dictionary stuff
if(!exists('vdict')) {source(here::here("./Code/001_TaxizeFunctions.R"))}
if(!exists('jvdict')) {source(here::here("./Code/001_Julia functions.R"))}

if(!file.exists(here::here("./Source/sequences.csv"))){
  unzip(here::here("./Source/GenBank.zip"), exdir = 'Source')
}

gb <- data.table::fread(here("./Source/sequences.csv")) %>% 
  dplyr::as_tibble()

# do the cleaning itself =======================================================
gb %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- jhdict(host.list)
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
                          "Reptilia") | HostOrder %in% 
           c("Testudines", "Crocodylia"))
            # Reptilia is defunct but left in case GLOBI has something on it 
            # or it's reinstituted or something weird

gb %>% pull(Species) %>% unique() %>% sort() -> virus.list
virus.table <- jvdict(virus.list)

gb %<>% rename(VirusOriginal = "Species") %>%
  left_join(virus.table)

# write files ==================================================================
vroom::vroom_write(gb, here::here(
  "./Intermediate/Unformatted/GenBankUnformatted.csv.gz"))
readr::write_csv(virus.table, here::here("./Intermediate/GBVirusTax.csv"))

