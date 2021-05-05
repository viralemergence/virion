
virion <- vroom("Intermediate/Formatted/VIRIONUnprocessed.tsv.gz")

# Is there anything that's not vertebrate in here?

virion %>% filter(!(HostClass %in% c("actinopteri",
                                     "actinopterygii",
                                     "amphibia",
                                     "aves",
                                     "chondrichthyes",
                                     "cladistia",
                                     "hyperoartia",
                                     "lepidosauria",
                                     "mammalia",
                                     "myxini",
                                     "reptilia"))) %>%
  filter(!is.na(HostClass)) %>% View()

# Deal with the phage 
  
virion %<>% 
  filter(!str_detect(Virus, "phage"),
         !str_detect(Virus, "bacteri")) %>%
  filter(!(VirusFamily %in% c("Turriviridae",
                             "Ackermannviridae",
                             "Myoviridae",
                             "Siphoviridae",
                             "Podoviridae",
                             "Sphaerolipoviridae",
                             "Pleoplipoviridae",
                             "Tectiviridae",
                             "Leviviridae",
                             "Lipothrixviridae",
                             "Rudiviridae",
                             "Cystoviridae",
                             "Microviridae",
                             "Inoviridae",
                             "Corticoviridae",
                             "Ampullaviridae",
                             "Bicaudaviridae",
                             "Clavaviridae",
                             "Finnlakeviridae",
                             "Fuselloviridae",
                             "Globuloviridae",
                             "Guttaviridae",
                             "Plasmaviridae",
                             "Portogloboviridae",
                             "Spiraviridae",
                             "Tristomaviridae")),
         !(VirusOrder %in% c("Belfryvirales",
                             "Caudovirales",
                             "Halopanivirales",
                             "Haloruvirales",
                             "Kalamavirales",
                             "Levivirales",
                             "Ligamenvirales",
                             "Mindivirales",
                             "Petitvirales",
                             "Tubulavirales",
                             "Vinavirales")))

vroom_write(virion, "Intermediate/Formatted/VIRIONUnprocessed.tsv.gz")
