#' Shrinks then writes the data
#' 
#' Removes NCBIAccession numbers as a field then keeps distinct values.
#' Writes this much smaller dataset with vroom.
#' 
#' 
#' @param virion_unique Dataframe. Cleaned and unique records from make_virion_unique
#' @param file String. Location for vroom to write to. 
#' @return Dataframe. Data written via vroom.
#' @author collinschwantes

write_virion_unique <- function(virion_unique, file =
                                "outputs/virion.csv.gz") {
  
  system("sh ./sys_deps/sys_specs.sh")
  
  print("dropping NCBI accession numbers and keeping distinct records")
  
  virion_out <- virion_unique |>
    dplyr::select(-NCBIAccession) |>
    dplyr::distinct()
  
  system("sh ./sys_deps/sys_specs.sh")
  
  print("dropped and distinct")

  print("writing csv.gz")
  vroom::vroom_write(virion_out,file = file,
                     delim = ","
                     )
  
}
