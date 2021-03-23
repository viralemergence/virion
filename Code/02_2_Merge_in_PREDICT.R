
library(tidyverse)
library(magrittr)

virion <- read_csv("Intermediate/Virion-Temp.csv")

predict.raw <- read_csv("~/Github/ept/PredictData (2).csv")

predict.raw %>% select(`Sample Date`, 
                    `Species Scientific Name Based on Field Morphology`, 
                    Virus,
                    `Genbank #`) %>% 
  rename(Date = `Sample Date`,
         Host = `Species Scientific Name Based on Field Morphology`,
         Accession = `Genbank #`) %>%
  group_by_at(vars(-Accession)) %>% summarize(Accession = str_c(Accession, collapse = ", ")) %>%
  unique() %>%  # The below step deals with flagged host names
  mutate(HostFlagID = ifelse(str_detect(Host, "\\*"),'Flagged',NA)) %>%
  mutate(Host = str_replace(Host, " \\*","")) %>%
  mutate(Virus = str_replace(Virus, "strain of ","")) %>% # Remove "Strain of" from virus names
  group_by(Host, Virus, HostFlagID) %>%
  slice(which.min(Date)) -> predict # "Pull the first record of each, controlling for flagging"

################################## DETOUR: PLOT THE PREDICT DATA
# 
# library(tidyverse)
# library(igraph)
# library(ggraph)
# library(graphlayouts)
# library(oaqc)
# 
# predict %>% ungroup() %>% select(Host, Virus) %>% unique() -> clo
# 
# net <- graph.data.frame(as.data.frame(clo), directed = FALSE)
# 
# net <- set_vertex_attr(net, 'Type', index = V(net), 
#                        ifelse(V(net)$name %in% clo$Host, "Host", "Virus"))
# 
# # plot(net)
# 
# got_palette <- c("#325E9A", "#DD5D5D", "#325E9A", "#DD5D5D")
# 
# ggraph(net, layout = "stress") + # layout = "centrality", cent = graph.strength(net)) +
#   geom_edge_link0(edge_colour = "grey50", alpha = 0.3) +
#   geom_node_point(aes(fill = Type), colour = "grey50", shape = 21, size = 5, stroke = 0.25) +
#   scale_fill_manual(values = got_palette) +
#   theme_graph() +
#   theme(legend.position = "none",
#         panel.background = element_rect(fill = "#ADEADD"))
################################## 

library(lubridate)

predict %>% mutate(Collection_Year = year(Date),
                   Collection_Month = month(Date),
                   Collection_Day = day(Date),
                   Release_Year = 2021,
                   Release_Month = 3,
                   Release_Day = 9,
                   Database = "PREDICT",
                   DatabaseVersion = "March92021FlatFile",
                   DetectionMethod = "PCR/Sequencing") %>%
  select(-Date) -> predict

# First, let's fix some typos and such

predict %>% rowwise() %>% mutate(Virus = strsplit(Virus, split="\\(")[[1]][1]) -> predict
predict %>% rowwise() %>% mutate(Virus = strsplit(Virus, split=", subtype")[[1]][1]) -> predict
predict %>% rowwise() %>% mutate(Virus = strsplit(Virus, split=", partial subtype")[[1]][1]) -> predict

predict %>% mutate(Virus = recode(Virus, !!!c("Yellow Fever" = "Yellow fever virus", 
                                              "Dengue virus serotype 1" = "Dengue virus", 
                                              "Dengue virus serotype 2" = "Dengue virus", 
                                              "Dengue virus serotype 3" = "Dengue virus", 
                                              "Dengue virus serotype 4" = "Dengue virus", 
                                              "Influenza A" = "Influenza A virus",
                                              "Influenza B" = "Influenza B virus",
                                              "Human BK Polyomavirus" = "Human polyomavirus 1",
                                              "Porcine Parainfluenzavirus 1" = "Porcine parainfluenza virus",
                                              "Human Parainfluenzavirus 1" = "Human respirovirus 1",
                                              "Human Parainfluenzavirus 3" = "Human respirovirus 3",
                                              "Human Parainfluenzavirus 2" = "Human rubulavirus 2",
                                              "Human Parainfluenzavirus 4" = "Human rubulavirus 4",
                                              "Marburg Virus " = "Marburg marburgvirus",
                                              "MERS-like Coronovirus" = "Bat MERS-like coronavirus",
                                              "Monkey pox" = "Monkeypox virus",
                                              "Morogoro virus" = "Morogoro mammarenavirus",
                                              "SFVHpi" = "Simian foamy virus"))) -> predict


