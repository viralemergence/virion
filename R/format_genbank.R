#' Format genbank data for integration with Virion
#'
#' @param gb  Data frame. Genbank data from gb_clean_viruses
#' @param temp Data frame. Template for Virion data
#' @param database_version Character. database version for genbank
#'
#' @returns data frame. Genbank data formatted for virion
#' @export
#'
#' @examples
format_genbank <- function(gb,temp, database_version){

gb %<>% 
  dplyr::rename(NCBIAccession = 'Accession') %>% 
  dplyr::rename(Release_Date = Release_Date) %>% # not sure what this is doing?
  dplyr::mutate_at("Release_Date", ~.x %>% # Modifying date column to make sense
                     stringr::str_split("T") %>% # Splitting at this midpoint
                     purrr::map_chr(1) %>% # Taking the first component 
                     lubridate::ymd() # Coding as YMD (shouldn't throw errors)
  ) 
print("renamed")

gb[, c(paste0("Collection", c("Year", "Month", "Day")))] <- 
  data.table::tstrsplit(gb$Collection_Date, "-", 
                        names=paste0("Collection", 
                                     c("Year", "Month", "Day"))) 
gb[, c(paste0("Release", c("Year", "Month", "Day")))] <- 
  data.table::tstrsplit(gb$Release_Date, "-", 
                        names=paste0("Release", 
                                     c("Year", "Month", "Day"))) 

# gb %<>% 
#   # known that the collection date is a string and many observations don't
#   # have year or month values, just the year, so many of these will turn up 
#   # as missing
#   tidyr::separate(Collection_Date, sep = "-", 
#                   into = paste0("Collection", c("Year", "Month", "Day"))) %>% 
#   tidyr::separate(Release_Date, sep = "-", 
#                   into = paste0("Release", c("Year", "Month", "Day"))) 
print("separated")


gb %<>% 
  dplyr::mutate_at(dplyr::vars(tidyselect::matches("Year|Month|Day")), 
                   as.numeric) %>% 
  dplyr::mutate(HostFlagID = stringr::str_detect(HostOriginal, "cf."),
                Database = "GenBank",
                DatabaseVersion = database_version,
                # Choice to call Nucleotide all sequence and not isolation is 
                # potentially problematic - revisit 
                DetectionMethod = "PCR/Sequencing", 
                # Just to keep separate from EID2 Nucleotide entries # Fix 
                # the HostSynonyms at the 01 import stage
                DetectionOriginal = "GenBank") 
print("mutated")
gb %<>% 
  dplyr::mutate(VirusTaxID = as.numeric(VirusTaxID)) %>% 
  # stiching together the temp and the genbank data that's now been formatted
  dplyr::bind_rows(temp, .) %>%  
  dplyr::mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", 
                     "HostClass", "Virus", "VirusGenus", "VirusFamily", 
                     "VirusOrder", "VirusClass"),
                   tolower)
  
# garbage collection to remove extras stuff from memory
gc()
  
return(gb)

}