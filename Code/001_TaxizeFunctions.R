
library(taxize)
library(tidyverse)
library(magrittr)

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

mutate_cond <- function(.data, condition, ..., envir = parent.frame()) {
  condition <- eval(substitute(condition), .data, envir)
  .data[condition, ] <- .data[condition, ] %>% mutate(...)
  .data
}


hdict <- function(names) { 
  names.orig <- names
  names <- str_replace(names, " cf\\.","")
  names <- str_replace(names, " sp\\.","")
  names <- str_replace(names, " gen\\.","")
  u <- get_uid(names, rank_filter = c("subspecies", "species", "genus", "family", "order", "class"), 
               division_filter = "vertebrates", ask = FALSE)
  c <- classification(u, batch_size = 10)
  n <- !is.na(u)
  attributes(u) <- NULL
  s <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="species")]], error = function(e) {NA})}), use.names = FALSE)
  g <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="genus")]], error = function(e) {NA})}), use.names = FALSE)
  f <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="family")]], error = function(e) {NA})}), use.names = FALSE)
  o <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="order")]], error = function(e) {NA})}), use.names = FALSE)
  c2 <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="class")]], error = function(e) {NA})}), use.names = FALSE)
  
  levels <- c("species", "genus", "family", "order", "class")
  u <- unlist(lapply(c, function(x){tryCatch(last(na.omit(x[x$rank %in% levels,'id'])), 
                                             error = function(e) {NA})}), use.names = FALSE)
  
  data.frame(HostOriginal = names.orig,
             HostTaxID = u,
             HostNCBIResolved = n, 
             Host = s,
             HostGenus = g,
             HostFamily = f,
             HostOrder = o, 
             HostClass = c2) %>% mutate_cond(HostNCBIResolved == FALSE, Host = HostOriginal) %>% return()
}

vdict <- function(names) { 
  names.orig <- names
  u <- get_uid(names, batch_size = 5, ask = FALSE)
  c <- classification(u, batch_size = 5)
  n <- !is.na(u)
  attributes(u) <- NULL
  s <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="species")]], error = function(e) {NA})}), use.names = FALSE)
  g <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="genus")]], error = function(e) {NA})}), use.names = FALSE)
  f <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="family")]], error = function(e) {NA})}), use.names = FALSE)
  o <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="order")]], error = function(e) {NA})}), use.names = FALSE)
  c2 <- unlist(lapply(c, function(x){tryCatch(x$name[[which(x$rank=="class")]], error = function(e) {NA})}), use.names = FALSE)
  
  levels <- c("species", "genus", "family", "order", "class")
  u <- unlist(lapply(c, function(x){tryCatch(last(na.omit(x[x$rank %in% levels,'id'])), 
                                             error = function(e) {NA})}), use.names = FALSE)
  
  data.frame(VirusOriginal = names.orig,
             VirusTaxID = u,
             VirusNCBIResolved = n, 
             Virus = s,
             VirusGenus = g,
             VirusFamily = f,
             VirusOrder = o, 
             VirusClass = c2) %>% mutate_cond(VirusNCBIResolved == FALSE, Virus = VirusOriginal) %>% return()
}


jhdict <- function(spnames) {
  raw <- data.frame(Name = spnames)
  
  write_csv(raw, './Code/Code_Dev/TaxonomyTempIn.csv', eol = "\n")
  system("julia --project Code/Code_Dev/host.jl")
  clean <- read_csv("~/Github/virion/Code/Code_Dev/TaxonomyTempOut.csv")
  file.remove('~/Github/virion/Code/Code_Dev/TaxonomyTempIn.csv')
  file.remove('~/Github/virion/Code/Code_Dev/TaxonomyTempOut.csv')
  
  clean %<>% group_by(Name) %>% 
    slice(which.min(TaxId))
    
  clean %<>% rename(HostOriginal = Name,
                    HostTaxID = TaxId,
                    Host = Species,
                    HostGenus = Genus,
                    HostFamily = Family,
                    HostOrder = Order,
                    HostClass = Class) %>%
    mutate(HostNCBIResolved = TRUE) %>%
    select(-Rank)
  
  bad <- data.frame(HostOriginal = spnames[!(spnames %in% clean$HostOriginal)],
                    HostNCBIResolved = FALSE)
  
  clean %<>% bind_rows(bad) %>%
    select(HostOriginal, HostTaxID, HostNCBIResolved, Host, HostGenus, HostFamily, HostOrder, HostClass)
  
  return(clean)
}


jvdict <- function(spnames) {
  raw <- data.frame(Name = spnames)
  
  write_csv(raw, './Code/Code_Dev/TaxonomyTempIn.csv', eol = "\n")
  system("julia --project Code/Code_Dev/virus.jl")
  clean <- read_csv("~/Github/virion/Code/Code_Dev/TaxonomyTempOut.csv")
  file.remove('~/Github/virion/Code/Code_Dev/TaxonomyTempIn.csv')
  file.remove('~/Github/virion/Code/Code_Dev/TaxonomyTempOut.csv')
  
  clean %<>% group_by(Name) %>% 
    slice(which.min(TaxId))
  
  clean %<>% rename(VirusOriginal = Name,
                    VirusTaxID = TaxId,
                    Virus = Species,
                    VirusGenus = Genus,
                    VirusFamily = Family,
                    VirusOrder = Order,
                    VirusClass = Class) %>%
    mutate(VirusNCBIResolved = TRUE) %>%
    select(-Rank)
  
  bad <- data.frame(VirusOriginal = spnames[!(spnames %in% clean$VirusOriginal)],
                    VirusNCBIResolved = FALSE)
  
  clean %<>% bind_rows(bad) %>%
    select(VirusOriginal, VirusTaxID, VirusNCBIResolved, Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass)
  
  return(clean)
}

