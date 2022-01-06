
library(tidyverse); library(vroom); library(magrittr)
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

virion <- vroom("./Intermediate/Formatted/VIRIONUnprocessed.csv.gz", col_type = cols(PMID = col_double(), PublicationYear = col_double()))

# # Is there anything that's not vertebrate in here?
# 
# virion %>% filter(!(HostClass %in% c("actinopteri",
#                                      "actinopterygii",
#                                      "amphibia",
#                                      "aves",
#                                      "chondrichthyes",
#                                      "cladistia",
#                                      "hyperoartia",
#                                      "lepidosauria",
#                                      "mammalia",
#                                      "myxini",
#                                      "reptilia"))) %>%
#   filter(!is.na(HostClass)) %>% View()

# Deal with the phage 
  
virion %<>% 
  filter(!str_detect(Virus, "phage")|is.na(Virus),
         !str_detect(Virus, "bacteri")|is.na(Virus)) %>%
  filter(!(VirusFamily %in% c("turriviridae",
                             "ackermannviridae",
                             "myoviridae",
                             "siphoviridae",
                             "podoviridae",
                             "sphaerolipoviridae",
                             "pleoplipoviridae",
                             "tectiviridae",
                             "leviviridae",
                             "lipothrixviridae",
                             "rudiviridae",
                             "cystoviridae",
                             "microviridae",
                             "inoviridae",
                             "corticoviridae",
                             "ampullaviridae",
                             "bicaudaviridae",
                             "clavaviridae",
                             "finnlakeviridae",
                             "fuselloviridae",
                             "globuloviridae",
                             "guttaviridae",
                             "plasmaviridae",
                             "portogloboviridae",
                             "spiraviridae",
                             "tristomaviridae",
                             "megaviridae")),
         !(VirusOrder %in% c("belfryvirales",
                             "caudovirales",
                             "halopanivirales",
                             "haloruvirales",
                             "kalamavirales",
                             "levivirales",
                             "ligamenvirales",
                             "mindivirales",
                             "petitvirales",
                             "tubulavirales",
                             "vinavirales")))

ictv <- read_csv("Source/ICTV Master Species List 2019.v1.csv")

virion %<>% mutate(ICTVRatified = (Virus %in% str_to_lower(ictv$Species))) %>%
  relocate(ICTVRatified, .after = VirusNCBIResolved)

virion %<>% mutate(HostFlagID = replace_na(HostFlagID, FALSE)) # This only applies to CLOVER and GLOBI, which both don't have any other internal flags

virion %<>% mutate_cond(str_detect(HostOriginal, " cf\\."), HostFlagID = TRUE) 

virion %<>% select(-c(HostSynonyms))

####

virion %<>% distinct()
virion %<>% mutate(across(everything(), ~replace_na(.x, '')))

virion %<>% 
  group_by_at(vars(-NCBIAccession)) %>% 
  summarize(NCBIAccession = str_c(NCBIAccession, collapse = ", "))

vroom_write(virion, "Virion/Virion.csv.gz")
