
# 0X_Dissolve VIRION into component parts ####

library(magrittr)
library(tidyverse)

virion <- read_csv("Virion/Virion-Master.csv")

fixer <- function(x) {toString(unique(unlist(x)))}

# Why is there no host genus? Needs to be fixed in NCBI

virion %>% 
  select(Host, HostFamily, HostOrder, HostClass, Host_Original, Host_NCBIResolved, HostSynonyms) %>% 
  rename(Species = Host, Family = HostFamily, Order = HostOrder, Class = HostClass, Original = Host_Original, NCBIResolved = Host_NCBIResolved, Synonyms = HostSynonyms) %>% 
  group_by_at(vars(-c("Original", "Synonyms"))) %>% 
  summarise_at(vars(c("Original", "Synonyms")), ~list(.x)) %>%
  arrange(Species) %>%
  mutate(Original = sapply(Original, fixer),
         Synonyms = sapply(Synonyms, fixer)) -> host.tax

virion %>% 
  select(Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass, Virus_Original, Virus_NCBIResolved) %>% 
  rename(Species = Virus, Genus = VirusGenus, Family = VirusFamily, Order = VirusOrder, Class = VirusClass, Original = Virus_Original, NCBIResolved = Virus_NCBIResolved) %>% 
  group_by_at(vars(-c("Original"))) %>% 
  summarise_at(vars(c("Original")), ~list(.x)) %>%
  arrange(Species) %>%
  mutate(Original = sapply(Original, fixer)) -> virus.tax

# Output the taxonomy files, and return associations without them

virion %>% 
  select(-c(HostFamily, HostOrder, HostClass, Host_Original, Host_NCBIResolved, HostSynonyms, 
            VirusGenus, VirusFamily, VirusOrder, VirusClass, Virus_Original, Virus_NCBIResolved,
            YearType,#YearType currently does nothing - should be eliminated earlier in the pipeline
            Detection_NotSpecified, Detection_Serology, Detection_Genetic, Detection_Isolation)) %>% # These reproduce other information already in one column
  relocate(Reference, .after = last_col()) %>%
  relocate(ReferenceType, .after = last_col()) %>%
  relocate(VirusFlag, .after = Virus) -> virion

virion %>% View()

write_csv(host.tax, "Virion/TaxonomyHost.csv")
write_csv(virus.tax, "Virion/TaxonomyVirus.csv")
write_csv(virion, "Virion/Associations.csv")
