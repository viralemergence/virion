# echo $PATH
# use str_split to compare the ":" separated items in PATH
# 
# r_path <- Sys.getenv("PATH")
# hb_path <- "/opt/homebrew/bin:/opt/homebrew/sbin"
# new_path <- paste0(hb_path,r_path,collapes = ":")
# Sys.setenv(PATH=new_path)


update_path <- function(items_to_add = "/opt/hostedtoolcache/juliaup/1.17.4/x64:"){
  r_path <- Sys.getenv("PATH")
  new_path <- paste0(items_to_add,r_path,collapes = ":")
  print(new_path)
  Sys.setenv(PATH=new_path)
}