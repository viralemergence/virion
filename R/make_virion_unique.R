#' Make virion data character and unique
#' 
#'  Takes unprocessed virion data and makes it unique.
#'
#' @param virion_unprocessed Data frame. Virion data with clover components
#'
#' @returns data frame. Data frame 
make_virion_unique <- function(virion_unprocessed){
  
  # rlang::inform("flagged cf\\.")
  # print(lobstr::obj_size(virion_ictv_ratified))
  
  virion_unique <- virion_unprocessed %>% 
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