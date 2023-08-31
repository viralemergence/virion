
library(tidyverse); library(vroom); library(magrittr)
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

virion <- vroom::vroom("./Intermediate/Formatted/VIRIONUnprocessed.csv.gz", 
                col_type = cols(PMID = col_double(), 
                                PublicationYear = col_double()))

# # Is there anything that's not vertebrate in here?
# 
# virion %>% dplyr::filter(!(HostClass %in% c("actinopteri",
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
#   dplyr::filter(!is.na(HostClass)) %>% View()

# Deal with the phage 
  
virion %<>% 
  dplyr::filter(!stringr::str_detect(Virus, "phage")|is.na(Virus),
         !stringr::str_detect(Virus, "bacteri")|is.na(Virus)) %>%
  dplyr::filter(!(VirusFamily %in% c("turriviridae",
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

ictv <- readr::read_csv("Source/ICTV Master Species List 2019.v1.csv")

virion %<>% dplyr::mutate(
  ICTVRatified = (Virus %in% stringr::str_to_lower(ictv$Species))) %>%
  dplyr::relocate(ICTVRatified, .after = VirusNCBIResolved)

# This only applies to CLOVER and GLOBI, which both don't have any other internal flags
virion %<>% dplyr::mutate(HostFlagID = replace_na(HostFlagID, FALSE)) 

virion %<>% mutate_cond(stringr::str_detect(HostOriginal, " cf\\."), HostFlagID = TRUE) 

virion %<>% dplyr::select(-c(HostSynonyms))

####

virion %<>% distinct()
virion %<>% dplyr::mutate_all(as.character) %>% 
  dplyr::mutate_all(~tidyr::replace_na(.x, ''))

virion %<>% 
  dplyr::group_by_at(dplyr::vars(-NCBIAccession)) %>% 
  dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", "))

vroom::vroom_write(virion, "Virion/Virion.csv.gz")
