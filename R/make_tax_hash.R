#' Makes hash based keys for use with taxonomy table
#' 
#' Takes Species:Class level information, hashes it, and adds the hash as an
#' id for both Hosts and Viruses
#' 
#' @param df 
#'
#' @return
#' @author collinschwantes
#' @export
make_tax_hash <- function(df) {

  df |>
    dplyr::mutate(HostTaxID = as.character(HostTaxID), #NA's cause a problem with str_c
                  VirusTaxID = as.character(VirusTaxID)) |>
    dplyr::mutate(dplyr::across(where(is.character), ~stringr::str_replace_na(string = .x,replacement = "")))|>
    dplyr::mutate(HostTaxHashID = stringr::str_c(Host,
                                                 HostGenus,
                                                 HostFamily,
                                                 HostOrder,
                                                 HostClass,
                                                 HostTaxID,
                                                 HostNCBIResolved,
                                                 sep = "|") |>
                    purrr::map_chr(rlang::hash)
    ) |>
    dplyr::mutate(VirusTaxHashID = stringr::str_c(Virus,
                                                  VirusGenus,
                                                  VirusFamily,
                                                  VirusOrder,
                                                  VirusClass,
                                                  VirusTaxID,
                                                  VirusNCBIResolved,
                                                  ICTVRatified,
                                                  sep = "|") |>
                    purrr::map_chr(rlang::hash))

}


make_tax_table <- function(df){
  host_tax <- df |>
    dplyr::select("TaxHashID" = HostTaxHashID,
                  "ScientificName" = Host,
                  "Genus" = HostGenus,
                  "Family" = HostFamily,
                  "Order" = HostOrder,
                  "Class" = HostClass,
                  "NCBITaxID" = HostTaxID,
                  "NCBIResolved" = HostNCBIResolved) |>
    dplyr::distinct(TaxHashID,.keep_all = TRUE)
  
  virus_tax <- df |>
    dplyr::select("TaxHashID" = VirusTaxHashID,
                  "ScientificName" = Virus,
                  "Genus" = VirusGenus,
                  "Family" = VirusFamily,
                  "Order" = VirusOrder,
                  "Class" = VirusClass,
                  "NCBITaxID" = VirusTaxID,
                  "NCBIResolved" = VirusNCBIResolved,
                  ICTVRatified
                  ) |>
    dplyr::distinct(TaxHashID,.keep_all = TRUE)
  
  out <- dplyr::bind_rows(host_tax,virus_tax) |>
    dplyr::distinct()
  
  return(out)
  
}

drop_tax_columns <- function(df){
  df |>
    select(-Host,
           -HostGenus,
           -HostFamily,
           -HostOrder,
           -HostClass,
           -HostTaxID,
           -HostNCBIResolved,
           -Virus,
           -VirusGenus,
           -VirusFamily,
           -VirusOrder,
           -VirusClass,
           -VirusTaxID,
           -VirusNCBIResolved,
           -ICTVRatified
           )
}