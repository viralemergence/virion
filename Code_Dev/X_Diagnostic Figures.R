
# X_Various Virion Figures ####

{
  
  library(ggregplot); library(colorspace); library(cowplot); library(fs)
  
  theme_set(theme_cowplot())
  
  dir_create("Figures")
  
  virion <- read_csv('VIRION.csv')
  virion %<>% filter(HostClass == "Mammalia")
  
}

# Discovery over time ####

Accumulation <- virion %>% # Discovery over years 
  arrange(Year) %>% group_by(Host, Virus, Database) %>% filter(Year == min(Year)) %>% ungroup %>% 
  group_by(Database) %>% mutate(N = 1:n()) %>% mutate(PropN = N/max(N)) 

Accumulation %>% 
  ggplot(aes(Year, N)) + 
  geom_hline(yintercept = 0, alpha = 0.6) +
  geom_line(aes(colour = Database)) + coord_fixed(ratio = 100/max(Accumulation$N)) +
  ggsave("Figures/PublicationDiscovery.jpeg")

virion %>% mutate_at(vars(contains("Date")), ~.x %>% str_split("-") %>% map_chr(1) %>% as.numeric) %>% 
  RandomSlice %>% 
  mutate(Colour = as.factor(1:n())) %>% 
  filter(Collection_Date > 1950) %>% 
  ggplot(aes(Collection_Date, Publication_Date)) + 
  # geom_point(colour = AlberColours[[3]]) + 
  geom_point(aes(colour = Colour), alpha = 0.1) +
  scale_colour_discrete_sequential(palette = AlberPalettes[[3]]) +
  # geom_smooth(method = lm) + 
  geom_smooth(colour = "black") + 
  geom_abline() + 
  coord_fixed() +
  theme(legend.position = "none") +
  ggsave("Figures/CollectionPublicationDate.jpeg", units = "mm", height = 150, width = 200, dpi = 600)

# virion %>% mutate_at(vars(contains("Date")), ~.x %>% str_split("-") %>% map_chr(1) %>% as.numeric) %>% 
#   filter(Collection_Date > 1950, Publication_Date > 2004) %>% 
#   ggplot(aes(x = Collection_Date, y = as.factor(Publication_Date))) + 
#   geom_density_ridges2(alpha = 0.8, colour = NA,
#                        fill = AlberColours[[3]]) +
#   labs(x = "Collection Date", y = "Publication Date")

# Proportion overlap ####

virion %>% 
  dplyr::select(Host, Virus, Database) %>% unique %>% 
  unite("Assoc", Host, Virus, sep = "_") %>% 
  table() -> M1

AssocFunction <- function(a){
  
  print(a)
  
  M1[M1[,a]==1,] %>% colSums %>% divide_by(sum(M1[,a])) %>% return
  
}

M1 %>% colnames %>% map(c(AssocFunction, as_tibble)) %>% bind_cols %>% as.matrix ->
  AM

dimnames(AM) <- list(colnames(M1), colnames(M1))

Plot3 <- AM %>% reshape2::melt() %>% 
  rename_all(~str_replace(.x, "Var", "DB")) %>% 
  mutate_at("value", 
            ~(.x*100) %>% round) %>% 
  mutate(Percent = paste0(value, "%")) %>% 
  filter(!DB1 == DB2) %>% 
  ggplot(aes(DB1, DB2)) + 
  geom_tile(aes(fill = value)) + 
  scale_y_discrete(limits = c(rev(colnames(AM)))) +
  coord_fixed() + 
  labs(x = NULL, y = NULL, fill = "% Shared") +
  geom_text(aes(label = Percent, colour = as.factor(value>60))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_colour_manual(values = c("black", "white"), guide = F) +
  scale_fill_continuous_sequential(palette = AlberPalettes[[1]], limits = c(0, 100))

Plot3 + ggsave("ProportionalAssociationOverlap.jpeg")
