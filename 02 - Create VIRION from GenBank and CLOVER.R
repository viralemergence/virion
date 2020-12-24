
# In case free-running 

library(tidyverse)
library(magrittr)

# Pull in the required pieces

clo <- read_csv("~/github/clover/output/Clover_v1.0_NBCIreconciled_20201211.csv")

gb <- read_csv("GenBank-Taxized.csv")


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

write_csv(virion, 'Virion-Temp.csv')
