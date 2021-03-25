
library(tidyverse); library(magrittr)

clo <- read_csv("Intermediate/CLOVERT_ReconciledAssociations_Taxize.csv")

clo %>% pull(Pathogen_Harmonised) %>% unique() -> path.list

path.tax <- jncbi(path.list, type = 'virus')

clo %>% pull(Host_Harmonised) %>% unique() -> host.list

host.tax <- jncbi(host.list, type = 'host')
