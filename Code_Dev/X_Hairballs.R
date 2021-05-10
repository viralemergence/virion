
library(tidyverse)
library(igraph)
library(ggraph)
library(graphlayouts)
library(oaqc)

vir <- vroom("Virion/Virion.csv.gz")

clo <- read_csv("~/Github/clover/clover/Clover_v1.0_NBCIreconciled_20201218.csv")

hp3 <- read_csv("~/Github/clover/data/source_databases/HP3_associations.csv")

vir %>% select(Host,Virus) %>% na.omit() %>% unique() -> vir

clo %>% select(Host, Virus) %>% 
  mutate(Host = str_c(Host, '_clo'),
         Virus = str_c(Virus, '_clo')) -> clo

hp3 %>% select(hHostNameFinal, vVirusNameCorrected) %>% 
  rename(Virus = 'vVirusNameCorrected',
         Host = 'hHostNameFinal') %>%
  mutate(Host = str_c(Host, '_hp3'),
         Virus = str_c(Virus, '_hp3')) -> hp3

vir %>% bind_rows(clo) %>% bind_rows(hp3) -> vir

vir %>% unique -> clo

net <- graph.data.frame(as.data.frame(clo), directed = FALSE)

net <- set_vertex_attr(net, 'Type', index = V(net), 
                ifelse(V(net)$name %in% clo$Host, "Host", "Virus"))

net <- decompose.graph(net, min.vertices = 500)
net <- union(net[[1]], net[[2]], net[[3]], byname = TRUE)
V(net)$Type <- ifelse(is.na(V(net)$Type_1),
                         ifelse(is.na(V(net)$Type_2), V(net)$Type_3, V(net)$Type_2),
                      V(net)$Type_1)

got_palette <- c("#325E9A", "#DD5D5D", "#325E9A", "#DD5D5D")

ggraph(net, layout = "stress") + # layout = "centrality", cent = graph.strength(net)) +
  geom_edge_link0(edge_colour = "grey50", alpha = 0.3) +
  geom_node_point(aes(fill = Type), colour = "grey50", shape = 21, size = 1, stroke = 0.25) +
  scale_fill_manual(values = got_palette) +
  theme_graph() +
  theme(legend.position = "none") # ,
    #   panel.background = element_rect(fill = "#ADEADD"))

