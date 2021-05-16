
library(magrittr)
library(tidyverse)
library(vroom)

library(igraph)
library(ggraph)
library(graphlayouts)
library(oaqc)

vir <- vroom("Virion/Virion.csv.gz")

vir %<>% 
  filter(HostNCBIResolved == TRUE,
         VirusNCBIResolved == TRUE) %>%
  select(Host,Virus,Database) %>% 
  na.omit() %>% 
  unique()

vir %>%
  filter(Database=="HP3") %>%
  select(Host, Virus) %>% 
  unique() -> hp3

vir %>%
  select(Host, Virus) %>% 
  unique() -> vir 

hp3$Source = 'HP3'
vir$Source = 'VIRION'

hp3 %<>% mutate(Virus = str_c(Virus,"_hp3"),
                Host = str_c(Host, "_hp3"))

vir %>% bind_rows(hp3) -> vir
vir %<>% na.omit()

net <- graph.data.frame(as.data.frame(vir), directed = FALSE)

sub_gs <- components(net)
small_sub <- which(sub_gs$csize < 20)
(rm_nodes <- which(sub_gs$membership %in% small_sub))
net <- delete_vertices(net, rm_nodes)


net <- set_vertex_attr(net, 'Type', index = V(net), 
                ifelse(V(net)$name %in% vir$Host, "Host", "Virus"))

net <- set_vertex_attr(net, 'Source', index = V(net), 
                       ifelse(str_detect(V(net)$name, "_hp3"), "HP3", "VIRION"))

got_palette <- c("#325E9A", "#DD5D5D", "#325E9A", "#DD5D5D")

ggraph(net, layout = "kk") + 
  geom_edge_link(edge_colour = "grey80", alpha = 0.2) +
  geom_node_point(aes(fill = Type), colour = "grey50", shape = 21, size = 1.1, stroke = 0.8, alpha = 0.5) +
  scale_fill_manual(values = got_palette) +
  theme_bw() +
  facet_nodes( ~ Source, scales = "free", shrink = TRUE) + 
  theme(legend.position = "none",
        strip.text = element_text(size = 20),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background = element_rect(fill = "#ADEADD"),
        plot.background = element_rect(fill = "#ADEADD"))
