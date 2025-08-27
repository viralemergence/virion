#' Deduplicate and clean Virion data
#'
#' Removes duplicate entries, mutates all fields to character, and does
#' some cleaning and summarizing.
#'
#' Writes virion output
#'
#' @param virion_clover_hosts Data frame. DF from clean_clover_hosts
#'
#' @returns data frame
#' @export
#'
#' @examples
deduplicate_virion <- function(virion_clover_hosts, path = "outputs/virion.csv.gz"){
  out <- virion_clover_hosts %>% 
    distinct() %>% 
    dplyr::mutate_all(as.character) %>% 
    dplyr::mutate_all(~tidyr::replace_na(.x, '')) %>%  
    dplyr::group_by_at(dplyr::vars(-NCBIAccession)) %>% 
    dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", ")) %>% 
    dplyr::ungroup()

  
  out_path <- vroom::vroom_write(out, path,delim = ",")
  
  return(out_path)
}