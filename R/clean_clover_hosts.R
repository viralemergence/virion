clean_clover_hosts <- function(virion_ictv_ratified){
  
  virion_ictv_ratified %<>% 
    dplyr::mutate(HostFlagID = replace_na(HostFlagID, FALSE)) 
  
  virion_ictv_ratified %<>%
    mutate_cond(stringr::str_detect(HostOriginal, " cf\\."), HostFlagID = TRUE) 
  
  virion_ictv_ratified %<>% 
    dplyr::select(-c(HostSynonyms))
  
  return(virion_ictv_ratified)
  
}