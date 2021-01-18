
# In case free-running 

library(tidyverse)
library(magrittr)
library(readr)

# Pull in the required pieces

setwd(here::here())

# setwd("~/Github/virion")
# clo <- read_csv("~/github/clover/output/Clover_v1.0_NBCIreconciled_20201211.csv")
# Greg just flagging that this was an old version 

if(file.exists("Intermediate/clover.csv")){
  
  clo <- read.csv("Intermediate/clover.csv")
  
}else{
  
  clo <- 
    read.csv("https://raw.githubusercontent.com/viralemergence/clover/main/output/Clover_v1.0_NBCIreconciled_20201218.csv")
  
  write.csv(clo, file = "Intermediate/clover.csv")
  
}

if(file.exists("Intermediate/GenBank-Taxized.csv")){
  
  gb <- read_csv("Intermediate/GenBank-Taxized.csv")
  
}else{  
  
  unzip(zipfile = './Intermediate/GBTaxized.zip', exdir = './Intermediate') 
  
  gb <- read_csv("Intermediate/GenBank-Taxized.csv")
  
}


gb %<>% mutate(Year = NA, # Fix the fact it drops year at the import stage 
              YearType = "GenBank", # Address collection-date versus publication-date by finding a way to include both - maybe reshape CLOVER format
              Database = "GenBank",
              DatabaseVersion = "Dec2020FlatFile",
              DetectionMethod = "PCR/Sequencing", # Choice to call Nucleotide all sequence and not isolation is potentially problematic - revisit 
              Detection_NotSpecified = FALSE,
              Detection_Serology = FALSE,
              Detection_Genetic = TRUE,
              Detection_Isolation = FALSE,
              Host_Original = Host,
              Virus_Original = Virus,
              DetectionMethod_Original = "GenBank", # Just to keep separate from EID2 Nucleotide entries
              Host_NCBIResolved = TRUE,
              Virus_NCBIResolved = TRUE,
              HostSynonyms = NA) # Fix the HostSynonyms at the 01 import stage

virion <- bind_rows(clo, gb)

write_csv(virion, './Intermediate/Virion-Temp.csv')
