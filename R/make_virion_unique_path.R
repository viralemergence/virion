


make_virion_unique_path <- function(virion_unprocessed,phage_taxa,ictv,file = "outputs/virion.csv.gz"){
  
  rlang::inform("removing phages")
  virion_out <-remove_phage(virion_unprocessed,phage_taxa)
  
  rlang::inform("ratifying with ictv")  
  virion_out <- ratify_virus(virion_out,ictv)
  
  rlang::inform("cleaning clover hosts")
  virion_out <- clean_clover_hosts(virion_out)
  
  rlang::inform("rolling up NCBI numbers")
  virion_out <- deduplicate_virion(virion_out) ## rolls up NCBI accession numbers
  
  rlang::inform("writing file")
  virion_out <- vroom::vroom_write(virion_out,file = file ,delim = ",")
  
  return(virion_out)
}