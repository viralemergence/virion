
# 04_Disaggregating VIRION ####

library(magrittr)
library(tidyverse)

# This script will eventually become a script that generates something akin to a SQL database

virion <- read_csv("Intermediate/Virion-Temp.csv")



write_csv(virion, './Virion/Virion-Master.csv')
