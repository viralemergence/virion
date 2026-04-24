#' Clean host components
#' 
#' cleans up the HostFlagID field and drops HostSynonyms 
#'
#' @param df 
#'
#' @returns
#' @export
#'
#' @examples
clean_host_fields <- function(df){
  # clean up host data
  virion_clean_host <- df %>%
    dplyr::select(-c(HostSynonyms)) %>% 
    dplyr::mutate(Host = tolower(Host))
  
  # rlang::inform("host to lower case and dropped host synonyms col")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  virion_clean_host <- virion_clean_host %>% 
    dplyr::mutate(HostFlagID = tidyr::replace_na(HostFlagID, FALSE))
  
  # rlang::inform("converted NA's to falses")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  virion_host_flag <- virion_clean_host %>% 
    dplyr::mutate(HostFlagID = case_when(
      stringr::str_detect(HostOriginal, " cf\\.") ~ TRUE,
      TRUE ~ HostFlagID
    )) 
}






