
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

start <- print(Sys.time())

g <- ggraph(net, layout = "kk") + 
  geom_edge_link(edge_colour = "grey80", alpha = 0.2) +
  geom_node_point(aes(fill = Type), colour = "grey50", shape = 21, size = 1.1, stroke = 0.8, alpha = 0.5) +
  scale_fill_manual(values = got_palette) +
  facet_nodes( ~ Source, scales = "free", shrink = TRUE) + 
  labs(fill = "") +
  theme_graph(strip_text_face = "plain", strip_text_size = 22, caption_size = 20, base_size = 20) 


ggsave(g,  filename = 'hairball.jpg', width = 40, height = 20, units = 'cm', dpi = 600)

dev.off()

end <- print(Sys.time())

print(end - start)