#' Get Genbank data
#'
#' @param url Character.Url for download
#' @param location  Character destination for file
#'
#' @returns
#' @export
#'
#' @examples
get_genbank <- function(url = "https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/AllNuclMetadata.csv.gz", location = here::here("./Source/")){
  
  message("this takes a minute or two")
  # download with wget
  system(paste0("wget ", url, " -qP ", location))

  if(fs::file_exists("./Source/AllNuclMetadata.csv.gz")){
    return("./Source/AllNuclMetadata.csv.gz")
  }

  stop("Genbank file didn't download :(")

}