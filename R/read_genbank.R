#' Read in Genbank Data
#'
#' @param genbank_path Character. Path to genbank file
#'
#' @returns
#' @export
#'
#' @examples
read_genbank <- function(genbank_path){
  seq <- data.table::fread(genbank_path,
                         select = c("#Accession", "Release_Date", "Species", 
                                    "Host", "Collection_Date"))
print("read in genbank")
    fs::file_delete(path = genbank_path) 
seq %<>% dplyr::rename(Accession = "#Accession")  

print("converting to tibble, this takes a minute")
out <- tibble::as_tibble(seq)

  return(out)
}