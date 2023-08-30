library(tidyverse)

install.ncbi <- function() {
  library(JuliaCall)
  julia_setup()
  julia_install_package_if_needed("NCBITaxonomy")
  julia_install_package_if_needed("DataFrames")
  julia_install_package_if_needed("CSV")
  julia_install_package_if_needed("ProgressMeter")
}