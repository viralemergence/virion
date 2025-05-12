#' Clean Clover Viruses
#' 
#'  Add NCBI resolved virus taxonomy
#' 
#' @title
#' @param clo_hosts_clean Data frame. Clover data 
#' @param clo_virus_table Data frame. NCBI resolved virus data
#' @return
#' @author collinschwantes
#' @export
clo_clean_viruses <- function(clo_hosts_clean, clo_virus_table) {

  
  # drop pathogen cols
  clo_hosts_clean %>% 
    dplyr::mutate(VirusOriginal = stringr::str_to_sentence(Pathogen)) %>% 
    dplyr::select(- tidyselect::matches("Pathogen")) %>% 
    dplyr::left_join(clo_virus_table,by = "VirusOriginal")
}
