
# 03_Adding SRA ####

library(magrittr)
library(tidyverse)
library(ggplot2)
library(PresenceAbsence)

# Load SRA, process to a maximum score based edgelist ####

if(!file.exists("Source/SRA_as_Edgelist.edges")){
  
  unzip("Source/SRA_as_Edgelist.zip", exdir = "Source")
  
}

sra <- read_delim("Source/SRA_as_Edgelist.edges", delim = ',')

sra %>% 
  group_by(from, to) %>%
  summarize(score = max(score)) %>%
  rename(Virus = from, 
         Host = to) %>%
  unique() -> sra.v

# Mark the ones that are in CLOVER

clo <- read_csv("Intermediate/Formatted/CloverFormatted.csv")

clo %<>% mutate(Clover = 1)

sra.v %<>% mutate(Virus = tolower(Virus),
                 Host = tolower(Host))

clo %<>% right_join(sra.v)

# Mark the ones that AREN'T in CLOVER

clo$Clover[is.na(clo$Clover)] <- 0

# Time to threshold this in such a way that we're sure of what we're working with ####

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

# Check out how score behaves

ggplot(clo, aes(x = factor(Clover), y = log(score)/max(log(clo$score)), fill = factor(Clover))) + 
  geom_violin() + 
  theme_bw() + 
  xlab("SRA association recorded in CLOVER?") + ylab("Maximum recorded virus hits in sample (log-transformed, rescaled)") + 
  geom_line(y = th$scaled[th$Method == 'MaxKappa'], col = 'red') + 
  geom_hline(aes(yintercept = th$scaled[th$Method == 'MaxKappa']), col = 'red', lty = 2) + 
  theme(axis.title.x = element_text(vjust = -1.5),
        axis.title.y = element_text(vjust = 5)) +
  scale_fill_manual(values = c("#00AFBB", "#00AFBB")) +
  theme(plot.margin = unit(c(1,1,1,1),"cm"),
        legend.position = 'n')

# Cut it off 

clo %<>% filter(Clover == 1 | scaled > th$scaled[th$Method == 'MaxKappa']) 

clo %>% count(Clover)

# Pull out the threshold from SRA-M we're going to apply to all of SRA-V

cut.score <- th$scaled[th$Method == 'MaxKappa']

# Now it's time to use this threshold ####

maxscore <- max(log(clo$score))

sra.v %>% 
  mutate(scaled = log(score)/maxscore) %>% # Needs to be scaled by the max sra.m score, because maybe there are other higher scores
  filter(scaled > cut.score) %>%  
  select(-scaled) %>%
  mutate( # Currently, there's no year metadata. Fix at the SRA generation stage @TP
         Database = "SRA",
         DatabaseVersion = "Dec2020FlatFile",
         DetectionMethod = "kmer", 
         DetectionOriginal = "SRA",
         HostOriginal = Host,
         VirusOriginal = Virus) -> sra

# Adding the dictionary step from GenBank script ####

sra %>% pull(Host) %>% unique() %>% sort() -> host.list
host.table <- hdict(host.list)

sra %>% pull(Virus) %>% unique() %>% sort() -> virus.list
virus.table <- vdict(virus.list)

# filter(Selected_class %in% c("Mammalia", # Selecting host taxa
#                              "Aves",
#                              "Reptilia",
#                              "Lepidosauria",
#                              "Actinopteri",
#                              "Actinopterygii",
#                              "Cladistia",
#                              "Hyperoartia",
#                              "Amphibia",
#                              "Chondrichthyes",
#                              "Elasmobranchii"))


sra %<>% ungroup %>% select(-c(Host, Virus)) %>%
  left_join(host.table) %>%
  left_join(virus.table) %>%
  select(-score) %>%
  unique()

# First pass cutting phage before you remove the relevant data

sra %<>% filter(!str_detect(Virus, "bacter"),
               !str_detect(Virus, "phage"))

write_csv(sra, "Intermediate/Unformatted/SRAUnformatted.csv")
