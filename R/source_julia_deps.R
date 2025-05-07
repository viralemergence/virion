#' Make sure julia packages are installed
#' 
#' Simple wrapper to system2. Will add better error catching in the future 
#'
#' @param path Character. Path to julia package install script. 
#'
#' @returns
#' @export
#'
#' @examples
source_julia_deps <- function(path = "sys_deps/julia_deps.sh"){
  system2(path)
}