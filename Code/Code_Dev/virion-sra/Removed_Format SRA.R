
library(tidyverse)

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

sra <- read_csv("Intermediate/Unformatted/SRAUnformatted.csv")

colnames(temp)[!(colnames(temp) %in% colnames(sra))]

sra %<>% mutate(VirusFlagContaminant = FALSE)

problems <- c("Vesicular stomatitis virus",
              "Guanarito mammarenavirus",
              "Woodchuck hepatitis virus",
              "Aureococcus anophagefferens virus",
              "Bacillariodnavirus LDMD-2013",
              "McMurdo Ice Shelf pond-associated circular DNA virus-1",
              "McMurdo Ice Shelf pond-associated circular DNA virus-5",
              "Organic Lake phycodnavirus 1",
              "Phaeocvstis alobosa virus",
              "Boiling Springs Lake RMA-DMA hybrid virus",
              "CHIV14",
              "Circovirus-like genome RW-C",
              "Circovirus-like genome RW-E",
              "Nepavirus",
              "Sewage-associated circular DNA virus-16",
              "Sewage-associated circular DNA virus-18",
              "Sewage-associated circular DNA virus-19",
              "Sewage-associated circular DNA virus-21",
              "Sewage-associated circular DNA virus-29",
              "Yellowstone Lake virophage 5",
              "Phytophthora parasitica virus",
              "Avon-Heathcote Estuary associated circular virus 24",
              "Avon-Heathcote Estuarv associated circular virus 3",
              "Blattelia germanica densovirus 1",
              "Blattella germanica densovirus-like virus",
              "Culex pipiens densovirus",
              "Dragonfly larvae associated circular virus-2",
              "Dragonfl larvae associated circular virus-3",
              "Dragonfly larvae associated circular virus-4",
              "Acanthamoeba castellanii mamavirus",
              "Acanthamoeba polyphaw mimivirus",
              "Megavirus Iba",
              "Circovirus-fike N112007",
              "Diporeia sp. associated circular virus",
              "Meles meles fecal virus",
              "Mosquito VEM virus SDRBAJ",
              "Odonata-associated circular virus-12",
              "Odonata-associated circular virus-13",
              "Odonata-associated circular virus-7",
              "Rodent stool-associated circular genome virus",
              "Sewage-associated circular DNA virus-1",
              "Sewage-associated circular DNA virus-11",
              "Sewage-associated circular DNA virus-13",
              "Sewage-associated circular DNA virus-14",
              "Sewage-associated circular DNA virus-6",
              "Sewage-associated circular DNA virus-7",
              "Sewage-associated circular DNA virus-8",
              "Virus Chimp162",
              "Avian leukosis virus",
              "Avian myeloblastosis virus",
              "Avian mveloblastosis-associated virus 1/2",
              "Avian myeloblastosis-associated virus type 1",
              "Avian myeloblastosis-associated virus type 2",
              "bat circovirus ZS/Yuonan-China/2009",
              "Circovtrus-like M/2007-3",
              "Dromedary stool-associated circular ssDNA virus",
              "Parvo-like hybrid virus UCI",
              "Parvo-like hybrid virus UCI 1",
              "Parvo-like hybrid virus UC12",
              "Parvo-like hybrid virus UC4",
              "Parvo-like hybrid virus UC8",
              "Parvo-like hybrid virus UC9",
              "Parvovirus MH-COV",
              "Rous sarcoma virus",
              "Tasmanian devil retrovirus",
              "Torque teno virus",
              "Semliki Forest virus")

sra %<>% mutate_cond(str_to_lower(Virus) %in% str_to_lower(problems), VirusFlagContaminant = TRUE)

sra %<>% mutate(HostTaxID = as.numeric(HostTaxID))
sra %<>% mutate(VirusTaxID = as.numeric(VirusTaxID))

sra$Virus <- NA

sra <- bind_rows(temp, sra)

sra %<>% mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", "HostClass",
                    "Virus", "VirusGenus", "VirusFamily", "VirusOrder", "VirusClass"),
                  tolower)

write_csv(sra, "Intermediate/Formatted/SRAFormatted.csv")
