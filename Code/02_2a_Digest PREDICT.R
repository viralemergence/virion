
if(!exists('jncbi')) {source('Code/001_Julia functions.R')}
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

library(tidyverse)
library(magrittr)
library(lubridate)

predict.raw <- read_csv("~/Github/ept/PredictData (2).csv")

predict.raw %>% 
  
  # Drop long lats, number of records
  select(`Sample Date`, 
         `Species Scientific Name Based on Field Morphology`, 
         Virus,
         `Genbank #`) %>% 
  
  # Some minor variable recodings 
  rename(Date = `Sample Date`, 
         Host = `Species Scientific Name Based on Field Morphology`,
         Accession = `Genbank #`) %>%
  
  # group_by_at(vars(-Accession)) %>% 
  # summarize(Accession = str_c(Accession, collapse = ", ")) %>%
  unique() %>%  
  
  # The below step deals with flagged host names and "cf." names equally
  mutate(HostFlagID = ifelse((str_detect(Host, "\\*")|str_detect(Host,"cf.")),
                             TRUE,
                             FALSE)) %>%
  mutate(Host = str_replace(Host, " \\*",""),
         Host = str_replace(Host, "cf. ","")) %>%  
  
  # Back up the virus names before doing anything else
  
  mutate(VirusOriginal = Virus) %>% 
  rename(VirusIntermediate = "Virus") %>% 
  
  # Remove "Strain of" from virus names
  mutate(VirusIntermediate = str_replace(VirusIntermediate, "strain of ","")) %>%
  
  # Fix the date information into the right format
  mutate(CollectionYear = year(Date),
         CollectionMonth = month(Date),
         CollectionDay = day(Date),
         ReleaseYear = 2021,
         ReleaseMonth = 3,
         ReleaseDay = 9,
         Database = "PREDICT",
         DatabaseVersion = "March92021FlatFile",
         DetectionMethod = "PCR/Sequencing") %>%
  select(-Date) -> predict

# First, let's fix some typos and such

predict %>% rowwise() %>% mutate(VirusIntermediate = strsplit(VirusIntermediate, split="\\(")[[1]][1]) -> predict
predict %>% rowwise() %>% mutate(VirusIntermediate = strsplit(VirusIntermediate, split=", subtype")[[1]][1]) -> predict
predict %>% rowwise() %>% mutate(VirusIntermediate = strsplit(VirusIntermediate, split=", partial subtype")[[1]][1]) -> predict

predict %>% mutate(VirusIntermediate = recode(VirusIntermediate, !!!c("Yellow Fever" = "Yellow fever virus", 
                                                                      "Dengue virus serotype 1" = "Dengue virus", 
                                                                      "Dengue virus serotype 2" = "Dengue virus", 
                                                                      "Dengue virus serotype 3" = "Dengue virus", 
                                                                      "Dengue virus serotype 4" = "Dengue virus", 
                                                                      "Influenza A" = "Influenza A virus",
                                                                      "Influenza B" = "Influenza B virus",
                                                                      "Human BK Polyomavirus" = "Human polyomavirus 1",
                                                                      "Porcine Parainfluenzavirus 1" = "Porcine parainfluenza virus",
                                                                      "Human Parainfluenzavirus 1" = "Human respirovirus 1",
                                                                      "Human Parainfluenzavirus 3" = "Human respirovirus 3",
                                                                      "Human Parainfluenzavirus 2" = "Human rubulavirus 2",
                                                                      "Human Parainfluenzavirus 4" = "Human rubulavirus 4",
                                                                      "Marburg Virus " = "Marburg marburgvirus",
                                                                      "MERS-like Coronovirus" = "Bat MERS-like coronavirus",
                                                                      "Monkey pox" = "Monkeypox virus",
                                                                      "Morogoro virus" = "Morogoro mammarenavirus",
                                                                      "SFVHpi" = "Simian foamy virus"))) -> predict

# Now: the taxonomy. First: generate a list of every PREDICT_ virus name 

predict %>% pull(VirusIntermediate) %>% unique %>% str_subset("PREDICT_") %>%
  str_split("-") %>% unlist %>% str_subset("PREDICT_") %>% unique -> predict.prefix

