
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
  filter(!(VirusFamily %in% c("turriviridae",
                             "ackermannviridae",
                             "myoviridae",
                             "siphoviridae",
                             "podoviridae",
                             "sphaerolipoviridae",
                             "pleoplipoviridae",
                             "tectiviridae",
                             "leviviridae",
                             "lipothrixviridae",
                             "rudiviridae",
                             "cystoviridae",
                             "microviridae",
                             "inoviridae",
                             "corticoviridae",
                             "ampullaviridae",
                             "bicaudaviridae",
                             "clavaviridae",
                             "finnlakeviridae",
                             "fuselloviridae",
                             "globuloviridae",
                             "guttaviridae",
                             "plasmaviridae",
                             "portogloboviridae",
                             "spiraviridae",
                             "tristomaviridae",
                             "megaviridae")),
         !(VirusOrder %in% c("belfryvirales",
                             "caudovirales",
                             "halopanivirales",
                             "haloruvirales",
                             "kalamavirales",
                             "levivirales",
                             "ligamenvirales",
                             "mindivirales",
                             "petitvirales",
                             "tubulavirales",
                             "vinavirales")))

ictv <- read_csv("Source/ICTV Master Species List 2019.v1.csv")

virion %<>% mutate(ICTVRatified = (Virus %in% str_to_lower(ictv$Species)))

vroom_write(virion, "Virion/Virion.csv.gz")
