#' Deposit data into Zenodo
#' 
#' Creates a new version of the Virion data deposit. Note that the deposit must exist.
#'
#' @param metadata List. Descriptive metadata terms for the deposit. see deposits::dcmi_terms 
#' @param sandbox Logical. Should we be using the zenodo sandbox? Good for testing.
#' @param resource Character. Path to deposit resources
#' @param outputs List. Targets that created outputs to be deposited.
#'
#' @return Data frame. deposit information for the updated deposit.
#' @author collinschwantes
#' @export
deposit_data <- function(metadata = metadata,
                         outputs,
                         resource = here::here("outputs"),
                         sandbox = FALSE) {
  
  ## check that outputs are not null
  
  check_outputs <- purrr::map_lgl(outputs, \(x){rlang::is_empty(x)|rlang::is_na(x)}
  )
  
  if(any(check_outputs)){
    missing_outputs <- names(outputs)[check_outputs] |>
      paste(collapse = "\n")
    
    msg <- sprintf("Required output is empty or NA:\n%s",missing_outputs)
    
    rlang::abort(msg)
  }
  
  
  # create client
  cli <- deposits::depositsClient$new(service = "zenodo",
                                      sandbox = sandbox)
  
  # assumes unique titles
  deposit_title <- metadata$title
  
  deposit_id <- cli$deposits |>
    dplyr::filter(title == deposit_title) |> 
    dplyr::pull(id)
  
  if(length(deposit_id) != 1){
    stop("Multiple deposits with the same title")
  }
  
  cli$deposit_retrieve(deposit_id = deposit_id)
  cli$deposit_version()

  # add files
  cli$deposit_add_resource(path = resource)
  
  # upload files
  for(i in fs::dir_ls(resource,regexp = "csv")){
    cli$deposit_upload_file(path = i)
  }
  
  
  # cli$deposit_update(path = "outputs/detection.csv.gz")
  
  # update metadata 
  cli$metadata <- metadata
  cli$deposit_fill_metadata(metadata)
  # add descriptions to datapackage.json
  
  data_package <- jsonlite::read_json("outputs/datapackage.json")
  all_defs  <- all_definitions()
  
  for(i in 1:length(data_package$resources)){
    print(i)
    resource_item <- data_package$resources[[i]]
    # get the definition
    def_filter <- stringr::str_detect(resource_item$name,pattern = names(all_defs))  
    defs_filtered <- all_defs[def_filter][[1]]
    
    # get the fields from the resource schema
    resource_fields <- resource_item$schema$fields
    
    # add descriptions
    resource_fields_described <- purrr::map(resource_fields, function(x){
      def <- defs_filtered[names(defs_filtered) %in% x$name]
      x$description <- def[[1]]
      return(x)
    })
    
    # add the updated fields to the schema
    resource_item$schema$fields <- resource_fields_described
    
    # update the resource in the data package
    data_package$resources[[i]] <- resource_item
  }
  
  data_package$metadata <- metadata

  # write 
  data_package_json <- jsonlite::write_json(x = data_package,path = "outputs/datapackage.json",pretty = TRUE,auto_unbox = TRUE)
  
  # check that the package was properly written
  pkg <- frictionless::read_package("outputs/datapackage.json")
  frictionless::check_package(pkg) 
  
  # update it!
  cli$deposit_update()
  # publish it!
  cli$deposit_publish()
  
  out <- cli$deposits %>% 
    dplyr::filter(id == deposit_id)
  return(out)
}