predict.tax <- data.frame(Virus = sort(predict.prefix), 
                          full = NA,
                          VirusGenus = NA, 
                          VirusFamily = NA, 
                          VirusOrder = NA)

predict.tax[1,2:5] <- c("Adeno-associated virus", "Dependoparvovirus", "Parvoviridae", "Piccovirales")
predict.tax[2,2:5] <- c("Adenovirus", NA, "Adenoviridae", "Rowavirales")
predict.tax[3,2:5] <- c("Arenavirus", NA, "Arenaviridae", "Bunyavirales")
predict.tax[4,2:5] <- c("Bocaparvovirus", "Bocaparvovirus", "Parvoviridae", "Picornavirales")
predict.tax[5,2:5] <- c("Coronavirus", NA, "Coronaviridae", "Nidovirales")
predict.tax[6,2:5] <- c("Enterovirus", "Enterovirus", "Picornaviridae", "Picornavirales")
predict.tax[7,2:5] <- c("Flavivirus", NA, "Flaviviridae", "Amarillovirales")
predict.tax[8,2:5] <- c("Hantavirus", NA, "Hantaviridae", "Bunyavirales")
predict.tax[9,2:5] <- c("Herpesvirus", NA, "Herpesviridae", "Herpesvirales")
predict.tax[10,2:5] <- c("Lentivirus", "Lentivirus", "Retroviridae", "Ortervirales")
predict.tax[11,2:5] <- c("Mamastrovirus", "Mamastrovirus", "Astroviridae", "Stellavirales")
predict.tax[12,2:5] <- c("Murine norovirus", "Norovirus", "Caliciviridae", "Picornavirales")
predict.tax[13,2:5] <- c("Orbivirus", "Orbivirus", "Reoviridae", "Reovirales")
predict.tax[14,2:5] <- c("Papillomavirus", NA, "Papillomaviridae", "Zurhausenvirales")
predict.tax[15,2:5] <- c("Picobirnavirus", NA, "Picobirnaviridae", "Durnavirales")
predict.tax[16,2:5] <- c("Phlebovirus", "Phleboviridae", "Phenuiviridae", "Bunyavirales")
predict.tax[17,2:5] <- c("Picornavirus", NA, "Picornaviridae", "Picornavirales")
predict.tax[18,2:5] <- c("Paramyxovirus", NA, "Paramyxoviridae", "Mononegavirales")
predict.tax[19,2:5] <- c("Posavirus", NA, NA, "Picornavirales")
predict.tax[20,2:5] <- c("Poxvirus", NA, "Poxviridae", "Chitovirales")
predict.tax[21,2:5] <- c("Polyomavirus", NA, "Polyomaviridae", "Sepolyvirales")
predict.tax[22,2:5] <- c("Rhabdovirus", NA, "Rhabdoviridae", "Mononegavirales")
predict.tax[23,2:5] <- c("Seadornavirus", "Seadornavirus", "Reoviridae", "Reovirales")

predict %>% pull(VirusIntermediate) %>% unique -> predict.names

predict.tax.big <- data.frame(FullName = (predict.names %>% str_subset("PREDICT_")))

predict.tax.big %>% separate(col = FullName, into = c("Virus","Number"), sep = "-", remove = FALSE) %>% 
  left_join(predict.tax) %>% rename(Short = "Virus", Virus = "FullName") %>%
  select(-c("Short", "Number", "full")) -> predictionary

# Check if literally any of these are NCBI resolved, which the vast majority are not

# for (i in 1:nrow(predictionary)) {
#   ncbi.num <- taxize::get_uid(predictionary$Virus[i])
#   ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
#   if(!is.na(ncbi.high[[1]][1])){
#     predictionary$VirusNCBIResolved[i] <- TRUE
#     predictionary$VirusTaxID[i] <- ncbi.num[[1]]
#   } else {
#     predictionary$VirusNCBIResolved[i] <- FALSE
#     predictionary$VirusTaxID[i] <- NA
#   }
#   print(i)
# }

