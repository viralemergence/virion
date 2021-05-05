
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

# Load SRA-mammals courtesy of Ryan's python script, and subset, to threshold appropriately ####

mammals <- read_csv("Intermediate/taxonomy_mammal_hosts.csv")

sra.v %>% 
  filter(Host %in% mammals$name) -> sra.m

if(file.exists("Intermediate/clover.csv")){
  
  clo <- read.csv("Intermediate/clover.csv")
  
}else{
  
  clo <- 
    read.csv("https://raw.githubusercontent.com/viralemergence/clover/main/output/Clover_v1.0_NBCIreconciled_20201218.csv")
  
  write.csv(clo, file = "Intermediate/clover.csv", row.names = F)
  
}

# Mark the ones that are in CLOVER
clo %<>% mutate(Clover = 1)

sra.m %>% mutate(Virus = tolower(Virus),
                 Host = tolower(Host)) -> sra.m2

# Join CLOVER and SRA
clo %<>% right_join(sra.m2, by = c("Pathogen_Harmonised" = "Virus", "HostHarmonised_Taxize" = "Host"))

# Mark the ones that AREN'T in CLOVER
clo$Clover[is.na(clo$Clover)] <- 0

# Time to threshold this in such a way that we're sure of what we're working with ####

clo %>% mutate(rownum = c(1:nrow(clo)),
               scaled = log(score)/max(log(score))) -> clo

clo %>% 
  select(HostHarmonised_Taxize, Pathogen_Harmonised, Clover, rownum, scaled) %>%
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

virion <- read_csv("Intermediate/Virion-Temp.csv")

maxscore <- max(log(clo$score))

sra.v %>% 
# sra.m %>% 
  mutate(scaled = log(score)/maxscore) %>% # Needs to be scaled by the max sra.m score, because maybe there are other higher scores
  filter(scaled > cut.score) %>%  
  select(-scaled) %>%
  mutate(#Year = NA, # Fix at the SRA generation stage @TP
         #YearType = "SRA", # Address collection-date versus publication-date by finding a way to include both - maybe reshape CLOVER format
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

# Adding the dictionary step from GenBank script ####

hosts_vec <- unique(na.omit(virion.sra$Host))

host.dictionary <- readRDS("Intermediate/HostDictionary.RDS")

NotInDictionary <- hosts_vec %>% # Identify host names not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

if(0){
  if(length(NotInDictionary)>0){ # Expanding the dictionary
    
    synonyms <- NotInDictionary %>% # Go through these names and Taxize them 
      lapply(findSyns3)
    
    # synonyms %>% 
    #   seq_along %>% 
    #   map(~ifelse(is.null(synonyms[[.x]]), 
    #               data.frame(Original = NotInDictionary[.x]),
    #               synonyms[[.x]])) ->
    #   synonyms
    
    synonyms %>% bind_rows() %>% # Attach those taxized names to the dictionary
      bind_rows(host.dictionary) -> 
      host.dictionary
    
    host.dictionary %<>% arrange(Original) # arrange by name
    
    write_rds(host.dictionary, "Intermediate/HostDictionary.RDS")
    
  }
}

StillNotInDictionary <- hosts_vec %>% # Identify host names STILL not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

data.frame(Original = StillNotInDictionary) %>% 
  bind_rows(host.dictionary, .) ->
  host.dictionary

# Double check if the dictionary needs expansion ####

# if(1){ # Set to not run

dict2 <- data.frame(Original = hosts_vec)

dict2 %>% 
  as_tibble %>%
  left_join(host.dictionary) -> dict2

for (i in 1:nrow(dict2)) {
  if(dict2$Original[i] %in% dict2$Synonyms) {
    dict2$Accepted_name[i] <- dict2$Accepted_name[which(dict2$Synonyms == dict2$Original[i])]
    print(i)
  }
}

ToGroup <- dict2 %>% names %>% setdiff(c("Submitted", "Synonyms"))

dict2 %>% 
  group_by_at(ToGroup) %>% #names
  summarise_at(c("Submitted", "Synonyms"), list) %>% # Adding the Taxize information to the data frame
  dplyr::select(-c(Submitted, Synonyms)) %>% 
  unique %>% #nrow %>% 
  left_join(virion.sra, ., by = c('Host' = 'Original')) ->
  virion.sra2 # <- left_join(gb, host.dictionary, by = c('Host' = 'Original'))

virion.sra2 %>% 
  filter(Selected_class %in% c("Mammalia", # Selecting host taxa
                               "Aves",
                               "Reptilia",
                               "Amphibia",
                               "Chondrichthyes",
                               "Elasmobranchii")) %>%
  
  select(Virus, # Selecting and renaming columns
         Host,
         # Year, 
         Selected_family, Selected_order, Selected_class) %>% 
  unique() -> virion.sra2

virion.sra2 %>% # Renaming to match other databases 
  rename_all(~.x %>% str_replace_all("Selected_", "Host") %>% 
               str_replace_all(c("class" = "Class", "order" = "Order", "family" = "Family"))) ->
  
  virion.sra2

virion.sra2 %<>%
  mutate(# Year = NA, # Fix at the SRA generation stage @TP
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
         HostSynonyms = NA)

### Add the viral higher taxonomy

virion.sra2 %>% pull(Virus) %>% unique() %>% sort() -> ncbi.names

sra.tax <- data.frame(Virus = ncbi.names,
                       VirusGenus = NA, 
                       VirusFamily = NA, 
                       VirusOrder = NA)

for (i in 1:nrow(sra.tax)) {
  sra.num <- taxize::get_uid(sra.tax$Virus[i])
  sra.high <- taxize::classification(sra.num, db = "ncbi")
  if(!is.na(sra.high[[1]][1])){
    if("genus" %in% sra.high[[1]]$rank) {sra.tax$VirusGenus[i] <- sra.high[[1]][which(sra.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% sra.high[[1]]$rank) {sra.tax$VirusFamily[i] <- sra.high[[1]][which(sra.high[[1]]$rank=='family'), 'name']}
    if("order" %in% sra.high[[1]]$rank) {sra.tax$VirusOrder[i] <- sra.high[[1]][which(sra.high[[1]]$rank=='order'), 'name']}
  }
}

virion.sra2 %<>% left_join(sra.tax)

# NOW... kill the virus associations but leave the originals

virion.sra2$Virus <- NA

# Combining with the rest of virion ####

virion <- read_csv("Intermediate/Virion-Temp.csv")

virion %<>% bind_rows(virion.sra2)

write_csv(virion, 'Virion/Virion-Master.csv')
