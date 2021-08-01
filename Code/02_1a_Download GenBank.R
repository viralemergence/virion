
library(RCurl)
library(readr)
library(tidyverse)
library(vroom)

url = "https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/AllNuclMetadata.csv"
download.file(url, destfile = "./Source/AllNuclMetadata.csv")
seq <- data.table::fread("./Source/AllNuclMetadata.csv",
                         select = c("#Accession", "Release_Date", "Species", "Host", "Collection_Date"))
seq %>% rename(Accession = "#Accession") %>% 
  vroom_write("./Source/sequences.csv")
