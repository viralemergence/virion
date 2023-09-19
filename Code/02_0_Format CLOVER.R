#' Format CLOVER 
#' 
#' Clover is a static file that comes from the clover database and you need to 
#' read it in from that location

# Set up =======================================================================
library(tidyverse)
library(magrittr)
library(lubridate)

clo <- readr::read_csv(here::here(paste0(
  "../clover/clover/clover_1.0_allpathogens/",
  "CLOVER_1.0_Viruses_AssociationsFlatFile.csv")))

# template dataframe ===========================================================

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

# do some cleaning on clover ===================================================

# This step should go away after Rory updates CLOVERT with the "sp." thing
if(!("HostGenus" %in% colnames(clo))) { 
  clo %<>% mutate(HostGenus = word(Host, 1)) }

# This step should go away after Rory updates to remove CitationID
if("CitationID" %in% colnames(clo)) { 
    clo %>% 
    rowwise() %>%
    mutate(NCBIAccession = 
             ifelse(CitationIDType=='NCBI Nucleotide', CitationID, NA),
           PMID = ifelse(CitationIDType=='PMID', CitationID, NA)) %>%
    select(-c(CitationID, CitationIDType)) -> clo
}

# names need to be consistent
clo %<>% rename(Virus = "Pathogen",
               VirusGenus = "PathogenGenus",
               VirusFamily = "PathogenFamily",
               VirusOrder = "PathogenOrder",
               VirusClass = "PathogenClass",
               DetectionOriginal = "DetectionMethodOriginal",
               VirusNCBIResolved = "PathogenNCBIResolved",
               VirusOriginal = "PathogenOriginal",
               VirusTaxID = "PathogenTaxID")

clo %<>% select(-c(PathogenType, 
                   Detection_NotSpecified,
                   Detection_Serology,
                   Detection_Genetic,
                   Detection_Isolation))

clo %<>% mutate(NCBIAccession = as.character(NCBIAccession))
clo %<>% select(-ICTVRatified)
dplyr::bind_rows(temp, clo) -> clo

# Consistency steps: all lowercase names
clo %<>% dplyr::mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", 
                     "HostClass","Virus", "VirusGenus", "VirusFamily", 
                     "VirusOrder", "VirusClass"),
                   tolower)

# write out ====================================================================

readr::write_csv(clo, 
                 here::here("./Intermediate/Formatted/CLOVERFormatted.csv"))
