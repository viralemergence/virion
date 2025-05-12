#' Not used - Install Julia packages to use the functions for NCBI
#' 
#' Here we use the JuliaCall library to get the funcitons we need 
#' 
#' 
#' @returns
#' @export
#'
#' @examples
install.ncbi <- function() {
  
  # install the packages if needed 
  JuliaCall::julia_install_package_if_needed("NCBITaxonomy")
  JuliaCall::julia_install_package_if_needed("DataFrames")
  JuliaCall::julia_install_package_if_needed("CSV")
  JuliaCall::julia_install_package_if_needed("ProgressMeter")
  JuliaCall::julia_install_package_if_needed("Suppressor")
}
