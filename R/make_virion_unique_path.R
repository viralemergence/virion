


make_virion_unique_path <- function(virion_unprocessed,phage_taxa,ictv,file = "outputs/virion.csv.gz"){
  
  rlang::inform("removing phages")
  virion_no_phage <-remove_phage(virion_unprocessed,phage_taxa)
  
  rlang::inform("ratifying with ictv")  
  virion_ictv_ratified <- ratify_virus(virion_no_phage,ictv)
  
  rlang::inform("cleaning clover hosts")
  virion_clover_hosts <- clean_clover_hosts(virion_ictv_ratified)
  
  rlang::inform("rolling up NCBI numbers")
  virion_unique <- deduplicate_virion(virion_clover_hosts) ## rolls up NCBI accession numbers
  
  rlang::inform("writing file")
  virion_unique_path <- vroom::vroom_write(virion_unique,file = file ,delim = ",")
  
  return(virion_unique_path)
}