# echo $PATH
# use str_split to compare the ":" separated items in PATH
# 
# r_path <- Sys.getenv("PATH")
# hb_path <- "/opt/homebrew/bin:/opt/homebrew/sbin"
# new_path <- paste0(hb_path,r_path,collapes = ":")
# Sys.setenv(PATH=new_path)


#' Update R PATH env variable
#'
#' R needs to know where julia can be found. This function adds the julia path
#' to R if its not there. 
#' In terminal run `echo $PATH` then use use str_split to compare the ":" 
#' separated items in PATH to the items in your R path
#'
#' r_path <- Sys.getenv("PATH")
#' hb_path <- "/opt/homebrew/bin:/opt/homebrew/sbin"
#' new_path <- paste0(hb_path,r_path,collapes = ":")
#' Sys.setenv(PATH=new_path)
#'
#' @param items_to_add Character. Vector of strings or single string of colon separated items. 
#'
#' @returns Character. updated PATH
#' @export
#'
#' @examples
#' 
#' # original path
#' "/usr/local/bin"
#' 
#' update_path(items_to_add = c("hello","world))
#' 
#' # returns new PATH with items added
#' "hello:world:/usr/local/bin"
#' 
#' # if we try to add an item already in the path, we get a message
#' update_path(items_to_add = c("hello"))
#' 
#' # gives an informative message and returns the PATH
#' message: "All items are already in the path"
#' 
#' 
#' 
update_path <- function(items_to_add){
  r_path <- Sys.getenv("PATH")
  
  r_path_objs <- stringr::str_split(r_path,pattern = ":") |> unlist()
  
  already_there <- items_to_add %in% r_path_objs
  
  if(all(already_there)){
  
    message("All items are already in the path")
    return(r_path)
  }
  
  # drop items already in the path
  if(any(!already_there)){
    items_in_path <- items_to_add[already_there]
    items_to_add <- items_to_add[!already_there]
    
    msg_in_path <- sprintf("%s is already in the path\n",items_in_path)
    msg_to_add <- sprintf("%s will be added to the path\n",items_to_add)
    
    message(msg_in_path)
    message(msg_to_add)
  }
  
  
  new_path <- paste0(c(items_to_add,r_path),collapse = ":")

  Sys.setenv(PATH=new_path)
  return(new_path)
}