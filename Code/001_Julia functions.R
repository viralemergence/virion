#' Install Julia packages to use the functions for NCBI ========================
#' 
#' Here we use the JuliaCall library to get the funcitons we need 

# create install.ncbi() function ===============================================

install.ncbi <- function() {
  
  # call this here in case it gets used elsewhere, but this shouldn't be needed
  library(JuliaCall)
  
  # install the packages if needed 
  JuliaCall::julia_install_package_if_needed("NCBITaxonomy")
  JuliaCall::julia_install_package_if_needed("DataFrames")
  JuliaCall::julia_install_package_if_needed("CSV")
  JuliaCall::julia_install_package_if_needed("ProgressMeter")
}