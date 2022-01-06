
library(tidyverse)
library(magrittr)

globi <- read_csv("Intermediate/Unformatted/GLOBIUnformatted.csv")

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

globi %<>% mutate(DetectionOriginal = "GLOBI",
                 Database = "GLOBI",
                 DatabaseVersion = format(file.info("Source/GLOBI-raw.csv")$ctime, 
                                          format = "%b %d, %Y"),
                 DetectionMethod = "Not specified")

bind_rows(temp, globi) -> globi

# Consistency steps: all lowercase names

globi %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                     "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                   tolower)

write_csv(globi, 'Intermediate/Formatted/GLOBIFormatted.csv')
