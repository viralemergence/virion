
# 0X_Dissolve VIRION into component parts ####

library(magrittr)
library(tidyverse)
library(vroom)

virion <- vroom("Virion/Virion.csv.gz")

fixer <- function(x) {toString(unique(unlist(x)))}

# Why is there no host genus? Needs to be fixed in NCBI

virion %<>% filter(!is.na(HostTaxID),
                   !is.na(VirusTaxID))

virion %>% 
  select(HostTaxID, Host, HostGenus, HostFamily, HostOrder, HostClass, HostSynonyms, HostNCBIResolved) %>% 
  group_by_at(vars(-c("HostSynonyms"))) %>% 
  summarise_at(vars(c("HostSynonyms")), ~list(.x)) %>%
  arrange(Host) %>%
  mutate(HostSynonyms = sapply(HostSynonyms, fixer)) -> host.tax

virion %>% 
  select(VirusTaxID, Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass, VirusNCBIResolved, ICTVRatified) %>% 
  arrange(Virus) %>%
  unique() -> virus.tax

# Output the taxonomy files, and return associations without them

write_csv(host.tax, "Virion/TaxonomyHost.csv")
write_csv(virus.tax, "Virion/TaxonomyVirus.csv")

virion %<>% 
  select(-c(Host, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass, HostSynonyms, 
            Virus, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass, ICTVRatified)) #

# Organize the sampling information into an ID-linked column

virion %<>%
  mutate(AssocID = row_number()) %>%
  relocate(AssocID, .before = everything())
  
virion %>%
  select(AssocID, 
         HostOriginal, VirusOriginal, 
         Database, DatabaseVersion,
         ReferenceText, 
         PMID) -> provenance

virion %>% 
  select(AssocID,
         DetectionMethod, DetectionOriginal, 
         HostFlagID, VirusFlagContaminant,
         NCBIAccession) -> detection

virion %>% 
  select(AssocID, 
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
  group_by(HostTaxID, VirusTaxID) %>%
  summarise_at(vars(c("AssocID")), ~list(.x)) %>%
  mutate(AssocID = sapply(AssocID, fixer))

write_csv(virion, "Virion/Edgelist.csv")
