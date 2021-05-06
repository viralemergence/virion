
# 0X_Dissolve VIRION into component parts ####

library(magrittr)
library(tidyverse)
library(vroom)

virion <- vroom("Intermediate/Formatted/VIRIONUnprocessed.tsv.gz")

fixer <- function(x) {toString(unique(unlist(x)))}

# Why is there no host genus? Needs to be fixed in NCBI

virion %>% 
  select(Host, HostTaxID, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass, HostSynonyms) %>% 
  group_by_at(vars(-c("HostSynonyms"))) %>% 
  summarise_at(vars(c("HostSynonyms")), ~list(.x)) %>%
  arrange(Host) %>%
  mutate(HostSynonyms = sapply(HostSynonyms, fixer)) -> host.tax

virion %>% 
  select(Virus, VirusTaxID, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass) %>% 
  arrange(Virus) %>%
  unique() -> virus.tax

# Output the taxonomy files, and return associations without them

write_csv(host.tax, "Virion/TaxonomyHost.csv")
write_csv(virus.tax, "Virion/TaxonomyVirus.csv")

virion %<>% 
  select(-c(HostTaxID, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass, HostSynonyms, 
            VirusTaxID, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass)) #

# Organize the sampling information into an ID-linked column

virion %<>%
  mutate(ID = row_number()) %>%
  relocate(ID, .before = everything())
  
virion %>%
  select(ID, 
         HostOriginal, VirusOriginal, 
         Database, DatabaseVersion,
         ReferenceText, 
         PMID) -> provenance

virion %>% 
  select(ID,
         DetectionMethod, DetectionOriginal, 
         HostFlagID, VirusFlagContaminant,
         NCBIAccession) -> detection

virion %>% 
  select(ID, 
         PublicationYear, 
         ReleaseYear, ReleaseMonth, ReleaseDay,
         CollectionYear, CollectionMonth, CollectionDay) -> temporal

vroom_write(provenance, "Virion/Provenance.csv.gz")
vroom_write(detection, "Virion/Detection.csv.gz")
vroom_write(temporal, "Virion/Temporal.csv.gz")

virion %<>%
  select(-c(Database, DatabaseVersion,
            ReferenceText, 
            PMID,
            DetectionMethod, DetectionOriginal, 
            HostOriginal, VirusOriginal,
            HostFlagID, VirusFlagContaminant,
            NCBIAccession,
            PublicationYear, 
            ReleaseYear, ReleaseMonth, ReleaseDay,
            CollectionYear, CollectionMonth, CollectionDay))

virion %<>% 
  group_by(Host, Virus) %>%
  summarise_at(vars(c("ID")), ~list(.x)) %>%
  arrange(Host, Virus) %>%
  mutate(ID = sapply(ID, fixer))

write_csv(virion, "Virion/Edgelist.csv")
