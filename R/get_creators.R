#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @param gh_url Character. URL to github api for contributors
#'
#' @title
#' @return
#' @author collinschwantes
#' @export
get_creators <- function(gh_url =
                         "https://api.github.com/repos/viralemergence/virion/contributors") {

  contribs <- httr::GET(url = gh_url)
  
  contribs_list <- httr::content(contribs)
  
  print(contribs_list)
  
  creators <- purrr::map(contribs_list,function(x){
    creator_list <- list(name = character(),
                         orcid = character())
    
    individ <- httr::GET(x$url)
    individ_list <- httr::content(individ)
    
    creator_list$name <- individ_list$name
    
    individ_html<- httr::GET(individ_list$html_url)
    individ_html_text <- httr::content(individ_html,as = "text")
    
    #orcid
    orcid <- stringr::str_extract(individ_html_text,pattern = "https://orcid.org/(\\d{4}-){3}\\d{3}(\\d|X)")
    creator_list$orcid <- orcid
    
    if(is.na(orcid)){
      creator_list <- list(name = creator_list$name)
    }
    
    return(creator_list)
  })
  
  return(creators)
}
