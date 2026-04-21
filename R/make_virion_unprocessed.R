#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param clo_formatted
#' @param predict_all_formatted_hosts_clean
#' @param gb_formatted
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
