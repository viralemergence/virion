
# 01_Setup ####

rm(list = ls())

library(tidyverse); library(taxize); library(magrittr); library(fs); library(zip)

# setwd("~/Github/virion")
# setwd(here::here())

source("Code/002_TaxiseCleaner.R")

# Read in host data ####

# Downloaded from NCBI Virus on 19th January 2021 by GFA
# https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?VirusLineage_ss=Viruses,%20taxid:10239&SeqType_s=Nucleotide
# Includes the following selected columns:
# Accession, Release Date, Species, Host, Collection Date

if(!file.exists("Source/sequences.csv")){
  
  unzip("Source/GenBank.zip", exdir = 'Source')
  
}

gb <- data.table::fread("Source/sequences.csv") %>% 
  as_tibble

gb %>% 
  rename(Release_Date = Release_Date) %>% 
  mutate_at("Release_Date", ~.x %>% # Modifying date column to make sense
              str_split("T") %>% # Splitting at this midpoint
              map_chr(1) %>% # Taking the first component 
              lubridate::ymd() # Coding as YMD (shouldn't throw errors)
  ) -> gb

if(0){ # Removing GenBank entries with only one word names?
  
  gb %>% mutate(NWords = str_count(Host, " ")) %>% 
    filter(NWords>1) -> gb
  
}

# Add import download step? ####
# https://cran.r-project.org/web/packages/biomartr/biomartr.pdf
# Or https://ropensci.org/blog/2020/11/10/coronaviruses-and-hosts/
# Or https://rdrr.io/cran/insect/man/searchGB.html


# Taxizing ####

hosts_vec <- unique(na.omit(gb$Host))

host.dictionary <- readRDS("Intermediate/HostDictionary.RDS")

NotInDictionary <- hosts_vec %>% # Identify host names not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

if(0){ # Not running
  if(length(NotInDictionary)>0){ # Expanding the dictionary
    
    synonyms <- NotInDictionary %>% # Go through these names and Taxize them 
      lapply(findSyns3)
    
    # synonyms %>% 
    #   seq_along %>% 
    #   map(~ifelse(is.null(synonyms[[.x]]), 
    #               data.frame(Original = NotInDictionary[.x]),
    #               synonyms[[.x]])) ->
    #   synonyms
    
    synonyms %>% bind_rows() %>% # Attach those taxized names to the dictionary
      bind_rows(host.dictionary) -> 
      host.dictionary
    
    host.dictionary %<>% arrange(Original) # arrange by name
    
    write_rds(host.dictionary, "Intermediate/HostDictionary.RDS")
    
  }
}

StillNotInDictionary <- hosts_vec %>% # Identify host names STILL not in the dictionary
  setdiff(host.dictionary$Original) %>%
  sort

data.frame(Original = StillNotInDictionary) %>% 
  bind_rows(host.dictionary, .) ->
  host.dictionary

# Double check if the dictionary needs expansion ####

# if(1){ # Set to not run

dict2 <- data.frame(Original = hosts_vec)

dict2 %>% 
  as_tibble %>%
  left_join(host.dictionary) -> dict2

for (i in 1:nrow(dict2)) {
  if(dict2$Original[i] %in% dict2$Synonyms) {
    dict2$Accepted_name[i] <- dict2$Accepted_name[which(dict2$Synonyms == dict2$Original[i])]
    print(i)
  }
}

host.dictionary <- dict2

# }

# Making the cleaned dataset ####

ToGroup <- host.dictionary %>% names %>% setdiff(c("Submitted", "Synonyms"))

host.dictionary %>% 
  group_by_at(ToGroup) %>% #names
  summarise_at(c("Submitted", "Synonyms"), list) %>% # Adding the Taxize information to the data frame
  # dplyr::select(-c(Submitted, Synonyms)) %>% 
  # unique %>% #nrow %>% 
  left_join(gb, ., by = c('Host' = 'Original')) ->
  gb2 # <- left_join(gb, host.dictionary, by = c('Host' = 'Original'))

gb2 %>% filter(Selected_class %in% c("Mammalia", # Selecting host taxa
                                     "Aves",
                                     "Reptilia",
                                     "Amphibia",
                                     "Chondrichthyes",
                                     "Elasmobranchii")) %>%
  
  select(Accession, 
         Virus = Species, #Genus, # Selecting and renaming columns
         Host = Accepted_name, 
         Selected_family, Selected_order, Selected_class,
         Release_Date, 
         Collection_Date) %>% 
  unique() -> gb2

# Renaming to match other databases 
gb2 %>% 
  rename_all(~.x %>% str_replace_all("Selected_", "Host") %>% 
               str_replace_all(c("class" = "Class", "order" = "Order", "family" = "Family"))) ->
  
  gb2

if(1){
  
  gb2 %>% # Selecting just the first identification of a given association
    arrange(Host, Virus, Release_Date) %>% 
    group_by(Host, Virus) %>% 
    # dplyr::count() %>% pull(n) %>% table
    filter(Release_Date == min(Release_Date)) %>% 
    mutate(N = 1:n()) %>% filter(N == 1) %>% 
    dplyr::select(-N) -> gb2
  
}

# Add viral tax
# Greg rewrite this step***

gb2.viruses.tax.df <- data.table::fread('GenBank-VirusesTaxized.csv')

gb2  <- left_join(gb2, gb2.viruses.tax.df)
 
# Check later if adding those columns breaks anything :grimace:

data.table::fwrite(gb2, 'Intermediate/GenBank-Taxized.csv')

file_delete("Intermediate/GBTaxized.zip")

zip(zipfile = 'Intermediate/GBTaxized.zip', 
    files = 'Intermediate/GenBank-Taxized.csv') 