# Now: the taxonomy. First: generate a list of every PREDICT_ virus name 

predict %>% pull(Virus) %>% unique %>% str_subset("PREDICT_") %>%
  str_split("-") %>% unlist %>% str_subset("PREDICT_") %>% unique -> predict.prefix

predict.tax <- data.frame(Virus = sort(predict.prefix), 
                          full = NA,
                          VirusGenus = NA, 
                          VirusFamily = NA, 
                          VirusOrder = NA)

predict.tax[1,2:5] <- c("Adeno-associated virus", "Dependoparvovirus", "Parvoviridae", "Piccovirales")
predict.tax[2,2:5] <- c("Adenovirus", NA, "Adenoviridae", "Rowavirales")
predict.tax[3,2:5] <- c("Arenavirus", NA, "Arenaviridae", "Bunyavirales")
predict.tax[4,2:5] <- c("Bocaparvovirus", "Bocaparvovirus", "Parvoviridae", "Picornavirales")
predict.tax[5,2:5] <- c("Coronavirus", NA, "Coronaviridae", "Nidovirales")
predict.tax[6,2:5] <- c("Enterovirus", "Enterovirus", "Picornaviridae", "Picornavirales")
predict.tax[7,2:5] <- c("Flavivirus", "Flavivirus", "Flaviviridae", "Amarillovirales")
predict.tax[8,2:5] <- c("Hantavirus", NA, "Hantaviridae", "Bunyavirales")
predict.tax[9,2:5] <- c("Herpesvirus", NA, "Herpesviridae", "Herpesvirales")
predict.tax[10,2:5] <- c("Lentivirus", "Lentivirus", "Retroviridae", "Ortervirales")
predict.tax[11,2:5] <- c("Mamastrovirus", "Mamastrovirus", "Astroviridae", "Stellavirales")
predict.tax[12,2:5] <- c("Murine norovirus", "Norovirus", "Caliciviridae", "Picornavirales")
predict.tax[13,2:5] <- c("Orbivirus", "Orbivirus", "Reoviridae", "Reovirales")
predict.tax[14,2:5] <- c("Papillomavirus", NA, "Papillomaviridae", "Zurhausenvirales")
predict.tax[15,2:5] <- c("Picobirnavirus", NA, "Picobirnaviridae", "Durnavirales")
predict.tax[16,2:5] <- c("Phlebovirus", "Phleboviridae", "Phenuiviridae", "Bunyavirales")
predict.tax[17,2:5] <- c("Picornavirus", NA, "Picornaviridae", "Picornavirales")
predict.tax[18,2:5] <- c("Paramyxovirus", NA, "Paramyxoviridae", "Mononegavirales")
predict.tax[19,2:5] <- c("Posavirus", NA, NA, "Picornavirales")
predict.tax[20,2:5] <- c("Poxvirus", NA, "Poxviridae", "Chitovirales")
predict.tax[21,2:5] <- c("Polyomavirus", NA, "Polyomaviridae", "Sepolyvirales")
predict.tax[22,2:5] <- c("Rhabdovirus", NA, "Rhabdoviridae", "Mononegavirales")
predict.tax[23,2:5] <- c("Seadornavirus", "Seadornavirus", "Reoviridae", "Reovirales")

predict %>% pull(Virus) %>% unique -> predict.names

predict.tax.big <- data.frame(FullName = (predict.names %>% str_subset("PREDICT_")))

predict.tax.big %>% separate(col = FullName, into = c("Virus","Number"), sep = "-", remove = FALSE) %>% 
  left_join(predict.tax) %>% rename(Short = "Virus", Virus = "FullName") %>%
  select(-c("Short", "Number", "full")) -> predictionary

# Test run of the NCBI part of this

predict %>% pull(Virus) %>% str_subset("PREDICT", negate = TRUE) %>% unique() %>% sort() -> ncbi.names

