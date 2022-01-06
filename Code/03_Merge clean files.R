
library(tidyverse); library(magrittr); library(vroom)

source("./Code/001_TaxizeFunctions.R")

gb <- vroom("./Intermediate/Formatted/GenbankFormatted.csv.gz", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
clo <- read_csv("./Intermediate/Formatted/CLOVERFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
pred <- read_csv("./Intermediate/Formatted/PREDICTAllFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))
globi <- read_csv("./Intermediate/Formatted/GLOBIFormatted.csv", col_type = cols(PMID = col_double(), PublicationYear = col_double()))

if(class(clo$NCBIAccession)=='numeric') {clo %<>% mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- bind_rows(clo, pred, gb, globi)

vroom_write(virion, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz")

