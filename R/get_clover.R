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
