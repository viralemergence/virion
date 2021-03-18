
library(tidyverse)

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

# Outstanding issues
# 1. Clean the virus names (e.g. influenza A subtypes )