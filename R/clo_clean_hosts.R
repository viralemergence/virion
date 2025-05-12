#' Clean Clover Hosts
#'
#'
#' @title
#' @param clo Data frame. Clover data
#' @param clo_host_table Data frame. NCBI resolved host taxonomy
#' @return
#' @author collinschwantes
#' @export
clo_clean_hosts <- function(clo, clo_host_table) {


  # drop everything in clo except host
  clo_col_filter <- !names(clo_host_table) %in% "Host"
  clo_cols_to_drop <- names(clo_host_table)[clo_col_filter]

  # join to NCBI data
  out <- clo %>% 
    dplyr::select(-all_of(clo_cols_to_drop)) %>% 
    dplyr::rename(HostOriginal = "Host") %>%
    dplyr::mutate(HostOriginal = stringr::str_to_sentence(HostOriginal)) %>% 
    dplyr::left_join(clo_host_table,by = "HostOriginal") 
  
  
  return(out)
}
