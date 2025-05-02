#' Generate file template 
#' 
#' This file generates a dataframe of zero rows but 32 variables that has the 
#' type coding for each variable that will be used later 

# Generate example file ========================================================
generate_template <- function(){
  temp <- data.frame(Host = character(),
  Virus = character(),
  HostTaxID = double(),
  VirusTaxID = double(),
  HostNCBIResolved = logical(),
  VirusNCBIResolved = logical(),
  HostGenus = character(),
  HostFamily = character(),
  HostOrder = character(),
  HostClass = character(),
  HostOriginal = character(),
  HostSynonyms = character(),
  VirusGenus = character(),
  VirusFamily = character(),
  VirusOrder = character(),
  VirusClass = character(),
  VirusOriginal = character(),
  HostFlagID = logical(),
  DetectionMethod = character(),
  DetectionOriginal = character(),
  Database = character(),
  DatabaseVersion = character(),
  PublicationYear = double(),
  ReferenceText = character(),
  PMID = double(),
  NCBIAccession = character(),
  ReleaseYear = double(),
  ReleaseMonth = double(),
  ReleaseDay = double(),
  CollectionYear = double(),
  CollectionMonth = double(),
  CollectionDay = double(),
  stringsAsFactors = FALSE)
  
  return(temp)

}

