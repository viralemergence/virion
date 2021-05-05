
library(tidyverse)

temp <- data.frame(Host = character(),
                   Virus = character(),
                   HostTaxID = double(),
                   VirusTaxID = double(),
                   HostNCBIResolved = logical(),
                   VirusNCBIResolved = logical(),
                   HostGenus = character(),
                   HostFamily = character(),
                   HostOrder = character(),
                   HostClass = character(),
                   HostOriginal = character(),
                   HostSynonyms = character(),
                   VirusGenus = character(),
                   VirusFamily = character(),
                   VirusOrder = character(),
                   VirusClass = character(),
                   VirusOriginal = character(),
                   HostFlagID = logical(),
                   VirusFlagContaminant = logical(),
                   DetectionMethod = character(),
                   DetectionOriginal = character(),
                   Database = character(),
                   DatabaseVersion = character(),
                   PublicationYear = double(),
                   ReferenceText = character(),
                   PMID = double(),
                   NCBIAccession = character(),
                   ReleaseYear = double(),
                   ReleaseMonth = double(),
                   ReleaseDay = double(),
                   CollectionYear = double(),
                   CollectionMonth = double(),
                   CollectionDay = double(),
                   stringsAsFactors = FALSE)

# Attaching GenBank ####

# if(!file.exists("Intermediate/GenBank-Taxized.csv")){
#   
#   unzip(zipfile = 'Intermediate/GBTaxized.zip', exdir = 'Intermediate') 
#   
# }
# 
# gb <- read_csv("Intermediate/GenBank-Taxized.csv")

gb <- read_csv("Intermediate/Unformatted/GenBankUnformatted.csv")

colnames(gb)[!(colnames(gb) %in% colnames(temp))]

gb %<>% rename(NCBIAccession = 'Accession')

gb %>% 
  rename(Release_Date = Release_Date) %>% 
  mutate_at("Release_Date", ~.x %>% # Modifying date column to make sense
              str_split("T") %>% # Splitting at this midpoint
              map_chr(1) %>% # Taking the first component 
              lubridate::ymd() # Coding as YMD (shouldn't throw errors)
  ) -> gb

gb %<>% 
  separate(Collection_Date, sep = "-", into = paste0("Collection", c("Year", "Month", "Day"))) %>%
  separate(Release_Date, sep = "-", into = paste0("Release", c("Year", "Month", "Day"))) %>% 
  mutate_at(vars(matches("Year|Month|Day")), as.numeric)

gb %<>% mutate(HostFlagID = FALSE,
               VirusFlagContaminant = FALSE,
               Database = "GenBank",
               DatabaseVersion = "Jan2021FlatFile",
               DetectionMethod = "PCR/Sequencing", # Choice to call Nucleotide all sequence and not isolation is potentially problematic - revisit 
               DetectionOriginal = "GenBank") # Just to keep separate from EID2 Nucleotide entries # Fix the HostSynonyms at the 01 import stage

gb %<>% mutate(VirusTaxID = as.numeric(VirusTaxID))

gb <- bind_rows(temp, gb)

gb %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                         "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                       tolower)

write_csv(gb, "Intermediate/Formatted/GenbankFormatted.csv")
