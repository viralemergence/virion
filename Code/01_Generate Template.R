
library(tidyverse)
library(magrittr)

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

write_csv(temp, "Intermediate/Template.csv")