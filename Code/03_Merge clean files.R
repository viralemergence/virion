
library(tidyverse); library(magrittr); library(vroom); library(tidyft)

source("./Code/001_TaxizeFunctions.R")

vroom::locale(encoding = "UTF-8")

gb <- vroom("./Intermediate/Formatted/GenbankFormatted.csv.gz", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
clo <- vroom("./Intermediate/Formatted/CLOVERFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
pred <- vroom("./Intermediate/Formatted/PREDICTAllFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
globi <- vroom("./Intermediate/Formatted/GLOBIFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))

if(is.numeric(clo$NCBIAccession)) {clo %<>% dplyr::mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- dplyr::bind_rows(clo, pred, gb, globi)
  
# chr_cols <- names(virion[, sapply(virion, is.character)])
#   
# virion <- virion %>%
#   tidyft::utf8_encoding(chr_cols) 

vroom::vroom_write(virion, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz")

