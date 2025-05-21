#' Read in current VMR spreadsheet
#'
#' @title
#' @param current_vmr_path Character. Path to vmr spreadsheet
#' @return
#' @author Albert Vill, Collin Schwantes
#' @export
read_current_vmr <- function(current_vmr_path) {
  
  vmr <- readxl::read_xlsx(path = current_vmr_path,
              sheet = "VMR MSL40",
              col_names = TRUE,
              col_ = c("text",
                       rep("numeric",2),
                       rep("text",25))) |>
    tibble::tibble(.name_repair = snakecase::to_snake_case) |>
    dplyr::select(where(not_all_na))

}


#' Check if an object is all NA
#' 
#' Used with select(where(...)) to drop columns that 
#' are all NA.
#'
#' @param x  An R object that can be passed to is.na
#'
#' @returns Logical. Is the object entirely composed of NAs?
#' @export
#'
not_all_na <- function(x){any(!is.na(x))} 



#' Find Taxa that are ALL assocaited with a particular host
#'
#' For each taxanomic designation from realm to species, check
#' if all individuals in that designation have the same host.
#'
#' @param data Data frame. vmr dataset
#' @param host Character. name(s) of host of interest
#'
#' @returns Data frame. All taxa that are associated with a particular host.
#' @export
#' @autho Albert Vill
#'
#' @examples
find_uniform_taxa <- function(data, host) {
    
    taxonomic_ranks <-
      c("realm", "kingdom","phylum",
        "subphylum","class", "order",
        "suborder","family","subfamily",
        "genus","subgenus","species")
    
    results <- list()
    
    for (rank in taxonomic_ranks) {
      grouped_data <-
        filter(data, !is.na(!!sym(rank))) |>
        group_by(across(all_of(rank))) |>
        summarise(All_Same_Host = all(host_source %in% host),
                  .groups = 'drop')
      
      uniform_taxa <-
        filter(grouped_data, All_Same_Host) |>
        select(taxonomic_name = !!sym(rank))
      
      if (nrow(uniform_taxa) > 0) {
        uniform_taxa <- uniform_taxa |>
          mutate(taxonomic_rank = rank)
        results[[rank]] <- uniform_taxa
      }
    }
    
    bind_rows(results) |>
      select(taxonomic_rank, taxonomic_name)
  }
