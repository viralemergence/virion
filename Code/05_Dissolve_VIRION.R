
# 0X_Dissolve VIRION into component parts ####

library(magrittr)
library(tidyverse)
library(vroom)

virion <- vroom("Intermediate/Formatted/VIRIONUnprocessed.tsv.gz")

fixer <- function(x) {toString(unique(unlist(x)))}

# Why is there no host genus? Needs to be fixed in NCBI

virion %>% 
  select(Host, HostTaxID, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass, HostOriginal, HostSynonyms) %>% 
  group_by_at(vars(-c("HostOriginal", "HostSynonyms"))) %>% 
  summarise_at(vars(c("HostOriginal", "HostSynonyms")), ~list(.x)) %>%
  arrange(Host) %>%
  mutate(HostOriginal = sapply(HostOriginal, fixer),
         HostSynonyms = sapply(HostSynonyms, fixer)) -> host.tax

virion %>% 
  select(Virus, VirusTaxID, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass, VirusOriginal) %>% 
  group_by_at(vars(-c("VirusOriginal"))) %>% 
  summarise_at(vars(c("VirusOriginal")), ~list(.x)) %>%
  arrange(Virus) %>%
  mutate(VirusOriginal = sapply(VirusOriginal, fixer)) -> virus.tax

# Output the taxonomy files, and return associations without them

write_csv(host.tax, "Virion/TaxonomyHost.csv")
write_csv(virus.tax, "Virion/TaxonomyVirus.csv")

virion %<>% 
  select(-c(HostTaxID, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass, HostOriginal, HostSynonyms, 
            VirusTaxID, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass, VirusOriginal)) #

# Organize the sampling information into an ID-linked column

virion %<>%
  mutate(ID = row_number()) %>%
  relocate(ID, .before = everything())
  
virion %>%
  select(ID, 
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
