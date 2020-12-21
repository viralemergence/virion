
library(tidyverse)
setwd("~/Github/virion")

source("00-taxize-cleaner-clone.R")

# read in host data

gb <- read_csv("GenBank_as_Edgelist.csv")

hosts_vec <- unique(na.omit(gb$Host))

start = Sys.time()
synonyms_lookup = lapply(1:500, findSyns3)
end = Sys.time()
end-start

synonyms_lookup %>% bind_rows() -> host.dictionary