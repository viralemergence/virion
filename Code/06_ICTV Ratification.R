
library(magrittr)
library(tidyverse)

tax <- read_csv("Virion/TaxonomyVirus.csv")
ictv <- read_csv("Source/ICTV Master Species List 2019.v1.csv")

tax %<>% mutate(ICTVRatified = (Virus %in% str_to_lower(ictv$Species)))
write_csv(tax, "Virion/TaxonomyVirus.csv")

