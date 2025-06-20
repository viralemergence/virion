#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ictv_url
#' @param current_msl_path
#' @return
#' @author collinschwantes
#' @export
get_ictv_version <- function(ictv_url = "https://ictv.global/sites/default/files/MSL/", current_msl_path) {

  file_name_msl <- fs::path_file(current_msl_path)
  
  out <- sprintf("%s%s",ictv_url,file_name_msl)
  
  return(out)
}
