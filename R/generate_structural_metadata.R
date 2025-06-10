#' Generate data template 
#'
#' This function generates a dataframe of zero rows with 32 typed variables. This
#' is essentially the structure for the Virion data. 
#'
#' @returns data frame
#' @export
#'
#' @examples
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

#' Field definitions for the VIRION template
#'
#' @returns List of definitions
#' @export
#'
#' @examples
virion_definitions <- function(){
  list(Host = "Host species name",
             Virus = "Virus species name",
             HostTaxID = "Taxonomic identification number from NCBI for host taxa.",
             VirusTaxID = "Taxonomic identification number from NCBI for virus taxa.",
             HostNCBIResolved = "Indicates where or not the host taxa could harmonized with the NCBI taxonomy.",
             VirusNCBIResolved = "Indicates where or not the virus taxa could harmonized with the NCBI taxonomy.",
             HostGenus = "Host genus name",
             HostFamily = "Host family name",
             HostOrder = "Host order name",
             HostClass = "Host class name",
             HostOriginal = "Host name from original dataset",
             HostSynonyms = "Synonyms for the host taxa",
             VirusGenus = "Virus genus name",
             VirusFamily = "Virus family name",
             VirusOrder = "Virus order name",
             VirusClass = "Virus class name",
             VirusOriginal = "Virus name from original dataset",
             HostFlagID = "Denotes the presence of possible uncertainty in host identification, which users may want to check before proceeding any further.",
             DetectionMethod = "Four harmonized categories in descending order of strength of evidence: “Isolation/Observation,” “PCR/Sequencing,” “Antibodies,” and “Not specified”. In some cases where detection method is not available via metadata, source information is used as DetectionOriginal (e.g., “NCBI Nucleotide”).",
             DetectionOriginal = "Method used for determing the presence of a virus as described in the original work",
             Database = "Source for the record. One of EID2, Shaw, HP3, GMPD2, PREDICT, OR GenBank",
             DatabaseVersion = "For static data, a citation. For dynamic data (e.g. Genbank) the access URL and a time stamp",
             PublicationYear = "For literature derived records. PublicationYear provides the year the literature source was published, accessed either from the original database’s reference description or from scraping the PubMed database.",
             ReferenceText = "A text description of literature sources",
             PMID = "PubMed identifiers for literature sources",
             NCBIAccession = "A unique identifier assigned to a record in sequence databases such as GenBank",
             ReleaseYear = " The year a given association was “released” in public information (EID2 and PREDICT) or a publicly deposited sample on GenBank. For PREDICT, all values are given as 2021, given the release of a static file at that time even though some findings may have been published or deposited in GenBank earlier. (This redundancy should be captured in overlap with GenBank and EID2.)",
             ReleaseMonth = "The month a given association was “released” to the public",
             ReleaseDay = "The day a given association was “released” to the public",
             CollectionYear = "Reports the year of actual sample collection (GenBank and Predict)",
             CollectionMonth = "Reports the month of actual sample collection (GenBank and Predict)",
             CollectionDay = "Reports the day of actual sample collection (GenBank and Predict)")
}


host_taxa_definitions <- function(fields =   c("HostTaxID",
                                               "Host",
                                               "HostGenus",
                                               "HostFamily",
                                               "HostOrder",
                                               "HostClass",
                                               "HostNCBIResolved")){
  v_defs <- virion_definitions()
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
}

virus_taxa_definitions <- function(fields = c("VirusTaxID",
                                              "Virus",
                                              "VirusGenus",
                                              "VirusFamily",
                                              "VirusOrder",
                                              "VirusClass",
                                              "VirusNCBIResolved",
                                              "ICTVRatified",
                                              "Database")){
  
  
  v_defs <- virion_definitions()
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
  
}


provenance_definitions <- function(fields = c("AssocID",
                                              "HostOriginal",
                                              "VirusOriginal",
                                              "Database",
                                              "DatabaseVersion",
                                              "ReferenceText", 
                                              "PMID")){
  
  v_defs <- virion_definitions()
  
  v_defs$AssocID <- "Row number from current VIRION version"
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
  
}


detection_definitions <- function(fields = c(
  "AssocID",
                      "DetectionMethod",
                      "DetectionOriginal", 
                      "HostFlagID",
                      "NCBIAccession"
)){
  v_defs <- virion_definitions()
  
  v_defs$AssocID <- "Row number from current VIRION version"
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
}

edgelist_definitions <- function(fields = c(
  "HostTaxID", "VirusTaxID", "AssocID"
)){
  v_defs <- virion_definitions()
  
  v_defs$AssocID <- "Row number from current VIRION version"
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
}

temporal_definitions <- function(fields = c("AssocID", 
                                            "PublicationYear", 
                                            "ReleaseYear", 
                                            "ReleaseMonth", 
                                            "ReleaseDay",
                                            "CollectionYear", 
                                            "CollectionMonth", 
                                            "CollectionDay")){
  v_defs <- virion_definitions()
  
  v_defs$AssocID <- "Row number from current VIRION version"
  
  h_defs <- v_defs[fields]
  
  return(h_defs)
}



