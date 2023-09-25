#' Download GenBank 
#' 
#' GenBank is an updating resource so you have to pull it and this script does 
#' that 

# set up =======================================================================

library(magrittr)

# download and process =========================================================

url = paste0("https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/",
             "AllNuclMetadata.csv.gz")

location <- here::here("./Source/") 
system(paste0("wget ", url, " -P ", location))

# reading this in - use data.table
seq <- data.table::fread(here::here("./Source/AllNuclMetadata.csv.gz"),
                         select = c("#Accession", "Release_Date", "Species", 
                                    "Host", "Collection_Date"))
print("readin")
seq %<>% dplyr::rename(Accession = "#Accession") 

# write out ==================================================================== 
vroom::vroom_write(seq, here::here("./Source/sequences.csv"))
print("written")
