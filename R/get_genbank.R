#' Get Genbank data
#'
#' @param url Character.Url for download
#' @param location  Character destination for file
#'
#' @returns
#' @export
#'
#' @examples
get_genbank <- function(gb_url = "https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/AllNuclMetadata.csv.gz", location = here::here("Source/AllNuclMetadata.csv.gz")){
  
  message("this takes a minute or two")
  # download with wget
  system(paste0("wget ", gb_url, " -qO ", location))

  if(fs::file_exists(location)){
    return(location)
  }

  stop("Genbank file didn't download :(")

}