ncbi.tax <- data.frame(Virus = ncbi.names,
                       VirusGenus = NA, 
                       VirusFamily = NA, 
                       VirusOrder = NA)

# usethis::edit_r_environ() then enter your API key

for (i in 1:nrow(ncbi.tax)) {
  ncbi.num <- taxize::get_uid(ncbi.tax$Virus[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {ncbi.tax$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {ncbi.tax$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {ncbi.tax$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
  }
}
 
# Add some guardrails 

for (i in 1:nrow(ncbi.tax)) {
  # "(?i)a"
  if(is.na(ncbi.tax$VirusOrder[i])){ # Only pull ones that haven't already been queried
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)cytomegalovirus")) {
      ncbi.tax$VirusGenus[i] <- "Cytomegalovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)adenovirus")) {
      ncbi.tax$VirusFamily[i] <- "Adenoviridae"
      ncbi.tax$VirusOrder[i] <- "Rowavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)alphacoronavirus")) {
      ncbi.tax$VirusGenus[i] <- "Alphacoronavirus"
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)betacoronavirus")) {
      ncbi.tax$VirusGenus[i] <- "Betacoronavirus"
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)coronavirus")) {
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)paramyxovirus")) {
      ncbi.tax$VirusFamily[i] <- "Paramyxoviridae"
      ncbi.tax$VirusOrder[i] <- "Mononegavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)foamy")) {
      ncbi.tax$VirusGenus[i] <- "Spumavirus"
      ncbi.tax$VirusFamily[i] <- "Retroviridae"
      ncbi.tax$VirusOrder[i] <- "Ortervirales"
    }
    
    #"Hantaviridae", "Bunyavirales")
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)hantavirus")) {
      ncbi.tax$VirusFamily[i] <- "Hantaviridae"
      ncbi.tax$VirusOrder[i] <- "Bunyavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)bocavirus")) {
      ncbi.tax$VirusGenus[i] <- "Bocaparvovirus"
      ncbi.tax$VirusFamily[i] <- "Parvoviridae"
      ncbi.tax$VirusOrder[i] <- "Picornavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)lymphocryptovirus")) {
      ncbi.tax$VirusGenus[i] <- "Lymphocryptovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)herpesvirus")) {
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)astrovirus")) {
      ncbi.tax$VirusFamily[i] <- "Astroviridae"
      ncbi.tax$VirusOrder[i] <- "Stellavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)rhadinovirus")) {
      ncbi.tax$VirusGenus[i] <- "Rhadinovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
  }
}

# And finally

ncbi.tax[ncbi.tax$Virus=="YN12103/CHN/2012","VirusFamily"] <- "Paramyxoviridae"
ncbi.tax[ncbi.tax$Virus=="YN12103/CHN/2012","VirusOrder"] <- "Mononegavirales"

ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusGenus"] <- "Alphacoronavirus"
ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusFamily"] <- "Coronaviridae"
ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusOrder"] <- "Nidovirales"

ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusGenus"] <- "Betacoronavirus"
ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusFamily"] <- "Coronaviridae"
ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusOrder"] <- "Nidovirales"

# Merge that bastard in

predict %<>% left_join(bind_rows(predictionary, ncbi.tax))

# How many don't have a genus?

predict %>% select(Virus, VirusGenus) %>% unique() %>% is.na %>% table()

# Now, the host taxonomy 

predict %>% pull(Host) %>% unique() -> hosts

hosts %>% # Go through these names and Taxize them 
  lapply(findSyns3) %>%
  bind_rows() -> test

table(test$Submitted == test$Accepted_name) # That's good, all valid names

test %>% rename(Host_Original = 'Original',
                Host = "Accepted_name",
                HostFamily = "Selected_family",
                HostOrder = "Selected_order", 
                HostClass = "Selected_class",
                HostSynonyms = "Synonyms") %>%
  select(-Submitted) %>%
  as_tibble() %>%
  group_by_at(vars(-HostSynonyms)) %>%
  summarise(HostSynonyms = toString(HostSynonyms)) -> test

predict %>% rename(Host_Original = "Host") %>% left_join(test) -> predict

virion <- read_csv('Intermediate/Virion-Temp.csv')

virion <- bind_rows(virion, predict) %>% 
  arrange(Host, Virus)

write_csv(virion, 'Intermediate/Virion-Temp.csv')

