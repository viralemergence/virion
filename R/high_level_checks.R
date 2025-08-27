#' High level checks of virion
#' 
#' Combined high level checks to save storage space on github actions.
#'
#' @param virion_unprocessed tibble. Unprocessed virion data
#' @param phage_taxa tibble. Phage taxa info
#' @param ictv tibble. ICTV master species list names
#' @return tibble
#' @author collinschwantes
#' @export
high_level_checks <- function(virion_unprocessed = virion_unprocessed,
                              phage_taxa = phage_taxa, ictv = ictv) {

  virion_no_phage <- remove_phage(virion_unprocessed,phage_taxa)
  virion_ictv_ratified <- ratify_virus(virion_no_phage,ictv)
  virion_clover_hosts <- clean_clover_hosts(virion_ictv_ratified)
  virion_unique_path <- deduplicate_virion(virion_clover_hosts)
  
  return(virion_unique_path)
}
