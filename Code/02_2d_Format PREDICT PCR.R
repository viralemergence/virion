
library(tidyverse)
library(magrittr)

predict <- read_csv("Intermediate/Unformatted/PREDICTPCRUnformatted.csv")

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

# Grab the VirusClass values

classer <- data.frame(VirusOrder = unique(na.omit(predict$VirusOrder)),
           VirusClass = NA)

for (i in 1:nrow(classer)) {
  ncbi.high <- taxize::classification(get_uid(classer$VirusOrder[i]), db = "ncbi")
  classer$VirusClass[i] <- ncbi.high[[1]]$name[which(ncbi.high[[1]]$rank=='class')]
}

predict %<>% left_join(classer) 

### Format 

predict <- bind_rows(temp, predict)

predict %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                     "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                   tolower)

predict %<>% mutate(DetectionMethod = "PCR/Sequencing",
                    DetectionOriginal = "PREDICT",
                    Database = "PREDICT",
                    DatabaseVersion = "June282021PCRTests",
                    ReleaseYear = 2021,
                    ReleaseMonth = 8,
                    ReleaseDay = 28)


write_csv(predict, "Intermediate/Formatted/PREDICTPCRFormatted.csv")