predictionary$VirusNCBIResolved = FALSE
predictionary$VirusTaxID = NA
predictionary$VirusIntermediate = predictionary$Virus

# Test run of the NCBI part of this

predict %>% pull(VirusIntermediate) %>% str_subset("PREDICT", negate = TRUE) %>% unique() %>% sort() -> ncbi.names

ncbi.tax <- vdict(ncbi.names)

ncbi.tax %<>% rename(VirusIntermediate = "VirusOriginal")

# Add some guardrails 

for (i in 1:nrow(ncbi.tax)) {
  # "(?i)a"
  if(is.na(ncbi.tax$VirusOrder[i])){ # Only pull ones that haven't already been queried
    if(str_detect(ncbi.tax$Virus[i], "(?i)cytomegalovirus")) {
      ncbi.tax$VirusGenus[i] <- "Cytomegalovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)adenovirus")) {
      ncbi.tax$VirusFamily[i] <- "Adenoviridae"
      ncbi.tax$VirusOrder[i] <- "Rowavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)alphacoronavirus")) {
      ncbi.tax$VirusGenus[i] <- "Alphacoronavirus"
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)betacoronavirus")) {
      ncbi.tax$VirusGenus[i] <- "Betacoronavirus"
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)coronavirus")) {
      ncbi.tax$VirusFamily[i] <- "Coronaviridae"
      ncbi.tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)paramyxovirus")) {
      ncbi.tax$VirusFamily[i] <- "Paramyxoviridae"
      ncbi.tax$VirusOrder[i] <- "Mononegavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)foamy")) {
      ncbi.tax$VirusGenus[i] <- "Spumavirus"
      ncbi.tax$VirusFamily[i] <- "Retroviridae"
      ncbi.tax$VirusOrder[i] <- "Ortervirales"
    }
    
    #"Hantaviridae", "Bunyavirales")
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)hantavirus")) {
      ncbi.tax$VirusFamily[i] <- "Hantaviridae"
      ncbi.tax$VirusOrder[i] <- "Bunyavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)bocavirus")) {
      ncbi.tax$VirusGenus[i] <- "Bocaparvovirus"
      ncbi.tax$VirusFamily[i] <- "Parvoviridae"
      ncbi.tax$VirusOrder[i] <- "Picornavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)lymphocryptovirus")) {
      ncbi.tax$VirusGenus[i] <- "Lymphocryptovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)herpesvirus")) {
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)astrovirus")) {
      ncbi.tax$VirusFamily[i] <- "Astroviridae"
      ncbi.tax$VirusOrder[i] <- "Stellavirales"
    }
    
    if(str_detect(ncbi.tax$Virus[i], "(?i)rhadinovirus")) {
      ncbi.tax$VirusGenus[i] <- "Rhadinovirus"
      ncbi.tax$VirusFamily[i] <- "Herpesviridae"
      ncbi.tax$VirusOrder[i] <- "Herpesvirales"
    }
  }
}

# And finally

ncbi.tax[ncbi.tax$Virus=="YN12103/CHN/2012","VirusFamily"] <- "Paramyxoviridae"
ncbi.tax[ncbi.tax$Virus=="YN12103/CHN/2012","VirusOrder"] <- "Mononegavirales"

ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusGenus"] <- "Alphacoronavirus"
ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusFamily"] <- "Coronaviridae"
ncbi.tax[ncbi.tax$Virus=="Trinidad/1FY2BA/2007","VirusOrder"] <- "Nidovirales"

ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusGenus"] <- "Betacoronavirus"
ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusFamily"] <- "Coronaviridae"
ncbi.tax[ncbi.tax$Virus=="Philippines/Diliman1525G2/2008","VirusOrder"] <- "Nidovirales"

# ### Merge

predict %<>% left_join(bind_rows(predictionary, ncbi.tax))

# How many don't have a genus?

predict %>% select(Virus, VirusGenus) %>% unique() %>% is.na %>% table()

# Final viral taxonomy step: merge up with the current NCBI species concepts where applicable

predict %<>% ungroup() # Because of weird rowwise

