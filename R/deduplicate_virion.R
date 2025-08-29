#' Deduplicate and clean Virion data
#'
#' Removes duplicate entries, mutates all fields to character, and does
#' some cleaning and summarizing.
#'
#' Writes virion output
#'
#' @param virion_clover_hosts Data frame. DF from clean_clover_hosts
#'
#' @returns data frame
#' @export
#'
#' @examples
deduplicate_virion <- function(virion_clover_hosts, path = "outputs/virion.csv.gz"){
  
  print("deduplicate_virion: starting")
  v_ <- virion_clover_hosts |> 
    dplyr::distinct()
  print("deduplicate_virion: distinct")
  v_ <- v_ |> 
    dplyr::mutate_all(as.character) 
  print("deduplicate_virion: character")
  
  gc()
  
  v_ <- v_ |>   
    dplyr::mutate_all(~tidyr::replace_na(.x, ''))
  print("deduplicate_virion: blank")
  
  v_ <- v_ |> 
  dplyr::group_by_at(dplyr::vars(-NCBIAccession)) |> 
    dplyr::summarize(NCBIAccession = stringr::str_c(NCBIAccession, collapse = ", ")) |> 
    dplyr::ungroup()
  print("deduplicate_virion: deduplicated")
  
  out_path <- vroom::vroom_write(v_, path,delim = ",")
  print("deduplicate_virion: file written")
    
  return(out_path)
}