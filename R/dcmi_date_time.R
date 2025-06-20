#' Time stamp formatted for DCMI compliance
#' 
#' 
#' @param x Date object. lubridate::today is default
#'
#' @return
#' @author collinschwantes
#' @export
dcmi_date_time <- function(x =lubridate::today()){
  sprintf("%sT00:00:00",x)
}
