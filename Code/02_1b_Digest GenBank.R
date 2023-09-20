#" GenBank digesting with NCBI
#" 
#" There"s some cleaning to do, and that"s done here
#" 

# set up =======================================================================

library(magrittr)

# this is necessary for using the NCBI records of more than 10
rentrez::set_entrez_key("ec345b39079e565bdfa744c3ef0d4b03ba08")

# get the functions to do all the dictionary stuff
if(!exists("vdict")) {source(here::here("./Code/001_TaxizeFunctions.R"))}
if(!exists("jvdict")) {source(here::here("./Code/001_Julia functions.R"))}

if(!file.exists(here::here("./Source/sequences.csv"))){
  zip::unzip(here::here("./Source/GenBank.zip"), exdir = "Source")
}

gb <- data.table::fread(here::here("./Source/sequences.csv")) %>% 
  dplyr::as_tibble()

# do the cleaning itself =======================================================
host_vec <- gb %>% 
  dplyr::pull(Host) %>% 
  unique() %>% 
  sort()

host_table <- jhdict(host_vec) 
readr::write_csv(host_table, here::here("./Intermediate/GBHostTax.csv"))

gb %<>% dplyr::rename(HostOriginal = "Host") %>%
  dplyr::left_join(host_table) %>%
  dplyr::filter(HostClass %in% c("Actinopteri",
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
            # or it"s reinstituted or something weird

# get vector of the species names 
virus_vec <- gb %>% 
  dplyr::pull(Species) %>% 
  unique() %>% 
  sort()

# get julia to help here
virus_table <- jvdict(virus_vec)

gb %<>% dplyr::rename(VirusOriginal = "Species") %>%
  dplyr::left_join(virus_table)

# write files ==================================================================
vroom::vroom_write(gb, here::here(
  "./Intermediate/Unformatted/GenBankUnformatted.csv.gz"))
readr::write_csv(virus_table, here::here("./Intermediate/GBVirusTax.csv"))

