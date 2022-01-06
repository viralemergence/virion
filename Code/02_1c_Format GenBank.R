
library(tidyverse); library(magrittr); library(vroom)
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}
if(!exists('jvdict')) {source('Code/001_Julia functions.R')}

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

# Attaching GenBank

gb <- vroom("Intermediate/Unformatted/GenBankUnformatted.csv.gz")

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

gb %<>% mutate(HostFlagID = str_detect(HostOriginal, "cf."),
               Database = "GenBank",
               DatabaseVersion = "Aug2021FlatFile",
               DetectionMethod = "PCR/Sequencing", # Choice to call Nucleotide all sequence and not isolation is potentially problematic - revisit 
               DetectionOriginal = "GenBank") # Just to keep separate from EID2 Nucleotide entries # Fix the HostSynonyms at the 01 import stage

gb %<>% mutate(VirusTaxID = as.numeric(VirusTaxID))

gb <- bind_rows(temp, gb)

gb %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                         "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                       tolower)

vroom_write(gb, "Intermediate/Formatted/GenbankFormatted.csv.gz")
