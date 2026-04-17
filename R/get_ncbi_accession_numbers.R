#' Create NCBI Asscession Data
#' 
#' NCBI Accession Data in a nice table.
#' 
#' This function is necessary because NCBI accession data significantly increase
#' the size of the final data object.
#' 
#' @param viron_unique Data.frame Cleaned and unique virion records
#'
#' @return Data.frame. Rollup of NCBI accession numbers for each AssocID  
#' @author collinschwantes
#' @export
get_ncbi_accession_numbers <- function(viron_unique) {

  out <- viron_unique |>
    dplyr::select(AssocID, NCBIAccession) |>
    dplyr::group_by(AssocID) |>
    dplyr::summarise(NCBIAccession = stringr::str_flatten(string = NCBIAccession,collapse = ",")) |>
    dplyr::ungroup()
    

  return(out)
}
