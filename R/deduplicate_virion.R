#' Deduplicate and clean Virion data
#'
#' Removes duplicate entries, mutates all fields to character, and does
#' some cleaning and summarizing.
#'
#' @param virion_clover_hosts Data frame. DF from clean_clover_hosts
#'
#' @returns data frame
#' @export
#'
#' @examples
deduplicate_virion <- function(virion_clover_hosts){
  # out <- virion_clover_hosts %>% 
  #   distinct() %>% 
  #   dplyr::mutate_all(as.character) %>% 
  #   dplyr::mutate_all(~tidyr::replace_na(.x, '')) %>%  
  #   dplyr::group_by_at(dplyr::vars(-NCBIAccession)) %>% 
  #   dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", ")) %>% 
  #   dplyr::ungroup()
  
  
  out <- virion_clover_hosts %>% 
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
    ) %>% 
    # roll up the ncbi accession numbers 
    dplyr::group_by(dplyr::pick(-NCBIAccession)) %>% 
    dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", ")) %>% 
    dplyr::ungroup()

  return(out)
}