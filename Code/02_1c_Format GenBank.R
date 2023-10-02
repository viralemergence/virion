# set up 
library(tidyverse); library(magrittr); library(vroom); library(data.table)
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}
print("vdict")
if(!exists('jvdict')) {source('Code/001_Julia functions.R')}
print("jvdict")

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

# Attaching GenBank
gb <- vroom::vroom("Intermediate/Unformatted/GenBankUnformatted.csv.gz") 
print("read in")
gb %<>% 
  dplyr::rename(NCBIAccession = 'Accession') %>% 
  dplyr::rename(Release_Date = Release_Date) %>% # not sure what this is doing?

  # really don't know why we want or need this here?????
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
            DatabaseVersion = "Aug2021FlatFile",
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


print("mutate at")
# write intermediate file
vroom::vroom_write(gb, "Intermediate/Formatted/GenbankFormatted.csv.gz")
print("written")

## little benchmarking 
# microbenchmark::microbenchmark(
#   data.table = {
#     gb %>% 
#       data.table::tstrsplit(Collection_Date, "-", 
#                             names=paste0("Collection", 
#                                          c("Year", "Month", "Day"))) %>% 
#       data.table::tstrsplit(gRelease_Date, "-", 
#                             names=paste0("Release", 
#                                          c("Year", "Month", "Day")))
#   },
#   tidyr = {
#     gb %>% 
#       # known that the collection date is a string and many observations don't
#       # have year or month values, just the year, so many of these will turn up 
#       # as missing
#       tidyr::separate(Collection_Date, sep = "-", 
#                       into = paste0("Collection", c("Year", "Month", "Day"))) %>% 
#       tidyr::separate(Release_Date, sep = "-", 
#                       into = paste0("Release", c("Year", "Month", "Day"))) 
#   },
#   times = 100
# )
