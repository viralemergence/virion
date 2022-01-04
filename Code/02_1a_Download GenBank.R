
library(RCurl)
library(readr)
library(tidyverse)
library(vroom)

url = "https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/AllNuclMetadata.csv"
d = tryCatch(download.file(url, destfile = "./Source/AllNuclMetadata.csv"), error = function(e){-999})
if(d = -999) {
  while (d == -999){
    Sys.sleep(600)
    d = tryCatch(download.file(url, destfile = "./Source/AllNuclMetadata.csv"), error = function(e){-999})
  }
}

seq <- data.table::fread("./Source/AllNuclMetadata.csv",
                         select = c("#Accession", "Release_Date", "Species", "Host", "Collection_Date"))
seq %>% rename(Accession = "#Accession") %>% 
  vroom_write("./Source/sequences.csv")
