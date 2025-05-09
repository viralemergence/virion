#' Creates an edge list for virion data
#' 
#' Makes an edge list between hosts and viruses
#'
#' @param virion_reduced_tax Data frame. Virion data 
#'
#' @returns data frame. Edge list of hosts and viruses
#' @export
#'
#' @examples
get_virion_edge_list <- function(virion_reduced_tax){
  
  virion_edge_list <- virion_reduced_tax %>%
    select(-c(Database, DatabaseVersion,
              ReferenceText, 
              PMID,
              DetectionMethod, DetectionOriginal, 
              HostOriginal, VirusOriginal,
              HostFlagID,
              NCBIAccession,
              PublicationYear, 
              ReleaseYear, ReleaseMonth, ReleaseDay,
              CollectionYear, CollectionMonth, CollectionDay)) %>% 
    group_by(HostTaxID, VirusTaxID) %>%
    summarise_at(vars(c("AssocID")), ~list(.x)) %>%
    mutate(AssocID = sapply(AssocID, fixer))
  
  return(virion_edge_list)
}

#' Get unique strings from list
#' 
#' @param x list. Single level list 
#'
#' @returns Character. Character vector with unique values
#' @export
#'
#' @examples
fixer <- function(x) {toString(unique(unlist(x)))}