library(rentrez)
for(i in 1:nrow(predict)) {
  if(predict$VirusNCBIResolved[i]=="FALSE" & !is.na(predict$Accession[i])){
    acc <- word(predict$Accession[i], 1, sep = ", ")
    tax <- tryCatch(tax <- entrez_summary(db="nuccore", id = acc)$taxid, error = function(e) {NA})
    if(!is.na(tax)) {
      ncbi.high <- taxize::classification(tax, db = "ncbi")
      if(!is.na(ncbi.high[[1]][1])){
        if(!(any(str_detect(ncbi.high[[1]]$name[which(ncbi.high[[1]]$rank=='species')], c('unidentified', 'unclassified', 'sp.'))))) {
          predict$VirusNCBIResolved[i] <- TRUE 
          if("species" %in% ncbi.high[[1]]$rank) {predict$Virus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='species'), 'name']}
          if("genus" %in% ncbi.high[[1]]$rank) {predict$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
          if("family" %in% ncbi.high[[1]]$rank) {predict$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
          if("order" %in% ncbi.high[[1]]$rank) {predict$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
          if("class" %in% ncbi.high[[1]]$rank) {predict$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
          
          levels <- c("species", "genus", "family", "order", "class")
          u <- last(ncbi.high[[1]][ncbi.high[[1]]$rank %in% levels,'id'])
          predict$VirusTaxID[i] <- u
          
          print(ncbi.high)
        }
      }
    } 
  }
}







#" Predict digestion
#" 
#" Predict is also a flat file that we pull in and deal with ourselves 

# set up =======================================================================

library(magrittr)

if(!exists("jncbi")) {source(here::here("./Code/001_Julia functions.R"))}
if(!exists("vdict")) {source(here::here("./Code/001_TaxizeFunctions.R"))}

predict_raw <- readr::read_csv(here::here("../ept/PredictData (2).csv"))
rentrez::set_entrez_key("ec345b39079e565bdfa744c3ef0d4b03ba08")

# formatting predict ===========================================================

predict <- predict_raw %>% 
  # Drop long lats, number of records
  dplyr::select(`Sample Date`, 
         `Species Scientific Name Based on Field Morphology`, 
         Virus,
         `Genbank #`) %>% 
  # Some minor variable recodings 
  dplyr::rename(Date = `Sample Date`, 
                Host = `Species Scientific Name Based on Field Morphology`,
                Accession = `Genbank #`) %>%
  # group_by_at(vars(-Accession)) %>% 
  # summarize(Accession = str_c(Accession, collapse = ", ")) %>%
  unique() %>%  
  # The below step deals with flagged host names and "cf." names equally
  dplyr::mutate(HostFlagID = ifelse(
    (stringr::str_detect(Host, "\\*") | stringr::str_detect(Host,"cf.")),
                             TRUE,
                             FALSE)) %>%
  dplyr::mutate(Host = stringr::str_replace(Host, " \\*",""),
                Host = stringr::str_replace(Host, "cf. ","")) %>% 
  # Back up the virus names before doing anything else
  dplyr::mutate(VirusOriginal = Virus) %>% 
  dplyr::rename(VirusIntermediate = "Virus") %>% 
  # Remove "Strain of" from virus names
  dplyr::mutate(VirusIntermediate = 
                  stringr::str_replace(VirusIntermediate, "strain of ","")) %>%
  # Fix the date information into the right format
  dplyr::mutate(CollectionYear = lubridate::year(Date),
                CollectionMonth = lubridate::month(Date),
                CollectionDay = lubridate::day(Date),
                ReleaseYear = 2021,
                ReleaseMonth = 3,
                ReleaseDay = 9,
                Database = "PREDICT",
                DatabaseVersion = "March92021FlatFile",
                DetectionMethod = "PCR/Sequencing") %>%
  dplyr::select(-Date)

## typos =======================================================================

predict %<>% 
  dplyr::rowwise() %>% 
  dplyr::mutate(VirusIntermediate = 
                  strsplit(VirusIntermediate, split="\\(")[[1]][1]) 
predict %<>% 
  dplyr::rowwise() %>% 
  dplyr::mutate(VirusIntermediate = 
                  strsplit(VirusIntermediate, split=", subtype")[[1]][1])
predict %<>% 
  dplyr::rowwise() %>% 
  dplyr::mutate(VirusIntermediate = 
                  strsplit(VirusIntermediate, 
                           split=", partial subtype")[[1]][1]) 

predict %<>% 
  dplyr::mutate(VirusIntermediate = dplyr::recode(
    VirusIntermediate, 
    !!!c("Yellow Fever" = "Yellow fever virus", 
         "Dengue virus serotype 1" = "Dengue virus", 
         "Dengue virus serotype 2" = "Dengue virus", 
         "Dengue virus serotype 3" = "Dengue virus", 
         "Dengue virus serotype 4" = "Dengue virus", 
         "Influenza A" = "Influenza A virus",
         "Influenza B" = "Influenza B virus",
         "Human BK Polyomavirus" = "Human polyomavirus 1",
         "Porcine Parainfluenzavirus 1" = "Porcine parainfluenza virus",
         "Human Parainfluenzavirus 1" = "Human respirovirus 1",
         "Human Parainfluenzavirus 3" = "Human respirovirus 3",
         "Human Parainfluenzavirus 2" = "Human rubulavirus 2",
         "Human Parainfluenzavirus 4" = "Human rubulavirus 4",
         "Marburg Virus " = "Marburg marburgvirus",
         "MERS-like Coronovirus" = "Bat MERS-like coronavirus",
         "Monkey pox" = "Monkeypox virus",
         "Morogoro virus" = "Morogoro mammarenavirus",
         "SFVHpi" = "Simian foamy virus")))

## deal with taxonomy ===========================================================

# Now: the taxonomy. First: generate a vector of every PREDICT_ virus name 
predict_prefix <- predict %>% 
  dplyr::pull(VirusIntermediate) %>% 
  unique %>% stringr::str_subset("PREDICT_") %>%
  stringr::str_split("-") %>% 
  unlist() %>% 
  stringr::str_subset("PREDICT_") %>% 
  unique()

predict_tax <- data.frame(Virus = sort(predict_prefix), 
                          full = NA,
                          VirusGenus = NA, 
                          VirusFamily = NA, 
                          VirusOrder = NA)

predict_tax[1,2:5] <- c("Adeno-associated virus", "Dependoparvovirus", 
                        "Parvoviridae", "Piccovirales")
predict_tax[2,2:5] <- c("Adenovirus", NA, "Adenoviridae", "Rowavirales")
predict_tax[3,2:5] <- c("Arenavirus", NA, "Arenaviridae", "Bunyavirales")
predict_tax[4,2:5] <- c("Bocaparvovirus", "Bocaparvovirus", "Parvoviridae", 
                        "Picornavirales")
predict_tax[5,2:5] <- c("Coronavirus", NA, "Coronaviridae", "Nidovirales")
predict_tax[6,2:5] <- c("Enterovirus", "Enterovirus", "Picornaviridae", 
                        "Picornavirales")
predict_tax[7,2:5] <- c("Flavivirus", NA, "Flaviviridae", "Amarillovirales")
predict_tax[8,2:5] <- c("Hantavirus", NA, "Hantaviridae", "Bunyavirales")
predict_tax[9,2:5] <- c("Herpesvirus", NA, "Herpesviridae", "Herpesvirales")
predict_tax[10,2:5] <- c("Lentivirus", "Lentivirus", "Retroviridae", 
                         "Ortervirales")
predict_tax[11,2:5] <- c("Mamastrovirus", "Mamastrovirus", "Astroviridae", 
                         "Stellavirales")
predict_tax[12,2:5] <- c("Murine norovirus", "Norovirus", "Caliciviridae", 
                         "Picornavirales")
predict_tax[13,2:5] <- c("Orbivirus", "Orbivirus", "Reoviridae", "Reovirales")
predict_tax[14,2:5] <- c("Papillomavirus", NA, "Papillomaviridae", 
                         "Zurhausenvirales")
predict_tax[15,2:5] <- c("Picobirnavirus", NA, "Picobirnaviridae", 
                         "Durnavirales")
predict_tax[16,2:5] <- c("Phlebovirus", "Phleboviridae", "Phenuiviridae", 
                         "Bunyavirales")
predict_tax[17,2:5] <- c("Picornavirus", NA, "Picornaviridae", 
                         "Picornavirales")
predict_tax[18,2:5] <- c("Paramyxovirus", NA, "Paramyxoviridae", 
                         "Mononegavirales")
predict_tax[19,2:5] <- c("Posavirus", NA, NA, "Picornavirales")
predict_tax[20,2:5] <- c("Poxvirus", NA, "Poxviridae", "Chitovirales")
predict_tax[21,2:5] <- c("Polyomavirus", NA, "Polyomaviridae", "Sepolyvirales")
predict_tax[22,2:5] <- c("Rhabdovirus", NA, "Rhabdoviridae", "Mononegavirales")
predict_tax[23,2:5] <- c("Seadornavirus", "Seadornavirus", 
                         "Reoviridae", "Reovirales")

predict_names <- predict %>% 
  dplyr::pull(VirusIntermediate) %>% 
  unique()

predict_tax_big <- data.frame(FullName = 
                                (predict_names %>% 
                                   stringr::str_subset("PREDICT_")))

predictionary <- predict_tax_big %>% 
  tidyr::separate(
    col = FullName, 
    into = c("Virus","Number"), 
    sep = "-", 
    remove = FALSE) %>% 
  dplyr::left_join(predict_tax) %>% 
  dplyr::rename(Short = "Virus", Virus = "FullName") %>%
  dplyr::select(-c("Short", "Number", "full"))

# Check if literally any of these are NCBI resolved, which the vast majority are not

# for (i in 1:nrow(predictionary)) {
#   ncbi_num <- taxize::get_uid(predictionary$Virus[i])
#   ncbi_high <- taxize::classification(ncbi_num, db = "ncbi")
#   if(!is_na(ncbi_high[[1]][1])){
#     predictionary$VirusNCBIResolved[i] <- TRUE
#     predictionary$VirusTaxID[i] <- ncbi_num[[1]]
#   } else {
#     predictionary$VirusNCBIResolved[i] <- FALSE
#     predictionary$VirusTaxID[i] <- NA
#   }
#   print(i)
# }

predictionary$VirusNCBIResolved = FALSE
predictionary$VirusTaxID = NA
predictionary$VirusIntermediate = predictionary$Virus

## test run of the NCBI part of this ===========================================

ncbi_names <- predict %>% 
  dplyr::pull(VirusIntermediate) %>% 
  stringr::str_subset("PREDICT", negate = TRUE) %>% 
  unique() %>% 
  sort()

# now using the self-made functions here
ncbi_tax <- vdict(ncbi_names)

ncbi_tax %<>% dplyr::rename(VirusIntermediate = "VirusOriginal")
 
# Add some guardrails ==========================================================
for (i in 1:nrow(ncbi_tax)) {
  # "(?i)a"
  # Only pull ones that haven"t already been queried
  if(rlang::is_na(ncbi_tax$VirusOrder[i])){ 
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)cytomegalovirus")) {
      ncbi_tax$VirusGenus[i] <- "Cytomegalovirus"
      ncbi_tax$VirusFamily[i] <- "Herpesviridae"
      ncbi_tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)adenovirus")) {
      ncbi_tax$VirusFamily[i] <- "Adenoviridae"
      ncbi_tax$VirusOrder[i] <- "Rowavirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)alphacoronavirus")) {
      ncbi_tax$VirusGenus[i] <- "Alphacoronavirus"
      ncbi_tax$VirusFamily[i] <- "Coronaviridae"
      ncbi_tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)betacoronavirus")) {
      ncbi_tax$VirusGenus[i] <- "Betacoronavirus"
      ncbi_tax$VirusFamily[i] <- "Coronaviridae"
      ncbi_tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)coronavirus")) {
      ncbi_tax$VirusFamily[i] <- "Coronaviridae"
      ncbi_tax$VirusOrder[i] <- "Nidovirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)paramyxovirus")) {
      ncbi_tax$VirusFamily[i] <- "Paramyxoviridae"
      ncbi_tax$VirusOrder[i] <- "Mononegavirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)foamy")) {
      ncbi_tax$VirusGenus[i] <- "Spumavirus"
      ncbi_tax$VirusFamily[i] <- "Retroviridae"
      ncbi_tax$VirusOrder[i] <- "Ortervirales"
    }
    
    #"Hantaviridae", "Bunyavirales")
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)hantavirus")) {
      ncbi_tax$VirusFamily[i] <- "Hantaviridae"
      ncbi_tax$VirusOrder[i] <- "Bunyavirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)bocavirus")) {
      ncbi_tax$VirusGenus[i] <- "Bocaparvovirus"
      ncbi_tax$VirusFamily[i] <- "Parvoviridae"
      ncbi_tax$VirusOrder[i] <- "Picornavirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)lymphocryptovirus")) {
      ncbi_tax$VirusGenus[i] <- "Lymphocryptovirus"
      ncbi_tax$VirusFamily[i] <- "Herpesviridae"
      ncbi_tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)herpesvirus")) {
      ncbi_tax$VirusFamily[i] <- "Herpesviridae"
      ncbi_tax$VirusOrder[i] <- "Herpesvirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)astrovirus")) {
      ncbi_tax$VirusFamily[i] <- "Astroviridae"
      ncbi_tax$VirusOrder[i] <- "Stellavirales"
    }
    
    if(stringr::str_detect(ncbi_tax$Virus[i], "(?i)rhadinovirus")) {
      ncbi_tax$VirusGenus[i] <- "Rhadinovirus"
      ncbi_tax$VirusFamily[i] <- "Herpesviridae"
      ncbi_tax$VirusOrder[i] <- "Herpesvirales"
    }
  }
}

