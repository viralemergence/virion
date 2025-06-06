#' Clean Clover host data in virion
#' 
#' Light cleaning of clover host data in virion. Converts any NA hostflag values
#' to FALSE, then checks for a specific name that is a known problem. 
#'
#' @param virion_ictv_ratified Data frame. Virion data with clover components
#'
#' @returns data frame. Data frame 
clean_clover_hosts <- function(virion_ictv_ratified){
  
  virion_host_flag <- virion_ictv_ratified %>%  
    dplyr::mutate(HostFlagID = tidyr::replace_na(HostFlagID, FALSE)) 
  
  virion_flag_cf <- virion_host_flag %>% 
    dplyr::mutate(HostFlagID = case_when(
      stringr::str_detect(HostOriginal, " cf\\.") ~ TRUE,
      TRUE ~ HostFlagID
    )) %>% 
    dplyr::select(-c(HostSynonyms))
  
  return(virion_flag_cf)
  
}