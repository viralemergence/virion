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
  virion_out <-remove_phage(virion_unprocessed,phage_taxa)
  
  rlang::inform("ratifying with ictv")  
  virion_out <- ratify_virus(virion_out,ictv)
  
  rlang::inform("cleaning clover hosts")
  virion_out <- clean_clover_hosts(virion_out)

  
  return(virion_out)
}