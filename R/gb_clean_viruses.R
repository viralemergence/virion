gb_clean_viruses <- function(gb_hosts_clean,virus_table){
  dplyr::rename(VirusOriginal = "Species") %>%
  dplyr::left_join(virus_table)
}