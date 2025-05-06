get_virion_edge_list <- function(virion_reduced_tax){
  
  virion_edge_list <- virion_reduced_tax %>%
    select(-c(Database, DatabaseVersion,
              ReferenceText, 
              PMID,
              DetectionMethod, DetectionOriginal, 
              HostOriginal, VirusOriginal,
              HostFlagID,
              NCBIAccession,
              PublicationYear, 
              ReleaseYear, ReleaseMonth, ReleaseDay,
              CollectionYear, CollectionMonth, CollectionDay)) %>% 
    group_by(HostTaxID, VirusTaxID) %>%
    summarise_at(vars(c("AssocID")), ~list(.x)) %>%
    mutate(AssocID = sapply(AssocID, fixer))
  
  return(virion_edge_list)
}

fixer <- function(x) {toString(unique(unlist(x)))}