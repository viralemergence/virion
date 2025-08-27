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

  name_to_update <- which(names(gb) == 'Accession')
  names(gb)[name_to_update] <- "NCBIAccession"
  
  gb$Release_Date <- lubridate::ymd(gb$Release_Date)
  gb$VirusTaxID <- as.numeric(gb$VirusTaxID)

  
# gb <- gb %>%
#   dplyr::rename(NCBIAccession = 'Accession')%>%
#   # dplyr::rename(Release_Date = Release_Date) %>% # not sure what this is doing?
#   dplyr::mutate(Release_Date = lubridate::ymd(Release_Date))
# # mutate_at is very expensive and doesnt seem to be doing anything.
#   #   dplyr::mutate_at("Release_Date", ~.x %>% # Modifying date column to make sense
#   #                    stringr::str_split("T") %>% # Splitting at this midpoint
#   #                    purrr::map_chr(1) %>% # Taking the first component
#   #                    lubridate::ymd() # Coding as YMD (shouldn't throw errors)
#   # )



print("renamed")

collection_cols <- c(paste0("Collection", c("Year", "Month", "Day")))

gb[, collection_cols] <- 
  data.table::tstrsplit(gb$Collection_Date, "-", 
                        names=paste0("Collection", 
                                     c("Year", "Month", "Day"))) 

release_cols <-  c(paste0("Release", c("Year", "Month", "Day")))

gb[, release_cols] <- 
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
  dplyr::mutate(dplyr::across(tidyselect::all_of(c(collection_cols,release_cols)), 
                   as.numeric)) 

gb$HostFlagID <- stringr::str_detect(gb$HostOriginal, "cf.")
gb$Database <- "GenBank"
gb$DatabaseVersion <- database_version
# Choice to call Nucleotide all sequence and not isolation is 
# potentially problematic - revisit 
gb$DetectionMethod <- "PCR/Sequencing"
# Just to keep separate from EID2 Nucleotide entries # Fix 
# the HostSynonyms at the 01 import stage
gb$DetectionOriginal = "GenBank"

print("mutated")
gb %<>% 
  # stiching together the temp and the genbank data that's now been formatted
  dplyr::bind_rows(temp, .) %>%  
  dplyr::mutate(dplyr::across(
    tidyselect::all_of(c("Host", "HostGenus", "HostFamily", "HostOrder", 
                     "HostClass", "Virus", "VirusGenus", "VirusFamily", 
                     "VirusOrder", "VirusClass")),
                   tolower)
    )
  
# garbage collection to remove extras stuff from memory
gc()

return(gb)

}
