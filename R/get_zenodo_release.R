#' Get the DOI for the latest version of a Zenodo Deposit.
#' 
#' @param parent_id Character. Parent ID for a zenodo deposit with versioning.
#'
#' @return
#' @author collinschwantes
#' @export
get_zenodo_release_doi <- function(parent_id = "5819055") {

  parent_url <- sprintf("https://zenodo.org/api/records/%s",parent_id)
  
  parent_json <- jsonlite::fromJSON(txt = parent_url)
  
  return(parent_json$doi)
  
}