## manually deal with some naming ==============================================

ncbi_tax[ncbi_tax$Virus=="YN12103/CHN/2012","VirusFamily"] <- 
  "Paramyxoviridae"
ncbi_tax[ncbi_tax$Virus=="YN12103/CHN/2012","VirusOrder"] <- 
  "Mononegavirales"

ncbi_tax[ncbi_tax$Virus=="Trinidad/1FY2BA/2007","VirusGenus"] <- 
  "Alphacoronavirus"
ncbi_tax[ncbi_tax$Virus=="Trinidad/1FY2BA/2007","VirusFamily"] <- 
  "Coronaviridae"
ncbi_tax[ncbi_tax$Virus=="Trinidad/1FY2BA/2007","VirusOrder"] <- 
  "Nidovirales"

ncbi_tax[ncbi_tax$Virus=="Philippines/Diliman1525G2/2008","VirusGenus"] <- 
  "Betacoronavirus"
ncbi_tax[ncbi_tax$Virus=="Philippines/Diliman1525G2/2008","VirusFamily"] <- 
  "Coronaviridae"
ncbi_tax[ncbi_tax$Virus=="Philippines/Diliman1525G2/2008","VirusOrder"] <- 
  "Nidovirales"

# ### Merge

predict %<>% dplyr::left_join(dplyr::bind_rows(predictionary, ncbi_tax))

