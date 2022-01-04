
library(taxize)
library(tidyverse)

test <- c("Adeno-associated virus - 3", 
           "Adeno-associated virus 3B",
           "Adenovirus predict_adv-20",
           "A bad name")

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

sleepy.hdict <- function(names.big) {
  j = 1 
  k = 1
  while (k == 1){
    names <- names.big[j:(min(j+9, length(names.big)))]
    
    clean <- tryCatch(hdict(names), error = "Server error (429) happened, waiting 60s")
    if(!is.data.frame(clean)) {
      Sys.sleep(60)
      clean <- tryCatch(hdict(names), error = "Server error (429) happened, waiting 60s")
      while(!is.data.frame(clean)) {      
        Sys.sleep(60)
        clean <- tryCatch(hdict(names), error = "Server error (429) happened, waiting 60s")
      }
    }
  
    if( j == 1) { clean.big <- clean } else { clean.big <- bind_rows(clean.big, clean) }
    
    if(length(names.big) <= j+9) {k = 2}
    j <- j + 10
    Sys.sleep(10)
  }
  return(clean.big)
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

sleepy.vdict <- function(names.big) {
  j = 1 
  k = 1
  while (k == 1){
    names <- names.big[j:(min(j+9, length(names.big)))]
    
    clean <- tryCatch(vdict(names), error = "Server error (429) happened, waiting 60s")
    if(!is.data.frame(clean)) {
      Sys.sleep(60)
      clean <- tryCatch(vdict(names), error = "Server error (429) happened, waiting 60s")
      while(!is.data.frame(clean)) {      
        Sys.sleep(60)
        clean <- tryCatch(vdict(names), error = "Server error (429) happened, waiting 60s")
      }
    }
    
    if( j == 1) { clean.big <- clean } else { clean.big <- bind_rows(clean.big, clean) }
    
    if(length(names.big) <= j+9) {k = 2}
    j <- j + 10
    Sys.sleep(10)
  }
  return(clean.big)
}
