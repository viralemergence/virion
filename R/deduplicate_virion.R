deduplicate_virion <- function(virion_clover_hosts){
  out <- virion_clover_hosts %>% 
    distinct() %>% 
    dplyr::mutate_all(as.character) %>% 
    dplyr::mutate_all(~tidyr::replace_na(.x, '')) %>%  
    dplyr::group_by_at(dplyr::vars(-NCBIAccession)) %>% 
    dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", "))

  return(out)
}