# How many don"t have a genus?
predict %>% 
  dplyr::select(Virus, VirusGenus) %>% 
  unique() %>% 
  dplyr::filter(rlang::is_na(VirusGenus)) %>% 
  nrow()

# merge up with the current NCBI species concepts where applicable =============

predict %<>% dplyr::ungroup() # Because of weird rowwise

library(rentrez)
for(i in 1:nrow(predict)) {
  if(predict$VirusNCBIResolved[i]=="FALSE" & !is.na(predict$Accession[i])){
    acc <- word(predict$Accession[i], 1, sep = ", ")
    tax <- tryCatch(tax <- entrez_summary(db="nuccore", id = acc)$taxid, error = function(e) {NA})
    if(!is.na(tax)) {
      ncbi.high <- taxize::classification(tax, db = "ncbi")
      if(!is.na(ncbi.high[[1]][1])){
        if(!(any(str_detect(ncbi.high[[1]]$name[which(ncbi.high[[1]]$rank=='species')], c('unidentified', 'unclassified', 'sp.'))))) {
          predict$VirusNCBIResolved[i] <- TRUE 
          if("species" %in% ncbi.high[[1]]$rank) {predict$Virus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='species'), 'name']}
          if("genus" %in% ncbi.high[[1]]$rank) {predict$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
          if("family" %in% ncbi.high[[1]]$rank) {predict$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
          if("order" %in% ncbi.high[[1]]$rank) {predict$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
          if("class" %in% ncbi.high[[1]]$rank) {predict$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
          
          levels <- c("species", "genus", "family", "order", "class")
          u <- last(ncbi.high[[1]][ncbi.high[[1]]$rank %in% levels,'id'])
          predict$VirusTaxID[i] <- u
          
          print(ncbi.high)
        }
      }
    } 
  }
}






for(i in 1:nrow(predict)) {
  
  if(predict$VirusNCBIResolved[i]=="FALSE" &
     !rlang::is_na(predict$Accession[i])){
    
    # accession value 
    acc <- stringr::word(predict$Accession[i], 1, sep = ", ")
    
    # try to get the taxonomic id 
    tax <- tryCatch(tax <- rentrez::entrez_summary(
      db="nuccore", id = acc)$taxid, error = function(e) {NA})
    
    # if it's not an NA, get a classification from NCBI
    if(!is.na(tax)) {
      
      # get the ncbi
      ncbi_high <- taxize::classification(tax, db = "ncbi")
      
      # if there are names continue 
      if(!is.na(ncbi_high[[1]][1])){
        
        # check if the species names are unresolved
        temp_name <- ncbi_high[[1]]$name[which(ncbi_high[[1]]$rank=="species")]
        if(!(any(stringr::str_detect(temp_name, 
                                c("unidentified", "unclassified", "sp."))))) {
          
          # this is putting in the resolved values 
          predict$VirusNCBIResolved[i] <- TRUE 
          if("species" %in% ncbi_high[[1]]$rank) {predict$Virus[i] <- 
            ncbi_high[[1]][which(ncbi_high[[1]]$rank=="species"), "name"]}
          if("genus" %in% ncbi_high[[1]]$rank) {predict$VirusGenus[i] <- 
            ncbi_high[[1]][which(ncbi_high[[1]]$rank=="genus"), "name"]}
          if("family" %in% ncbi_high[[1]]$rank) {predict$VirusFamily[i] <- 
            ncbi_high[[1]][which(ncbi_high[[1]]$rank=="family"), "name"]}
          if("order" %in% ncbi_high[[1]]$rank) {predict$VirusOrder[i] <- 
            ncbi_high[[1]][which(ncbi_high[[1]]$rank=="order"), "name"]}
          if("class" %in% ncbi_high[[1]]$rank) {predict$VirusClass[i] <- 
            ncbi_high[[1]][which(ncbi_high[[1]]$rank=="class"), "name"]}
          
          levels <- c("species", "genus", "family", "order", "class")
          u <- dplyr::last(ncbi_high[[1]][ncbi_high[[1]]$rank %in% levels,"id"])
          predict$VirusTaxID[i] <- u
  
          print(ncbi_high)
        }
      }
    } 
  }
}

## host taxonomy ===============================================================

predict %<>% dplyr::mutate(
  Host = dplyr::recode(
    Host, 
    !!!c("Hipposideros larvatus/grandis species complex" = "Hipposideros sp.")))

hosts <- predict %>% 
  dplyr::pull(Host) %>% 
  unique()

host_tax <- hdict(hosts)

predict %<>%
  dplyr::rename(HostOriginal = "Host") %>% 
  dplyr::left_join(host_tax)

# just a manual look 
predict %>% filter(is_na(Host)) %>% pull(HostOriginal) %>% unique()

predict %<>% select(-VirusIntermediate)

# write out intermediate =======================================================
readr::write_csv(
  predict, 
  here::here("Intermediate/Unformatted/PREDICTMainUnformatted.csv"))
