library(taxize)
library(rgbif)
library(doParallel)
library(plyr)


#' function to find and resolve taxonomic synonyms based on Encyclopedia of Life
#'
#'
#' @param x
#' @return a thing
findSyns2 = function(x){
  
  # get specific species name
  taxname = hosts_vec[x]
  
  # print progress
  print(paste("Processing:", taxname, sep=" "))
  
  # phyla to consider
  phyla = c("Chordata","Arthropoda","Gastropoda", "Mollusca")
  
  # (1) resolve misspellings
  taxname_resolved = gnr_resolve(taxname, with_canonical_ranks = TRUE)$matched_name2[1]
  if(!is.null(taxname_resolved)){ if(length(strsplit(taxname_resolved, " ", fixed=TRUE)[[1]]) == 2 ){ taxa = taxname_resolved }}
  if(!is.null(taxname_resolved)){ if(length(strsplit(taxname_resolved, " ", fixed=TRUE)[[1]]) > 2 ){ taxa = paste(strsplit(taxname_resolved, " ", fixed=TRUE)[[1]][1:2], collapse=" ")} }
  
  # if taxa == NA, return list with nothing defined 
  if(is.na(taxa)){   if(class(syns)[1] == 'simpleError'){ return(data.frame(Original=taxname, Submitted=taxname_resolved, Accepted_name=NA, Selected_family=NA, Selected_order=NA, Selected_class=NA, Synonyms=NA))} }
  
  # (2) remove sub-species categorisations and set 'genus' and 'species' variables
  genus = NULL
  if(length(strsplit(taxa, " ", fixed=TRUE)[[1]]) %in% c(2,3)){ genus = strsplit(taxa," ",fixed=TRUE)[[1]][1]; species = strsplit(taxa," ",fixed=TRUE)[[1]][2] }
  if(length(strsplit(taxa, "_", fixed=TRUE)[[1]]) %in% c(2,3)){ genus = strsplit(taxa,"_",fixed=TRUE)[[1]][1]; species = strsplit(taxa,"_",fixed=TRUE)[[1]][2] }
  if(length(strsplit(taxa, " ", fixed=TRUE)[[1]]) >3 | length(strsplit(taxa, "_" , fixed=TRUE)[[1]][1]) > 3){ return("name error") }
  if(is.null(genus)){ genus = taxa; species = NA }
  
  # (3) use genus to lookup family, order, class
  syns = tryCatch( name_lookup(genus)$data, error = function(e) e)
  if(class(syns)[1] == 'simpleError'){ return(data.frame(Original=taxname, Submitted=taxa, Accepted_name=NA, Selected_family=NA, Selected_order=NA, Selected_class=NA, Synonyms=NA))}
  
  # for cases where the lookup does not find a phylum within the specified range
  if(all(! syns$phylum %in% phyla)){
    fam1 = syns$family[ !is.na(syns$family) & !is.na(syns$phylum) ]
    order1 = syns$order[ !is.na(syns$family) & !is.na(syns$phylum) ]
    class1 = syns$class[ !is.na(syns$family) & !is.na(syns$phylum) ]
    datfam = data.frame(fam1=fam1, order=1:length(fam1), order1=order1, class1=class1)
    # select highest frequency fam/class/order combo
    fam2 = as.data.frame( table(datfam[ , c(1,3,4)]) )
    family2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "fam1"] ) 
    order2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "order1"] )
    class2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "class1"] )
    if(length(fam2) > 1){
      datfam2 = datfam[datfam$fam1 %in% family2, ]
      family2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "fam1"])
      order2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "order1"])
      class2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "class1"])
    }
  } else {	# for everything else
    fam1 = syns$family[ !is.na(syns$family) & !is.na(syns$phylum) & (syns$phylum %in% phyla) ]
    order1 = syns$order[ !is.na(syns$family) & !is.na(syns$phylum) & (syns$phylum %in% phyla) ]
    class1 = syns$class[ !is.na(syns$family) & !is.na(syns$phylum) & (syns$phylum %in% phyla) ]
    datfam = data.frame(fam1=fam1, order=1:length(fam1), order1 = order1, class1=class1)
    # select highest frequency fam/class/order combo
    fam2 = as.data.frame( table(datfam[ , c(1,3,4)]) )
    family2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "fam1"] ) 
    order2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "order1"] )
    class2 = as.vector(fam2[ fam2$Freq==max(fam2$Freq, na.rm=TRUE), "class1"] )
    # select highest in list if more than one max
    if(length(family2) > 1){
      datfam2 = datfam[datfam$fam1 %in% family2, ]
      family2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "fam1"])
      order2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "order1"])
      class2 = as.vector(datfam2[datfam2$order == min(datfam2$order, na.rm=TRUE), "class1"])
    } 
  }
  
  # # (4) search for species records in EOL
  # eol = tryCatch(as.data.frame(eol_search(taxa)), error = function(e) e)
  # if(class(eol)[1] == 'simpleError'){ return(list(Original=taxname, Submitted=taxa, Taxa_synonyms="EOL lookup failed", Selected_family="EOL lookup failed"))}
  # 
  # # (5) get EOL species records and identify current synonyms
  # if(nrow(eol)>5) eol = eol[ 1:5, ]
  # getEOLrecs = function(x){ as.data.frame(eol_pages(eol$pageid[x])$scinames) }
  # recs = tryCatch(do.call(rbind.data.frame, lapply(1:nrow(eol), getEOLrecs)), error=function(e) e)
  # #recs = tryCatch(eol_pages(eol$pageid[1])$scinames, error=function(e) e)
  # if(class(recs)[1] == 'simpleError'){ return(list(Original=taxname, Submitted=taxa, Taxa_synonyms="EOL processing failed", Selected_family="EOL processing failed"))}
  # synonyms = unique(recs$canonicalform)
  
  # (4) search for species synonyms in ITIS
  syns = tryCatch(suppressMessages(synonyms(get_tsn(taxa, ask = FALSE, accepted = TRUE), db='itis')), error=function(e) e)
  if(class(syns)[1] == 'simpleError'){ return(data.frame(Original=taxname, Submitted=taxa, Accepted_name="failed", Selected_family=family2, Selected_order=order2, Selected_class=class2, Synonyms="failed"))}
  syns = as.data.frame(syns[[1]])
  
  # get info
  original = taxa
  accepted_name = taxa # save accepted name as original searched name
  if("acc_name" %in% names(syns)){ accepted_name = syns$acc_name } # unless search shows that this is not the accepted name
  # if("message" %in% names(syns) & syns$message == "no syns found"){ synonyms = NA 
  # } else if("syn_name" %in% names(syns)){ synonyms = unique(syns$syn_name) 
  # } else{ synonyms = NA
  # } # add synonyms
  if("syn_name" %in% names(syns)){ synonyms = unique(syns$syn_name) 
  } else{ synonyms = NA }
  
  # combine into list and add synonyms 
  result = data.frame(Original=taxname, 
                      Submitted=taxa,
                      Accepted_name=accepted_name,
                      Selected_family=family2,
                      Selected_order=order2,
                      Selected_class=class2)
  result = do.call("rbind", replicate(length(synonyms), result[1, ], simplify = FALSE))
  result$Synonyms = synonyms
  return(result)
}


#' nest function within a tryCatch call in case of any errors
#'
#'
#' @param x
#' @return a thing
findSyns3 = function(x){
  result = tryCatch(findSyns2(x), error=function(e) NULL)
  return(result)
}

