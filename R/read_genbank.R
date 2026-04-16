#' Read in Genbank Data
#'
#' @param genbank_path Character. Path to genbank file
#'
#' @returns
#' @export
#'
#' @examples
read_genbank <- function(genbank_path){
  
  # vroom is slower but this is a possible refactor to 
  # drop an additional package dependency
  # gb_raw <- vroom::vroom(file = genbank_path,
  #                        delim = ",",
  #                        col_select = c("#Accession",
  #                                      "Release_Date",
  #                                      "Species",
  #                                      "Host",
  #                                      "Collection_Date"),
  #                        altrep = TRUE
  #                        )
  # 
  gb_raw <- data.table::fread(genbank_path,
                         select = c("#Accession", "Release_Date", "Species",
                                    "Host", "Collection_Date"))
print("read in genbank")
gb_raw %<>% dplyr::rename(Accession = "#Accession")  

  return(gb_raw)
}