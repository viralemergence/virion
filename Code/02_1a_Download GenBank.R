#' Download GenBank 
#' 
#' GenBank is an updating resource so you have to pull it and this script does 
#' that 

# set up =======================================================================

library(readr)
library(vroom)
library(here)
library(data.table)
library(magrittr)
library(dplyr)

# download and process =========================================================

url = paste0("https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/",
             "AllNuclMetadata.csv.gz")
d = tryCatch(utils::download.file(url, destfile = here::here(
  "./Source/AllNuclMetadata.csv.gz")),
  error = function(e){-999})

if(d == -999) {
  while (d == -999){
    Sys.sleep(600)
    d = tryCatch(utils::download.file(
      url, destfile = here::here("./Source/AllNuclMetadata.csv.gz")), 
      error = function(e){-999})
  }
}

# reading this in - use data.table
seq <- data.table::fread(here::here("./Source/AllNuclMetadata.csv.gz"),
                         select = c("#Accession", "Release_Date", "Species", 
                                    "Host", "Collection_Date"))
seq %<>% dplyr::rename(Accession = "#Accession")

# write out ==================================================================== 
vroom::vroom_write(seq, here::here("./Source/sequences.csv"))
