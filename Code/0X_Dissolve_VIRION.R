
# 0X_Dissolve VIRION into component parts ####

library(magrittr)
library(tidyverse)

virion <- read_csv("Virion/Virion-Master.csv")

virion %>% colnames()

# Why is there no host genus? Needs to be fixed in NCBI

virion %>% 
  select(Host, HostFamily, HostOrder, HostClass, Host_Original, Host_NCBIResolved, HostSynonyms) %>% 
  rename(Species = Host, Family = HostFamily, Order = HostOrder, Class = HostClass, Original = Host_Original, NCBIResolved = Host_NCBIResolved, Synonyms = HostSynonyms) %>% 
  # Missing step where we collapse by Host_Original
  unique() %>% 
  arrange(Species) -> host.tax

virion %>% 
  select(Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass, Virus_Original, Virus_NCBIResolved) %>% 
  rename(Species = Virus, Genus = VirusGenus, Family = VirusFamily, Order = VirusOrder, Class = VirusClass, Original = Virus_Original, NCBIResolved = Virus_NCBIResolved) %>% 
  # Missing step where we collapse by Virus_Original
  unique() %>% 
  arrange(Species) -> virus.tax
