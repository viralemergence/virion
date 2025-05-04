gb_clean_hosts <- function(gb,host_table){
  out <- gb %>% 
    dplyr::rename(HostOriginal = "Host") %>%
  dplyr::left_join(host_table,by = "HostOriginal") %>%
  dplyr::filter(HostClass %in% c("Actinopteri",
                                 "Amphibia",
                                 "Aves",
                                 "Chondrichthyes",
                                 "Cladistia",
                                 "Hyperoartia",
                                 "Lepidosauria",
                                 "Mammalia",
                                 "Myxini",
                                 "Reptilia") | HostOrder %in% 
           c("Testudines", "Crocodylia"))
            # Reptilia is defunct but left in case
            # it's reinstituted or something weird

  return(out)
}