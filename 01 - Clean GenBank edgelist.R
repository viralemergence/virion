
library(tidyverse)
setwd("~/Github/virion")

source("00 - taxize-cleaner-clone.R")

# Read in host data

unzip("GenBank_as_Edgelist.zip", exdir = getwd())
gb <- read_csv("GenBank_as_Edgelist.csv")
hosts_vec <- unique(na.omit(gb$Host))
synonyms <- lapply(1:20, findSyns3) # length(hosts_vec)
# ^ This is the one you're gonna want to switcheroo
synonyms %>% bind_rows() -> host.dictionary

gb2 <- left_join(gb, host.dictionary, by = c('Host' = 'Original'))
write_csv(gb2, 'GenBank-Taxized.csv')
zip(zipfile = 'GBTaxized.zip', files = 'GenBank-Taxized.csv')
