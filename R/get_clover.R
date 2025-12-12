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
  curl::curl_download(url = url,destfile = destfile)
  # download.file(url,destfile = destfile)

  if(fs::is_file(destfile)){
    clo <- readr::read_csv(destfile)

    return(destfile)
  }
  
  
  # try zenodo deposit 
  # use 4435127 to get latest version of the data
  destfile <- download_deposit_version("4435127", "data/clover","CLOVER_1\\.0_Viruses_AssociationsFlatFile\\.csv")
  
  if(fs::is_file(destfile)){
    clo <- readr::read_csv(destfile)
    
    return(destfile)
  }

  stop("file not downloaded")
}


#' Download deposit version
#'
#' Downloads and extracts some version of the deposit.
#'
#' @param zenodo_id String. ID for a Zenodo deposit. Should correspond to the version of a deposit.
#' @param dir_path String. Path to directory where the files should be downloaded
#'  e.g. "inst/extdata/wdds_archive" note no trailing slash on the path.
#' @param specific_file string. Regex pattern for a specific file.
#'
#' @returns String. Path to downloaded version or file
#' @export
#' @examplesIf curl::has_internet()
#'
#' # download the deposit
#'
#' \dontrun{
#' download_deposit_version("4435127", "data/clover")
#' }
#'
download_deposit_version <- function(zenodo_id, dir_path, specific_file = NULL) {
  # assertthat::assert_that(is.character(zenodo_id), msg = "zenodo_id must be character")
  # assertthat::assert_that(is.character(version), msg = "version must be character")
  # assertthat::assert_that(assertthat::is.scalar(dir_path), msg = "dir_path must scalar (a length 1 vector)")
  # 
  
  browser()
  ##create folder in archive for version
  fs::dir_create(path = dir_path) # will not overwrite existing folders
  
  
  ## use id to get the thing
  api_url <- sprintf("https://zenodo.org/api/records/%s", zenodo_id)
  
  id_json <- jsonlite::fromJSON(api_url)
  zip_file <- fs::path_file(id_json$files$key)
  
  zip_path <- sprintf("%s/%s", dir_path, zip_file)
  curl::curl_download(url = id_json$files$links$self, destfile = zip_path)
  unzip_result <- utils::unzip(zipfile = zip_path, exdir = dir_path, overwrite = TRUE)
  
  unzip_path <- fs::path_common(unzip_result)
  
  ## clean up the folder
  # remove zip
  fs::file_delete(zip_path)
  
  ## only keep a specific file
  
  if(!is.null(specific_file)){
    
    files_to_delete <- fs::dir_ls(path = unzip_path,
               recurse = TRUE,
               type = "file",
               regexp = specific_file,
               invert = TRUE)
    
    fs::file_delete(files_to_delete)
    
    files_to_keep <- fs::dir_ls(path = unzip_path,
                                  recurse = TRUE,
                                  type = "file",
                                  regexp = specific_file,
                                  invert = FALSE)
    
    return(files_to_keep)
  }
  
  return(unzip_path)
}