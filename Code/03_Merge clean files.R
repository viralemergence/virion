
setwd("~/Github/virion")

library(tidyverse); library(magrittr)

gb <- read_csv("Intermediate/Formatted/GenbankFormatted.csv")
clo <- read_csv("Intermediate/Formatted/CloverFormatted.csv")
pred <- read_csv("Intermediate/Formatted/PredictFormatted.csv")
globi <- read_csv("Intermediate/Formatted/GLOBIFormatted.csv")

if(class(clo$NCBIAccession)=='numeric') {clo %<>% mutate(NCBIAccession = as.character(NCBIAccession))}

virion <- bind_rows(clo, pred, gb, globi)

write_csv(virion, "Intermediate/Formatted/VIRIONUnprocessed.csv")
