#' Clean Genbank Virus Data
#' 
#' Cleans the virus data in genbank and adds NCBI taxonomic designation
#'
#' @param gb_hosts_clean 
#' @param virus_table 
#'
#' @returns
#' @export
#'
#' @examples
gb_clean_viruses <- function(gb_hosts_clean,virus_table){
  gb_hosts_clean %>% 
  dplyr::rename(VirusOriginal = "Species") %>%
  dplyr::left_join(virus_table, by = "VirusOriginal")
}