

install.ncbi <- function() {
  library(JuliaCall)
  julia_setup()
  julia_install_package_if_needed("NCBITaxonomy")
  julia_install_package_if_needed("DataFrames")
  julia_install_package_if_needed("CSV")
  julia_install_package_if_needed("ProgressMeter")
}

jncbi <- function(spnames, type = 'host') {
  #   #library(JuliaCall)
  #   #julia_setup(installJulia = TRUE)
  #   julia_install_package_if_needed("NCBItaxonomy")
  #   julia_install_package_if_needed("NCBItaxonomy")
  #   julia_install_package_if_needed("CSV")
  raw <- data.frame(Name = spnames)
  write_csv(raw, '~/Github/virion/Code_Dev/TaxonomyTempIn.csv', eol = "\n")
  
  if(type == 'host') {system("julia C:/Users/cjcar/Documents/Github/virion/Code_Dev/host.jl")}
  if(type == 'virus') {system("julia C:/Users/cjcar/Documents/Github/virion/Code_Dev/virus.jl")}
  
  clean <- read_csv("~/Github/virion/Code_Dev/TaxonomyTempOut.csv")
  file.remove('~/Github/virion/Code_Dev/TaxonomyTempIn.csv')
  file.remove('~/Github/virion/Code_Dev/TaxonomyTempOut.csv')
  
  clean$Name <- stringr::str_to_sentence(clean$Name)
  clean$match <- stringr::str_to_sentence(clean$match)
  return(clean)
}
