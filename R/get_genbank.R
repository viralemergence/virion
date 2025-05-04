get_genbank <- function(url = "https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/AllNuclMetadata.csv.gz", location = here::here("./Source/")){
  

  # download with wget
  system(paste0("wget ", url, " -P ", location))

  if(fs::file_exists("./Source/AllNuclMetadata.csv.gz")){
    return("./Source/AllNuclMetadata.csv.gz")
  }

  stop("Genbank file didn't download :(")

}