#' Quality control checks for virion
#'
#' Looks at certain descriptive statistics 
#'
#' @param virion_unique_path data.table Virion unique data
#'
#' @return
#' @author collinschwantes
#' @export
check_virion_quality <- function(virion_unique_path) {
  
  # check that data has grown?
  # 484464 from preprint
  virion_size <- nrow(virion_unique_path) 
  if(virion_size <= 484464){
    rlang::abort(message = "Total records: Virion has fewer records than reported in the pre-print")
  } else {
    msg_size_total <- glue::glue("Virion contains {virion_size} observations")
    
    rlang::inform(msg_size_total)
  }
  
  # check that data has hosts
  
  has_hosts <- virion_unique_path %>% 
    pull(Host) |>
    unique() |>
    length()
  
  if(has_hosts < 3692){
    rlang::abort(message = "Unique Hosts: Virion has fewer unique hosts than reported in the pre-print")
  } else {
    msg_size_host <- glue::glue("Virion contains {has_hosts} unique hosts")
    
    rlang::inform(msg_size_host)
  }
  
  # check that data has viruses
  has_viruses <- virion_unique_path %>% 
    pull(Virus) |>
    unique() |>
    length()
  
  if(has_viruses < 7000){
    rlang::abort(message = "Unique Viruses: Virion has fewer unique viruses than reported in the pre-print")
  } else {
    msg_size_virus <- glue::glue("Virion contains {has_viruses} unique viruses")
    
    rlang::inform(msg_size_virus)
  }
  
  ## check that all hosts are lower case #####
  
  uppercase_hosts <- virion_unique_path |>
    dplyr::filter(stringr::str_detect(string = Host,pattern = "[A-Z]")) |>
    nrow()
  
  if(uppercase_hosts != 0){
    rlang::abort(message = "Host case: there are upper case hosts for some reason.")
  } 
  
  
  ### check that all viruses are lower case ####
  uppercase_viruses <- virion_unique_path |>
    dplyr::filter(stringr::str_detect(string = Virus,pattern = "[A-Z]")) |>
    nrow()
  
  if(uppercase_hosts != 0){
    rlang::abort(message = "Virus case: there are upper case viruses for some reason.")
  } 
  
  # check that data has NCBI tax
  
  ncbi_hosts <- virion_unique_path %>% 
    filter(as.logical(HostNCBIResolved)) |>
    nrow()
  
  host_ncbi_coverage <- coverage_x(ncbi_hosts,virion_size)
  
  msg_host_coverage <- glue::glue("{host_ncbi_coverage}% of hosts are resolved in NCBI taxonomy")
  
  rlang::inform(msg_host_coverage)
  
  ncbi_virus <- virion_unique_path %>% 
    filter(as.logical(VirusNCBIResolved)) |>
    nrow()
  
  virus_ncbi_coverage <- coverage_x(ncbi_virus,virion_size)

  msg_virus_coverage <- glue::glue("{virus_ncbi_coverage}% of viruses are resolved in NCBI taxonomy")
  
  rlang::inform(msg_virus_coverage)
  # check that data has ICTV tax
  
  ictv_rat_virus <- virion_unique_path %>% 
    filter(as.logical(ICTVRatified)) |>
    nrow()
  
  ictv_ratified_coverage <-  coverage_x(ictv_rat_virus,virion_size)
  
  msg_ictv_coverage <- glue::glue("{ictv_ratified_coverage}% of viruses are ICTV ratified")
  
  rlang::inform(msg_ictv_coverage)

  
 ### check for 1:many relationships between hosts and taxa ids
  
 ### check for 1:many relationships between viruses and taxa ids
  

}

#' Check coverage for a given metric
#'
#' @param x Numeric. Number of entries that meet criteria
#' @param virion_size Numeric. Number of entries in virion
#'
#' @returns Numeric. Rounded percent coverage
#' @export
#'
#' @examples
#' 
#' coverage_x(10,100)
#' 
coverage_x <- function(x, virion_size){
  round((x/virion_size)*100,2)
}
