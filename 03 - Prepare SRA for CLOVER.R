
library(magrittr)
library(tidyverse)

setwd("~/Github/virion")

sra <- read_delim("SRA_as_Edgelist.edges", delim = ',')

sra %>% 
  group_by(from, to) %>%
  summarize(score = max(score)) %>%
  rename(Virus = from, 
         Host = to) %>%
  unique() -> sra.v

clo <- read_csv("~/github/clover/output/Clover_v1.0_NBCIreconciled_20201211.csv")

# Mark the ones that are in CLOVER
clo %<>% mutate(Clover = 1)

# Join CLOVER and SRA
clo %<>% right_join(sra.v)

# Mark the ones that AREN'T in CLOVER
clo$Clover[is.na(clo$Clover)] <- 0

# Check out how score behaves

library(ggplot2)

ggplot(clo, aes(x = factor(Clover), y = log(score))) + 
  geom_violin()

# Time to threshold this in such a way that we're sure of what we're working with

library(PresenceAbsence)

clo %>% mutate(rownum = c(1:nrow(clo)),
               scaled = log(score)/max(log(score))) -> vir

vir %>% 
  select(Host, Virus, Clover, rownum, scaled) %>%
  unique() %>%
  select(rownum, Clover, scaled) -> 
  vir.sub

th <- optimal.thresholds(vir.sub,
                           threshold = 1001,
                           opt.methods = c(2,4,5,10,11),
                           req.sens = 0.99,
                           req.spec = 0.99,
                           na.rm = TRUE)

vir %<>% filter(Clover == 1 | scaled > th$scaled[th$Method == 'MaxKappa']) 

vir %>% count(Clover)
