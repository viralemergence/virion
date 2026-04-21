#' Align predict hosts with the NCBI backbone
#'
#' 
#'
#' @param predict_all_formatted data frame. Predict data
#' @param pre_host_table data frame. host table from jhdict
#' @return
#' @author collinschwantes
#' @export
pre_clean_hosts <- function(predict_all_formatted, pre_host_table) {

  # drop everything in predict except host
  pre_col_filter <- !names(pre_host_table) %in% "HostOriginal"
  pre_cols_to_drop <- names(pre_host_table)[pre_col_filter]
  
  # join to NCBI data
  out <- predict_all_formatted %>% 
    dplyr::select(-all_of(pre_cols_to_drop)) %>% 
    dplyr::mutate(HostOriginal = stringr::str_to_sentence(HostOriginal)) %>% 
    dplyr::left_join(pre_host_table,relationship = "many-to-many",by = "HostOriginal") 

  # get col order
  col_order <- names(predict_all_formatted)
  
  # host columns to lower
  host_cols <- c("Host",
                 "HostGenus",
                 "HostFamily",
                 "HostOrder",
                 "HostClass")
  
  out <- out %>% 
    dplyr::select(all_of(col_order)) |>
    dplyr::mutate(across(all_of(host_cols), tolower))
  
  # to lower all host names
  
  
  
  return(out)
}
