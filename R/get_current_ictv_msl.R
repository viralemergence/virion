#' Download the latest MSL version
#'
#' @param url_msl Character. URL provided by ICTV
#'
#' @return Character. String to ICTV path
#' @author collinschwantes
#' @export
download_current_msl <- function(url_msl = "https://ictv.global/msl/current") {

  # get current 
  
  head_msl <- httr::HEAD(url_msl)
  file_location <- head_msl$all_headers[[1]]$headers$location
  file_name <- fs::path_file(file_location)
  
  msg <- sprintf("Current version of ICTV MSL: %s", file_name)
  message(msg)
  
  dest_file <- sprintf("Source/%s",file_name)
  
  download.file(url = url_msl,destfile = dest_file)
  
  # check that the file downloaded
  
  if(!fs::file_exists(dest_file)){
    stop("ICTV MSL did not download. Check the url_msl.")
  }
  
  return(dest_file)
}


read_current_msl <- function(current_msl_path,  supported_file_ext = "xlsx"){
  
  # check file extension
  msl_ext <- fs::path_ext(path = current_msl_path)
  
  if(!msl_ext %in% supported_file_ext){
    msg <- sprintf("Did ICTV change the file format for the master species list?

%s file extension NOT included in read_current_msl.
Please update the function.", msl_ext)
    
    stop(msg)  
  }

  # parse various file extensions
  if( msl_ext == "xlsx"){
    msl <- readxl::read_excel(current_msl_path,sheet = "MSL",col_types = "text")
    
    # only column that needs to be numeric
    msl$Sort <- as.numeric(msl$Sort)
    
  }
  
  # check for critical columns
  if(!"Species" %in% names(msl)){
    stop("Species column not found in MSL. Species necessary for downstream processing")
  }
  
  return(msl)
    
}


