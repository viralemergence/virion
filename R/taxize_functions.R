#' Setting up the taxa functions 
#' 
#' There are a couple of functions that we need for the taxonomic stuff, we'll 
#' do that and test it here

# functions ====================================================================

#' mutate_cond
#' 
#' @description a base R / dplyr mashup to do some data manipulation
#' 
#' @param .data implied data object that we need 
#' @param condition the condition that we're checking 
#' @param envir note that this needs access to the parent set of call stacks
#' 
#' @return .data  
mutate_cond_old <- function(.data, condition, ..., envir = parent.frame()) {
  condition <- eval(substitute(condition), .data, envir)
  .data[condition, ] <- .data[condition, ] %>% dplyr::mutate(...)
  .data
}


#' jhdict()
#' 
#' @description dictionary for the host taxonomic names but with Julia - 
#' using the names from the parent object, construct a new 
#' dataframe that has all the relevant taxonomic variables split out into 
#' new columns for easier presentation
#' 
#' @param spnames vector of species names in the object
#' 
#' @return dataframe after all both Julia and R operations
jhdict <- function(spnames) {
  ## has to be lower case to work with the Julia funcs
  spnames  <- tolower(spnames)

  # turn this into a dataframe for ease
  raw <- data.frame(Name = spnames)

  # this raw temp df is going to be passed to julia 
  readr::write_csv(raw, here::here("Code/Code_Dev/TaxonomyTempIn.csv"),
            eol = "\n")
  
  # ensure that the system() call is giving the whole path name of the file
  ## ran system install steps from gh actions workflow first
  ####################
  ### ADD sys_deps/julia_deps.sh
  
   system(paste0("julia --project ", here::here("Code/Code_Dev/host.jl"))) # this is better for reproducing this

  # JuliaCall::julia_setup(JULIA_HOME = "/Users/cjs242/.julia/juliaup/julia-1.12.0-beta2+0.aarch64.apple.darwin14/bin",rebuild = TRUE)
  # install.ncbi() ## add packages
  # JuliaCall::julia_source(file_name = here::here("Code/Code_Dev/virus.jl"))
  
  
  # after Julia has worked read in the cleaned file and get rid of the tmp files
  clean <- readr::read_csv(here::here("Code/Code_Dev/TaxonomyTempOut.csv"))
  file.remove(here::here("Code/Code_Dev/TaxonomyTempIn.csv"))
  file.remove(here::here("Code/Code_Dev/TaxonomyTempOut.csv"))
  
  # the clean file needs to be sliced up 
  clean %<>% dplyr::group_by(Name) %>% 
    dplyr::slice(which.min(TaxId))
  
  # there's a renaming process to keep all the names of the df standard
  clean %<>% dplyr::rename(HostOriginal = Name,
                    HostTaxID = TaxId,
                    Host = Species,
                    HostGenus = Genus,
                    HostFamily = Family,
                    HostOrder = Order,
                    HostClass = Class) %>%
    dplyr::mutate(HostNCBIResolved = TRUE) %>%
    dplyr::select(-Rank)
  
  # bad df is the one for which we don't have the NCBI resolved values 
  bad <- data.frame(HostOriginal = spnames[!(spnames %in% clean$HostOriginal)],
                    HostNCBIResolved = FALSE)
  
  # keeping both parts, but also want the bad ones, but it's noted in the 
  # HostNCBIResolved column
  clean %<>% dplyr::bind_rows(bad) %>%
    dplyr::select(HostOriginal, HostTaxID, HostNCBIResolved, Host, 
           HostGenus, HostFamily, HostOrder, HostClass) %>% 
    dplyr::mutate(HostOriginal = stringr::str_to_sentence(HostOriginal))
  
  return(clean)
}

#' jvdict()
#' 
#' @description dictionary for the virus taxonomic names but with Julia - 
#' using the names from the parent object, construct a new 
#' dataframe that has all the relevant taxonomic variables split out into 
#' new columns for easier presentation
#' 
#' @param spnames vector of species names in the object
#' 
#' @return dataframe after all both Julia and R operations
jvdict <- function(spnames) {
  
  ## has to be lower case to work with the Julia funcs
  spnames  <- tolower(spnames)
  
  # turn this into a dataframe for ease
  raw <- data.frame(Name = spnames)
  
  # this raw temp df is going to be passed to julia
  readr::write_csv(raw, here::here("Code/Code_Dev/TaxonomyTempIn.csv"), 
                   eol = "\n")
  
  # ensure that the system() call is giving the whole path name of the file
  # ran system install steps from gh actions workflow first
  system(paste0(
    "julia --project ",
    here::here("Code/Code_Dev/virus.jl"))) # this is better for reproducing this
  
  print("made it through the julia")
  if(!fs::file_exists(path = here::here("Code/Code_Dev/TaxonomyTempOut.csv"))){
    stop("jvdict: TaxonomyTempOut.csv not written")
  }
  
  # JuliaCall::julia_setup(JULIA_HOME = "/Users/cjs242/.julia/juliaup/julia-1.12.0-beta2+0.aarch64.apple.darwin14/bin",rebuild = TRUE)
  # install.ncbi() ## add packages
  # JuliaCall::julia_source(file_name = here::here("Code/Code_Dev/virus.jl"))
  
  # after Julia has worked read in the cleaned file and get rid of the tmp files
  clean <- readr::read_csv(here::here("Code/Code_Dev/TaxonomyTempOut.csv"))
  file.remove(here::here("Code/Code_Dev/TaxonomyTempIn.csv"))
  file.remove(here::here("Code/Code_Dev/TaxonomyTempOut.csv"))
  
  # there's a renaming process to keep all the names of the df standard
  clean %<>% dplyr::group_by(Name) %>% 
    dplyr::slice(which.min(TaxId))

  # there's a renaming process to keep all the names of the df standard
  clean %<>% dplyr::rename(VirusOriginal = Name,
                    VirusTaxID = TaxId,
                    Virus = Species,
                    VirusGenus = Genus,
                    VirusFamily = Family,
                    VirusOrder = Order,
                    VirusClass = Class) %>%
    dplyr::mutate(VirusNCBIResolved = TRUE) %>%
    dplyr::select(-Rank)
  
  # bad df is the one for which we don't have the NCBI resolved values 
  bad <- data.frame(
    VirusOriginal = spnames[!(spnames %in% clean$VirusOriginal)],
                    VirusNCBIResolved = FALSE)
  
  # keeping both parts, but also want the bad ones, but it's noted in the 
  # HostNCBIResolved column
  clean %<>% dplyr::bind_rows(bad) %>%
    dplyr::select(VirusOriginal, VirusTaxID, VirusNCBIResolved, Virus, 
                  VirusGenus, VirusFamily, VirusOrder, VirusClass) %>% 
    dplyr::mutate(VirusOriginal = stringr::str_to_sentence(VirusOriginal))
  
  return(clean)
}

# tests ========================================================================

# virus.test <- c("Adeno-associated virus - 3", 
#            "Adeno-associated virus 3B",
#            "Adenovirus predict_adv-20",
#            "A bad name")
# host.test <- c("Equus caballus ferus",
#                "Homo sapiens",
#                "Hongus bongus",
#                "Chiroptera",
#                "Mus",
#                "Bacillus anthracis")
