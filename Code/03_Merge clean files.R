
library(tidyverse); library(magrittr); library(vroom); library(tidyft)

source("./Code/001_TaxizeFunctions.R")

vroom::locale(encoding = "UTF-8")

gb <- vroom("./Intermediate/Formatted/GenbankFormatted.csv.gz", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
print("gb")
clo <- readr::read_csv("./Intermediate/Formatted/CLOVERFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double(),
                                                                             ReferenceText = col_character()))
print("clo")
pred <- vroom("./Intermediate/Formatted/PREDICTAllFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
print("pred")

if(is.numeric(clo$NCBIAccession)) {clo %<>% dplyr::mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- dplyr::bind_rows(clo, pred, gb)
#   
# chr_cols <- names(virion[, sapply(virion, is.character)])
# virion <- virion %>%
#   tidyft::utf8_encoding(chr_cols)

top <-
  virion %>% 
    dplyr::filter(Host == "abramis brama",
                  Virus == "infectious pancreatic necrosis virus",
                  HostTaxID == 38527)


vroom::vroom_write(virion, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz")

