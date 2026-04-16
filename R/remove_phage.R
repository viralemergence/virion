#' Remove phages and other organisms
#' 
#' Removes phages and bacteri*
#'
#' @param virion_data Data frame. Virion data to be processed
#' @param phage_taxa Data frame. Phage taxa from vmr data.
#' @param taxa_ranks Character. Vector of taxa ranks. See ICTV taxonomy for ranks.
#'
#' @returns
#' @export
#'
#' @examples
remove_phage <- function(virion_data = virion_unprocessed,
                         phage_taxa, 
                         taxa_ranks = c("order","family","genus","species")){
  
  if(is.null(taxa_ranks)){
    message("No taxa ranks supplied, returning virion_data")
    return(virion_data)
  }
  
  # set taxonomic names to lower for joining
  phage_taxa$taxonomic_name <- tolower(phage_taxa$taxonomic_name)
  
  # loop through each rank and remove taxa
  for(taxa_rank in taxa_ranks){
    virion_data <- anti_join_taxa_rank(virion_data = virion_data, 
                                                  taxa_to_filter = phage_taxa,
                        taxa_rank = taxa_rank)
  }
  
  
  virion_data <- data.table::setkey(virion_data,NULL)
  
  return(virion_data)
}

#' Filter out taxa by rank
#'
#' @param virion_data Data frame. Virion data
#' @param taxa_to_filter Data frame. Taxa of interest from vmr
#' @param taxa_rank 
#'
#' @returns
#' @export
#'
#' @examples
anti_join_taxa_rank <- function(virion_data,taxa_to_filter, taxa_rank){
  # browser()
  virion_col <- sprintf("Virus%s", stringr::str_to_sentence(taxa_rank))
  
  if(taxa_rank == "species"){
    virion_col <- "Virus"
  }
  
  ### equivalent to by = c("taxonmic_name" = virion_col)
  virion_rename <- purrr::set_names(x = c("taxonomic_name") ,nm = virion_col )
  
  taxa_filtered <- taxa_to_filter |>
    dplyr::filter(taxonomic_rank == taxa_rank) |>
    dplyr::rename(all_of(virion_rename))
  
  # this now goes over the memory limit for a free github action runner
  # single operation over 17 gb
  # virion_drop_taxa_rank  <- dplyr::anti_join(virion_data,
  #                                            taxa_filtered,
  #                                              by = virion_col)
  
  # has a higher overall load but no single operation over 10 gb
  dt_virion <- data.table::setkeyv(x = virion_data,virion_col )
  dt_taxa <- as.data.table(taxa_filtered, key = virion_col)
  # # Anti-join: Rows in dt_virion not in dt_taxa
  virion_drop_taxa_rank <- dt_virion[!dt_taxa, on = virion_col]
  
  return(virion_drop_taxa_rank)
}
