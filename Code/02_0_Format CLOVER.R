
library(tidyverse)
library(magrittr)
library(lubridate)

clo <- read_csv("~/Github/clovert_dev/clover/clover/CLOVER_1.0_Viruses_AssociationsFlatFile.csv")

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

# This step should go away after Rory updates CLOVERT with the "sp." thing
if(!("HostGenus" %in% colnames(clo))) { clo %<>% mutate(HostGenus = word(Host, 1)) }

# This step should go away after Rory updates to remove CitationID
if("CitationID" %in% colnames(clo)) { 
    clo %>% 
    rowwise() %>%
    mutate(NCBIAccession = ifelse(CitationIDType=='NCBI Nucleotide', CitationID, NA),
           PMID = ifelse(CitationIDType=='PMID', CitationID, NA)) %>%
    select(-c(CitationID, CitationIDType)) -> clo
}

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

# colnames(clo)[!(colnames(clo) %in% colnames(temp))] # Deleted check 

bind_rows(temp, clo) -> clo

# Consistency steps: all lowercase names

clo %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                     "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                   tolower)

write_csv(clo, 'Intermediate/Formatted/CLOVERFormatted.csv')
