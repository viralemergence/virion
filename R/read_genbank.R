#' Read in Genbank Data
#'
#' @param genbank_path Character. Path to genbank file
#'
#' @returns
#' @export
#'
#' @examples
read_genbank <- function(genbank_path){
  seq <- data.table::fread(here::here("./Source/AllNuclMetadata.csv.gz"),
                         select = c("#Accession", "Release_Date", "Species", 
                                    "Host", "Collection_Date"))
print("readin genbank")
seq %<>% dplyr::rename(Accession = "#Accession")  

  return(seq)
}