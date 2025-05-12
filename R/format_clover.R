#' Format clover data
#'
#' Uses data template to format clover data
#'
#' @param clo Data frame. Data frame of raw clover data
#' @param clover_template  Data frame. Template for virion data
#'
#' @returns Data frame. Formatted clover data
#' @export
#'
#' @examples
format_clover <- function(clo,clover_template){

# This step should go away after Rory updates CLOVERT with the "sp." thing
  if(!("HostGenus" %in% colnames(clo))) { 
    
    genus_length <- stringr::str_split(clo_virus_clean$HostGenus, " ") |> purrr::map_dbl(length)
    if(any(genus_length == 2)){
      
      index_nums <- which(genus_length == 2)
      index_num_char <- paste(index_nums,collapse = ", ")
      
      hosts_with_2_words <- clo$HostGenus[index_nums] |>
        paste(collapse = "\n")
      msg <- sprintf("HostGenus for item(s) %s contain multiple words:
%s",index_num_char,hosts_with_2_words )
      warning(msg)
      clo %<>% dplyr::mutate(HostGenus = stringr::word(Host, 1)) 
    }
  }



# names need to be consistent
clo %<>% dplyr::rename(
                       DetectionOriginal = "DetectionMethodOriginal")

clo %<>% dplyr::select(-c(Detection_NotSpecified,
                          Detection_Serology,
                          Detection_Genetic,
                          Detection_Isolation))

clo %<>% dplyr::mutate(NCBIAccession = as.character(NCBIAccession))
clo %<>% dplyr::select(-ICTVRatified)
clo <- dplyr::bind_rows(clover_template, clo)

# Consistency steps: all lowercase names
clo %<>% dplyr::mutate_at(c("Host", "HostGenus", "HostFamily", "HostOrder", 
                     "HostClass","Virus", "VirusGenus", "VirusFamily", 
                     "VirusOrder", "VirusClass"),
                   tolower)

  return(clo)

}