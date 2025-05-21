#' Remove phages and other organisms
#' 
#' Removes phages and bacteri*
#'
#' @param virion_data Data frame. Virion data to be processed
#' @param phage_taxa Data frame. Phage taxa from vmr data.
#'
#' @returns
#' @export
#'
#' @examples
remove_phage <- function(virion_data = virion_unprocessed,phage_taxa){
  
  # set taxonomic names to lower for joining
  phage_taxa$taxonomic_name <- tolower(phage_taxa$taxonomic_name)
  
  
  for(taxa_rank in c("class","order","family","genus","species")){
    virion_data <- anti_join_taxa_rank(virion_data = virion_data, 
                                                  taxa_to_filter = phage_taxa,
                        taxa_rank = taxa_rank)
  }
  
  
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

  virion_col <- sprintf("Virus%s", stringr::str_to_sentence(taxa_rank))
  
  if(taxa_rank == "species"){
    virion_col <- "Virus"
  }
  
  virion_rename <- purrr::set_names(x = c("taxonomic_name") ,nm = virion_col )
  
  taxa_filtered <- taxa_to_filter |>
    dplyr::filter(taxonomic_rank == taxa_rank) |>
    dplyr::rename(all_of(virion_rename))
  
  virion_drop_taxa_rank  <- dplyr::anti_join(virion_data,
                                             taxa_filtered,
                                               by = virion_col)
  
  return(virion_drop_taxa_rank)
}
