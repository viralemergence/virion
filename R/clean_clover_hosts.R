#' Clean Clover host data in virion
#' 
#' Light cleaning of clover host data in virion
#'
#' @param virion_ictv_ratified Data frame. Virion data with clover components
#'
#' @returns data frame. Data frame 
clean_clover_hosts <- function(virion_ictv_ratified){
  
  virion_ictv_ratified %<>% 
    dplyr::mutate(HostFlagID = tidyr::replace_na(HostFlagID, FALSE)) 
  
  virion_ictv_ratified %<>%
    mutate_cond(stringr::str_detect(HostOriginal, " cf\\."), HostFlagID = TRUE) 
  
  virion_ictv_ratified %<>% 
    dplyr::select(-c(HostSynonyms))
  
  return(virion_ictv_ratified)
  
}