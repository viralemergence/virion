#' binds data sets and shows resource use.
#' 
#' 
#' @param clo_formatted data.table Clover data
#' @param predict_all_formatted_hosts_clean data.table Predict data
#' @param gb_formatted data.table genbank data
#' @return
#' @author collinschwantes
#' @export
make_virion_unprocessed <- function(clo_formatted,
                                    predict_all_formatted_hosts_clean,
                                    gb_formatted) {

  system("sh ./sys_deps/sys_specs.sh")
  
  out <- dplyr::bind_rows(
    clo_formatted,
    predict_all_formatted_hosts_clean, 
    gb_formatted)

  
  return(out)
}
