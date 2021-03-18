
# 02_Merging Clover in ####
# Created and cleaned in https://github.com/viralemergence/clover

library(tidyverse); library(magrittr); library(readr)

# Pull in the required pieces ####

if(file.exists("Intermediate/clover.csv")){
  
  clo <- read.csv("Intermediate/clover.csv")
  
}else{
  
  clo <- 
    read.csv("https://raw.githubusercontent.com/viralemergence/clover/main/output/Clover_v1.0_NBCIreconciled_20201218.csv")
  
  write.csv(clo, file = "Intermediate/clover.csv", row.names = F)
  
}

# Altering the year column for Clover ####

clo %<>% 
  # mutate_at("YearType", as.character) %>% 
  mutate_at("YearType", 
            ~ifelse(str_detect(.x, "Nucleotide"), "Release_Year", "Publication_Year")) %>% 
  tidyr::pivot_wider(names_from = YearType, values_from = Year) %>%
  rename(Other_Year = `NA`)

# Attaching GenBank ####

if(!file.exists("Intermediate/GenBank-Taxized.csv")){
  
  unzip(zipfile = 'Intermediate/GBTaxized.zip', exdir = 'Intermediate') 
  
}

gb <- read_csv("Intermediate/GenBank-Taxized.csv")

# Keep this here so that it doesn't take up MB as a csv
gb %<>% mutate(#Release_Year = Release_Date %>% str_split("-") %>% map_chr(1) %>% as.numeric, # Taking first argument of date
               YearType = "GenBank", # Address collection-date versus publication-date by finding a way to include both - maybe reshape CLOVER format
               Database = "GenBank",
               DatabaseVersion = "Jan2021FlatFile",
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

gb %<>% 
  separate(Collection_Date, sep = "-", into = paste0("Collection_", c("Year", "Month", "Day"))) %>%
  # separate(Publication_Date, sep = "-", into = paste0("Publication_", c("Year", "Month", "Day"))) %>% 
  separate(Release_Date, sep = "-", into = paste0("Release_", c("Year", "Month", "Day"))) %>% 
  mutate_at(vars(matches("Year|Month|Day")), as.numeric)

virion <- bind_rows(clo, gb) %>% 
  arrange(Host, Virus)

write_csv(virion, 'Intermediate/Virion-Temp.csv')
