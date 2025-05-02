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
mutate_cond <- function(.data, condition, ..., envir = parent.frame()) {
  condition <- eval(substitute(condition), .data, envir)
  .data[condition, ] <- .data[condition, ] %>% dplyr::mutate(...)
  .data
}

#' hdict()
#' 
#' @description dictionary function for the host species - 
#' using the names from the parent object, construct a new 
#' dataframe that has all the relevant taxonomic variables split out into 
#' new columns for easier presentation
#' 
#' @param names vector of names of the object
#' 
#' @return dataframe after all taxonomic operations
hdict <- function(names) { 
  
  # first deal with the names and get rid of every misplaced prefix
  names.orig <- names
  names <- stringr::str_replace(names, " cf\\.","")
  names <- stringr::str_replace(names, " sp\\.","")
  names <- stringr::str_replace(names, " gen\\.","")
  
  # taxize function to get the UID codes for the taxonomic names
  u <- taxize::get_uid(names, 
                       rank_filter = c("subspecies", "species", "genus", 
                                       "family", "order", "class"), 
               division_filter = "vertebrates", ask = FALSE)
  
  # tazise function to get the taxonomic hierarchy
  c <- taxize::classification(u, batch_size = 10)
  n <- !is.na(u) # keep the non-NA ones
  attributes(u) <- NULL
  
  # go through and get all of the separate taxonomic levels and extract them 
  # into vectors
  s <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="species")]], 
             error = function(e) {NA}
             )}), use.names = FALSE)
  g <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="genus")]], 
             error = function(e) {NA})}), use.names = FALSE)
  f <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="family")]], 
             error = function(e) {NA})}), use.names = FALSE)
  o <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="order")]], 
             error = function(e) {NA})}), use.names = FALSE)
  c2 <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="class")]], 
             error = function(e) {NA})}), use.names = FALSE)
  
  # extracting across all the levels here
  levels <- c("species", "genus", "family", "order", "class")
  u <- unlist(lapply(c, function(x){
    tryCatch(last(na.omit(x[x$rank %in% levels,'id'])), 
             error = function(e) {NA})}), use.names = FALSE)
  
  # turn the extracted vectors into a dataframe and return it 
  data.frame(HostOriginal = names.orig,
             HostTaxID = u,
             HostNCBIResolved = n, 
             Host = s,
             HostGenus = g,
             HostFamily = f,
             HostOrder = o, 
             HostClass = c2) %>% 
    mutate_cond(HostNCBIResolved == FALSE, Host = HostOriginal) %>% return()
}

#' vdict()
#' 
#' @description dictionary for the virus taxonomic names - 
#' using the names from the parent object, construct a new 
#' dataframe that has all the relevant taxonomic variables split out into 
#' new columns for easier presentation
#' 
#' @param names vector of names of the object
#' 
#' @return dataframe after all taxonomic operations
vdict <- function(names) { 
  
  # first deal with the names and get rid of every misplaced prefix
  names.orig <- names
  u <- taxize::get_uid(names, batch_size = 5, ask = FALSE)
  c <- taxize::classification(u, batch_size = 5)
  n <- !is.na(u)
  attributes(u) <- NULL
  
  # go through and get all of the separate taxonomic levels and extract them 
  # into vectors
  s <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="species")]], 
             error = function(e) {NA})}), use.names = FALSE)
  g <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="genus")]], 
             error = function(e) {NA})}), use.names = FALSE)
  f <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="family")]], 
             error = function(e) {NA})}), use.names = FALSE)
  o <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="order")]], 
             error = function(e) {NA})}), use.names = FALSE)
  c2 <- unlist(lapply(c, function(x){
    tryCatch(x$name[[which(x$rank=="class")]], 
             error = function(e) {NA})}), use.names = FALSE)
  
  # extracting across all the levels here
  levels <- c("species", "genus", "family", "order", "class")
  u <- unlist(lapply(c, function(x){
    tryCatch(last(na.omit(x[x$rank %in% levels,'id'])), 
             error = function(e) {NA})}), use.names = FALSE)
  
  # turn the extracted vectors into a dataframe and return it 
  data.frame(VirusOriginal = names.orig,
             VirusTaxID = u,
             VirusNCBIResolved = n, 
             Virus = s,
             VirusGenus = g,
             VirusFamily = f,
             VirusOrder = o, 
             VirusClass = c2) %>% 
    mutate_cond(VirusNCBIResolved == FALSE, Virus = VirusOriginal) %>% return()
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
  
  # turn this into a dataframe for ease
  raw <- data.frame(Name = spnames)
  
  # this raw temp df is going to be passed to julia 
  readr::write_csv(raw, here::here("./Code/Code_Dev/TaxonomyTempIn.csv"),
            eol = "\n")
  
  # ensure that the system() call is giving the whole path name of the file
  system(paste0(
    "julia --project ",
    here::here("Code/Code_Dev/host.jl"))) # this is better for reproducing this
  
  # after Julia has worked read in the cleaned file and get rid of the tmp files
  clean <- readr::read_csv(here::here("./Code/Code_Dev/TaxonomyTempOut.csv"))
  file.remove(here::here("./Code/Code_Dev/TaxonomyTempIn.csv"))
  file.remove(here::here("./Code/Code_Dev/TaxonomyTempOut.csv"))
  
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
           HostGenus, HostFamily, HostOrder, HostClass)
  
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
  
  # turn this into a dataframe for ease
  raw <- data.frame(Name = spnames)
  
  # this raw temp df is going to be passed to julia
  readr::write_csv(raw, here::here("./Code/Code_Dev/TaxonomyTempIn.csv"), 
                   eol = "\n")
  
  # ensure that the system() call is giving the whole path name of the file
  system(paste0(
    "julia --project ",
    here::here("Code/Code_Dev/virus.jl"))) # this is better for reproducing this
  
  # after Julia has worked read in the cleaned file and get rid of the tmp files
  clean <- readr::read_csv(here::here("./Code/Code_Dev/TaxonomyTempOut.csv"))
  file.remove(here::here("./Code/Code_Dev/TaxonomyTempIn.csv"))
  file.remove(here::here("./Code/Code_Dev/TaxonomyTempOut.csv"))
  
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
                  VirusGenus, VirusFamily, VirusOrder, VirusClass)
  
  return(clean)
}

# tests ========================================================================

virus.test <- c("Adeno-associated virus - 3", 
           "Adeno-associated virus 3B",
           "Adenovirus predict_adv-20",
           "A bad name")
host.test <- c("Equus caballus ferus",
               "Homo sapiens",
               "Hongus bongus",
               "Chiroptera",
               "Mus",
               "Bacillus anthracis")
