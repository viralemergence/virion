
library(tidyverse)

predict <- read_csv("Intermediate/Unformatted/PREDICTUnformatted.csv")

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
                   VirusFlagContaminant = logical(),
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


predict %<>% rename(NCBIAccession = "Accession")

library(lubridate)

predict %>% mutate(CollectionYear = year(Date),
                   CollectionMonth = month(Date),
                   CollectionDay = day(Date)) %>% 
  select(-Date) -> predict

predict %<>% mutate(DetectionOriginal = 'PREDICT')

# Grab the VirusClass values

classer <- data.frame(VirusOrder = unique(predict$VirusOrder),
           VirusClass = NA)

for (i in 1:nrow(classer)) {
  ncbi.high <- taxize::classification(get_uid(classer$VirusOrder[i]), db = "ncbi")
  classer$VirusClass[i] <- ncbi.high[[1]]$name[which(ncbi.high[[1]]$rank=='class')]
}

predict %<>% left_join(classer) 

### Format 

predict <- bind_rows(temp, predict %>% mutate(HostTaxID = as.double(HostTaxID),
                                              VirusTaxID = as.double(VirusTaxID)))

predict %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                     "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                   tolower)

write_csv(predict, "Intermediate/Formatted/PREDICTMainFormatted.csv")
