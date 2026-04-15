#' Clean and deduplicate VIRION data
#' 
#' combines several cleaning functions into a single step to reduce
#' targets overhead. See descriptions in remove_phage, ratify_virus, and clean_clover hosts.
#'
#' @param virion_unprocessed Data.frame. Uncleaned VIRION data.
#' @param phage_taxa Data.frame. Taxa identified as phages and unlikely to infect non-bacterial hosts
#' @param ictv Data.frame. Master species list.
#'
#' @returns Dataframe of cleaned VIRION data.
#' @export
#'
#' @examples
make_virion_unique<- function(virion_unprocessed,phage_taxa,ictv){
  
  rlang::inform("removing phages")
  virion_no_phage <-remove_phage(virion_unprocessed,phage_taxa)
  
  
  rlang::inform("ratifying with ictv")  
  virion_ratified <- ratify_virus(virion_no_phage,ictv)
  
  # system_stats
  
  # system2(command = "sh",args = "sys_deps/sys_specs.sh")
  
  # remove other inputs from memory before going into the memory intensive bit
  # gc(verbose = FALSE)
  
  rlang::inform("cleaning clover hosts")
  virion_out <- clean_clover_hosts(virion_ratified)

  
  return(virion_out)
}