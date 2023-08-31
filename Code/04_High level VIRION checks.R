
library(tidyverse); library(vroom); library(magrittr)
print("libs")
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}
print("taxize")
virion <- vroom::vroom("Intermediate/Formatted/VIRIONUnprocessed.csv.gz", 
                col_type = cols(
                  Host = col_character(),
                  Virus = col_character(),
                  HostTaxID = col_double(),
                  VirusTaxID = col_double(),
                  HostNCBIResolved = col_logical(),
                  VirusNCBIResolved = col_logical(),
                  HostGenus = col_character(),
                  HostFamily = col_character(),
                  HostOrder = col_character(),
                  HostClass = col_character(),
                  HostOriginal = col_character(),
                  HostSynonyms = col_character(),
                  VirusGenus = col_character(),
                  VirusFamily = col_character(),
                  VirusOrder = col_character(),
                  VirusClass = col_character(),
                  VirusOriginal = col_character(),
                  HostFlagID = col_logical(),
                  DetectionMethod = col_character(),
                  DetectionOriginal = col_character(),
                  Database = col_character(),
                  DatabaseVersion = col_character(),
                  PublicationYear = col_double(),
                  ReferenceText = col_character(),
                  PMID = col_double(),
                  NCBIAccession = col_character(),
                  ReleaseYear = col_double(),
                  ReleaseMonth = col_double(),
                  ReleaseDay = col_double(),
                  CollectionYear = col_double(),
                  CollectionMonth = col_double(),
                  CollectionDay = col_double(),
                  AssocID = col_double(),
                  DatabaseDOI = col_character(),
                  Release_Date = col_date(),
                  Collection_Date = col_date()))
print("read")

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
print("filter")

ictv <- readr::read_csv("Source/ICTV Master Species List 2019.v1.csv")
print("read2")

virion %<>% dplyr::mutate(
  ICTVRatified = (Virus %in% stringr::str_to_lower(ictv$Species))) %>%
  dplyr::relocate(ICTVRatified, .after = VirusNCBIResolved)
print("relocate")


# This only applies to CLOVER and GLOBI, which both don't have any other internal flags
virion %<>% dplyr::mutate(HostFlagID = replace_na(HostFlagID, FALSE)) 
print("mutate1")

virion %<>% mutate_cond(stringr::str_detect(HostOriginal, " cf\\."), HostFlagID = TRUE) 
print("mutate condition")

virion %<>% dplyr::select(-c(HostSynonyms))
print("select")

####

virion %<>% distinct()
virion %<>% dplyr::mutate_all(as.character) %>% 
  dplyr::mutate_all(~tidyr::replace_na(.x, ''))
print("replacing")
virion %<>% 
  dplyr::group_by_at(dplyr::vars(-NCBIAccession)) %>% 
  dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", "))
print("summarize")

vroom::vroom_write(virion, "Virion/Virion.csv.gz")
print("written")
