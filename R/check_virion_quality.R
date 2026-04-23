#' Quality control checks for virion
#'
#' Looks at certain descriptive statistics 
#'
#' @param virion_unique_path data.table Virion unique data
#' @param virion_ncbi_accession_numbers data.table NCBI Accession Numbers
#'
#' @return
#' @author collinschwantes
#' @export
check_virion_quality <- function(virion_unique_path,
                                 virion_ncbi_accession_numbers,
                                 virion_tax_table,
                                 virion_db_info) {
  
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
    pull(HostTaxHashID) |>
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
    pull(VirusTaxHashID) |>
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
    dplyr::inner_join(virion_tax_table, by = c("HostTaxHashID" = "TaxHashID")) |>
    dplyr::filter(stringr::str_detect(string = ScientificName,pattern = "[A-Z]")) |>
    nrow()
  
  if(uppercase_hosts != 0){
    rlang::abort(message = "Host case: there are upper case hosts for some reason.")
  } 
  
  
  ### check that all viruses are lower case ####
  uppercase_viruses <- virion_unique_path |>
    dplyr::inner_join(virion_tax_table, by = c("VirusTaxHashID" = "TaxHashID")) |>
    dplyr::filter(stringr::str_detect(string = ScientificName,pattern = "[A-Z]")) |>
    nrow()
  
  if(uppercase_viruses != 0){
    rlang::abort(message = "Virus case: there are upper case viruses for some reason.")
  } 
  
  # check that data has NCBI tax
  
  ncbi_hosts <- virion_unique_path |>
    dplyr::left_join(virion_tax_table, by = c("HostTaxHashID" = "TaxHashID"), 
                     relationship = "many-to-one") |>
    filter(as.logical(NCBIResolved)) |>
    nrow()
  
  host_ncbi_coverage <- coverage_x(ncbi_hosts,virion_size)
  
  msg_host_coverage <- glue::glue("{host_ncbi_coverage}% of hosts are resolved in NCBI taxonomy")
  
  rlang::inform(msg_host_coverage)
  
  ### check virus coverage
  
  virion_unique_virus_tax <- virion_unique_path %>% 
    dplyr::left_join(virion_tax_table, 
                     by = c("VirusTaxHashID" = "TaxHashID"),
                     relationship = "many-to-one")
  
  ncbi_virus <-  virion_unique_virus_tax |>
    filter(as.logical(NCBIResolved)) |>
    nrow()
  
  virus_ncbi_coverage <- coverage_x(ncbi_virus,virion_size)

  msg_virus_coverage <- glue::glue("{virus_ncbi_coverage}% of viruses are resolved in NCBI taxonomy")
  
  rlang::inform(msg_virus_coverage)
  # check that data has ICTV tax
  
  ictv_rat_virus <- virion_unique_virus_tax %>% 
    filter(as.logical(ICTVRatified)) |>
    nrow()
  
  ictv_ratified_coverage <-  coverage_x(ictv_rat_virus,virion_size)
  
  msg_ictv_coverage <- glue::glue("{ictv_ratified_coverage}% of viruses are ICTV ratified")
  
  rlang::inform(msg_ictv_coverage)


 ### look at NCBI accession numbers
  ncbi_acc_total <- virion_ncbi_accession_numbers |>
                      dplyr::pull(NCBIAccession) |>
                      stringr::str_split(pattern = ",") |>
                      unlist() |>
                      unique() |>
                      length()
  
                      
 
  msg_ncbi_acc_total <- glue::glue("{ncbi_acc_total} unique accession numbers from NCBI")
  
  rlang::inform(msg_ncbi_acc_total)
  
  ### check data sources
  
  database_check <- all(sort(unique(virion_db_info$Database)) ==  sort(c("GenBank","PREDICT","EID2","Shaw","HP3","GMPD2")))
  
  if(!database_check){
    rlang::abort(message = "A database is missing from virion or has been added. 
                 Should contain GenBank, PREDICT, EID2, SHAW, HP3,GMPD2")
  }
  
  if(nrow(virion_db_info) <7){
    rlang::abort(message = "virion_db_info appears to have lost a source. 
                 Should contain at least 7 sources.")
  } 
     
 ### check for 1:many relationships between hosts and taxa ids
  
 ### check for 1:many relationships between viruses and taxa ids
  

  # c(msg_size_total,
  #       msg_size_host,
  #       msg_host_coverage,
  #       msg_size_virus,
  #       msg_virus_coverage,
  #       msg_ictv_coverage)
  
  return(TRUE)
  
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
