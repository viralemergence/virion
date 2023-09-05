
library(tidyverse); library(magrittr); library(vroom); library(tidyft)

source("./Code/001_TaxizeFunctions.R")

vroom::locale(encoding = "UTF-8")

gb <- vroom("./Intermediate/Formatted/GenbankFormatted.csv.gz", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
print("gb")
clo <- vroom("./Intermediate/Formatted/CLOVERFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double(),
                                                                             ReferenceText = col_character()))
print("clo")
pred <- vroom("./Intermediate/Formatted/PREDICTAllFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
print("pred")
globi <- vroom("./Intermediate/Formatted/GLOBIFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
print("globi")

if(is.numeric(clo$NCBIAccession)) {clo %<>% dplyr::mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- dplyr::bind_rows(clo, pred, gb, globi)
#   
# chr_cols <- names(virion[, sapply(virion, is.character)])
# virion <- virion %>%
#   tidyft::utf8_encoding(chr_cols)

top <-
  virion %>% 
    dplyr::filter(Host == "abramis brama",
                  Virus == "infectious pancreatic necrosis virus",
                  HostTaxID == 38527)


vroom::vroom_write(virion, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz",
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

