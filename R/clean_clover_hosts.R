#' Clean Clover host data in virion
#' 
#' Light cleaning of clover host data in virion. Converts any NA hostflag values
#' to FALSE, then checks for a specific name that is a known problem. 
#'
#' @param virion_ictv_ratified Data frame. Virion data with clover components
#'
#' @returns data frame. Data frame 
clean_clover_hosts <- function(virion_ictv_ratified){
  
  
  # clean up host data
  virion_clean_host <- virion_ictv_ratified %>%
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
  
  # rlang::inform("flagged cf\\.")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  virion_unique <- virion_host_flag %>% 
    # get unique records 
    dplyr::distinct() %>% 
    # convert everything to character
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        as.character)
    ) %>% 
    # remove all NAs and replace with blanks
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        ~tidyr::replace_na(.x, '')
      )
    )
  
  # rlang::inform("unique and character")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  virion_out <- virion_unique %>% 
    # roll up the ncbi accession numbers 
    dplyr::group_by(dplyr::pick(-NCBIAccession)) %>% 
    dplyr::mutate(AssocID = as.character(dplyr::cur_group_id())) %>% 
    dplyr::ungroup()
  
  # rlang::inform("now with group ids")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  return(virion_out)
  
}