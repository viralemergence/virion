
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
  
  
  group_by_at(vars(-Accession)) %>% 
  summarize(Accession = str_c(Accession, collapse = ", ")) %>%
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
predict.tax[7,2:5] <- c("Flavivirus", "Flavivirus", "Flaviviridae", "Amarillovirales")
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

##################################################################################################
##################################################################################################
##################################################################################################
##################################################################################################
##################################################################################################
##################################################################################################
##################################################################################################
##################################################################################################

# Now, the host taxonomy 

predict %<>% mutate(Host = recode(Host, !!!c("Hipposideros larvatus/grandis species complex" = "Hipposideros sp.")))

predict %>% pull(Host) %>% unique() -> hosts

host.tax <- hdict(hosts)

predict %>% rename(HostOriginal = "Host") %>% 
  left_join(host.tax) -> predict

predict %>% filter(is.na(Host)) %>% pull(HostOriginal) %>% unique()

predict %<>% select(-VirusIntermediate)

write_csv(predict, "Intermediate/Unformatted/PREDICTMainUnformatted.csv")
