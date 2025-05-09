#' Format clover data
#'
#' Uses data template to format clover data
#'
#' @param clo Data frame. Data frame of raw clover data
#' @param clover_template  Data frame. Template for virion data
#'
#' @returns Data frame. Formatted clover data
#' @export
#'
#' @examples
format_clover <- function(clo,clover_template){

# This step should go away after Rory updates CLOVERT with the "sp." thing
if(!("HostGenus" %in% colnames(clo))) { 
  clo %<>% dplyr::mutate(HostGenus = stringr::word(Host, 1)) }

# This step should go away after Rory updates to remove CitationID
if("CitationID" %in% colnames(clo)) { 
    clo %>% 
    dplyr::rowwise() %>%
    dplyr::mutate(NCBIAccession = 
             ifelse(CitationIDType=='NCBI Nucleotide', CitationID, NA),
           PMID = ifelse(CitationIDType=='PMID', CitationID, NA)) %>%
    dplyr::select(-c(CitationID, CitationIDType)) -> clo
}

# names need to be consistent
clo %<>% dplyr::rename(Virus = "Pathogen",
                       VirusGenus = "PathogenGenus",
                       VirusFamily = "PathogenFamily",
                       VirusOrder = "PathogenOrder",
                       VirusClass = "PathogenClass",
                       DetectionOriginal = "DetectionMethodOriginal",
                       VirusNCBIResolved = "PathogenNCBIResolved",
                       VirusOriginal = "PathogenOriginal",
                       VirusTaxID = "PathogenTaxID")

clo %<>% dplyr::select(-c(PathogenType, 
                          Detection_NotSpecified,
                          Detection_Serology,
                          Detection_Genetic,
                          Detection_Isolation))

clo %<>% dplyr::mutate(NCBIAccession = as.character(NCBIAccession))
clo %<>% dplyr::select(-ICTVRatified)
clo <- dplyr::bind_rows(clover_template, clo)

# Consistency steps: all lowercase names
clo %<>% dplyr::mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", 
                     "HostClass","Virus", "VirusGenus", "VirusFamily", 
                     "VirusOrder", "VirusClass"),
                   tolower)

  return(clo)

}