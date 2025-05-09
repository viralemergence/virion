#' Get Clover data
#'
#' Download clover data
#'
#' @param url Character. url for download
#' @param destfile Character. destination for file
#'
#' @returns
#' @export
#'
#' @examples
get_clover <- function(
 url = "https://github.com/viralemergence/clover/blob/main/clover/clover_1.0_allpathogens/CLOVER_1.0_Viruses_AssociationsFlatFile.csv?raw=true",
 destfile = "Intermediate/Raw/CLOVER_1.0_Viruses_AssociationsFlatFile.csv")
{
  download.file(url,destfile = destfile)

  if(fs::is_file(destfile)){
    clo <- readr::read_csv(destfile)

    return(destfile)
  }

  stop("file not downloaded")
}
