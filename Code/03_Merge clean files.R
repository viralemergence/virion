
setwd("~/Github/virion")

library(tidyverse); library(magrittr); library(vroom)

gb <- read_csv("Intermediate/Formatted/GenbankFormatted.csv")
clo <- read_csv("Intermediate/Formatted/CloverFormatted.csv")
sra <- read_csv("Intermediate/Formatted/SRAFormatted.csv")
pred <- read_csv("Intermediate/Formatted/PredictFormatted.csv")
globi <- read_csv("Intermediate/Formatted/GLOBIFormatted.csv")

if(class(clo$NCBIAccession)=='numeric') {clo %<>% mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- bind_rows(clo, pred, gb, sra, globi)

vroom_write(virion, "Intermediate/Formatted/VIRIONUnprocessed.tsv.gz")

