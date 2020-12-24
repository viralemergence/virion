
library(magrittr)
library(tidyverse)

setwd("~/Github/virion")

# Load SRA, process to a maximum score based edgelist

sra <- read_delim("./Source/SRA_as_Edgelist.edges", delim = ',')

sra %>% 
  group_by(from, to) %>%
  summarize(score = max(score)) %>%
  rename(Virus = from, 
         Host = to) %>%
  unique() -> sra.v

# Load SRA-mammals courtesy of Ryan's python script, and subset, to threshold appropriately

mammals <- read_csv("./Intermediate/taxonomy_mammal_hosts.csv")

sra.v %>% 
  filter(Host %in% mammals$name) -> sra.m

clo <- read_csv("~/github/clover/output/Clover_v1.0_NBCIreconciled_20201211.csv")

# Mark the ones that are in CLOVER
clo %<>% mutate(Clover = 1)

# Join CLOVER and SRA
clo %<>% right_join(sra.m)

# Mark the ones that AREN'T in CLOVER
clo$Clover[is.na(clo$Clover)] <- 0

# Check out how score behaves

library(ggplot2)

ggplot(clo, aes(x = factor(Clover), y = log(score))) + 
  geom_violin()

# Time to threshold this in such a way that we're sure of what we're working with

library(PresenceAbsence)

clo %>% mutate(rownum = c(1:nrow(clo)),
               scaled = log(score)/max(log(score))) -> clo

clo %>% 
  select(Host, Virus, Clover, rownum, scaled) %>%
  unique() %>%
  select(rownum, Clover, scaled) -> 
  clo.sub

th <- optimal.thresholds(clo.sub,
                           threshold = 1001,
                           opt.methods = c(2,4,5,10,11),
                           req.sens = 0.99,
                           req.spec = 0.99,
                           na.rm = TRUE)

clo %<>% filter(Clover == 1 | scaled > th$scaled[th$Method == 'MaxKappa']) 

clo %>% count(Clover)

# Pull out the threshold from SRA-M we're going to apply to all of SRA-V

cut.score <- th$scaled[th$Method == 'MaxKappa']

########################################################

# Now it's time to use this threshold 

virion <- read_csv("./Intermediate/Virion-Temp.csv")

maxscore <- max(log(sra.m$score))

sra.v %>% 
  mutate(scaled = log(score)/maxscore) %>% # Needs to be scaled by the max sra.m score, because maybe there are other higher scores
  filter(scaled > cut.score) %>%  
  select(-scaled) %>%
  mutate(Year = NA, # Fix at the SRA generation stage @TP
         YearType = "SRA", # Address collection-date versus publication-date by finding a way to include both - maybe reshape CLOVER format
         Database = "SRA",
         DatabaseVersion = "Dec2020FlatFile",
         DetectionMethod = "kmer", # Choice to call Nucleotide all sequence and not isolation is potentially problematic - revisit 
         Detection_NotSpecified = FALSE,
         Detection_Serology = FALSE,
         Detection_Genetic = FALSE,
         Detection_Isolation = FALSE,
         Host_Original = Host,
         Virus_Original = Virus,
         DetectionMethod_Original = "kmer", # Just to keep separate from EID2 Nucleotide entries
         Host_NCBIResolved = TRUE,
         Virus_NCBIResolved = TRUE,
         HostSynonyms = NA) -> virion.sra

virion %<>% bind_rows(virion.sra)

write_csv(virion, 'VIRION.csv')

########################################################

# Quickly check overlaps
# 
# memory.limit(10000000000)
# 
# library(ggregplot); library(igraph); library(colorspace); library(cowplot); library(patchwork)
# 
# virion %>% dplyr::select(Host, Virus, Database) %>% unique %>% 
#   unite("Assoc", Host, Virus, sep = "_") %>% 
#   table() -> M1
# 
# SocGraph <- graph_from_incidence_matrix(M1)
# Proj <- bipartite.projection(SocGraph)$proj2
# AM <- Proj %>% get.adjacency(attr = "weight") %>% as.matrix
# Observations = colSums(M1)
# Matrix <- AM
# N <- Matrix %>% nrow
# A <- rep(Observations, each = N)
# AMatrix <- matrix(A, ncol = N)
# AM <- (Matrix/(AMatrix))
# 
# AM %>% reshape2::melt() %>% 
#   rename_all(~str_replace(.x, "Var", "DB")) %>% 
#   mutate_at("value", 
#             ~(.x*100) %>% round) %>% 
#   mutate(Percent = paste0(value, "%")) %>% 
#   filter(!DB1 == DB2) %>% 
#   ggplot(aes(DB1, DB2)) + 
#   geom_tile(aes(fill = value)) + 
#   scale_y_discrete(limits = c(rev(colnames(AM)))) +
#   coord_fixed() + 
#   labs(x = NULL, y = NULL, fill = "% Shared") +
#   geom_text(aes(label = Percent, colour = as.factor(value>60))) +
#   scale_colour_manual(values = c("black", "white"), guide = F) +
#   scale_fill_continuous_sequential(palette = AlberPalettes[[1]], limits = c(0, 100))
# 
