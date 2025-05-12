#' Verify virus name against ictv
#'
#' Uses ICTV to verify NCBI name
#'
#' @param virion_no_phage Data frame. Virion data
#' @param ictv Data frame. From https://ictv.global/msl
#'
#' @returns
#' @export
#'
#' @examples
ratify_virus <- function(virion_no_phage,ictv){
  virion_ictv_ratified <-  virion_no_phage %>% dplyr::mutate(
    ICTVRatified = (Virus %in% stringr::str_to_lower(ictv$Species))) %>%
    dplyr::relocate(ICTVRatified, .after = VirusNCBIResolved)
  
  return(virion_ictv_ratified)
}