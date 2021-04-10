
library(tidyverse); library(magrittr)

clo <- read_csv("Intermediate/CLOVERT_ReconciledAssociations_Taxize.csv")

# Hosts first 

clo %>% pull(HostHarmonised_Taxize) %>% unique() -> host.list

host.tax <- jncbi(host.list, type = 'host')

host.tax %>% rename(Host_Intermediate = "Name",
                    Host = "match") %>% 
  filter(matched=='TRUE') %>%
  select(-matched) %>%
  mutate(HostFamily = NA,
         HostOrder = NA,
         HostClass = NA) -> host.dictionary

for (i in 1:nrow(host.dictionary)) {
  ncbi.num <- taxize::get_uid(host.dictionary$Host[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("family" %in% ncbi.high[[1]]$rank) {host.dictionary$HostFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {host.dictionary$HostOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {host.dictionary$HostClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
  }
}

write_csv(host.dictionary, 'Intermediate/clovert_host_taxonomy.csv')

# Need to make a script that's specifically for viruses

clo %>% pull(Pathogen_Harm2) %>% str_squish() %>% unique() -> path.list

for (i in 1:14) { 
path.tax.i <- jncbi(path.list[(1+500*(i-1)):min(length(path.list), 500 + 500*(i-1))], type = 'pathogen')
if(i == 1) {path.tax <- path.tax.i} else {path.tax <- bind_rows(path.tax, path.tax.i)}
}

path.tax %>% rename(Pathogen_Intermediate = "Name",
                    Pathogen = "match") %>% 
  filter(matched=='TRUE') %>%
  select(-matched) %>%
  mutate(PathogenGenus = NA,
         PathogenFamily = NA,
         PathogenOrder = NA,
         PathogenClass = NA) -> path.dictionary

for (i in 1:nrow(path.dictionary)) {
  ncbi.num <- taxize::get_uid(path.dictionary$Pathogen[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {path.dictionary$PathogenGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {path.dictionary$PathogenFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {path.dictionary$PathogenOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {path.dictionary$PathogenClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
  }
}

write_csv(path.dictionary, 'Intermediate/clovert_path_taxonomy.csv')