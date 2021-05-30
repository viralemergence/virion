
library(tidyverse); library(magrittr)

clo <- read_csv("Intermediate/CLOVERT_ReconciledAssociations_Taxize.csv")

# Viruses first

clo %>% pull(Virus) %>% unique() -> path.list

path.tax <- jncbi(path.list, type = 'virus') # Generate the NCBI taxonomy

path.tax %<>% filter(matched==TRUE) # Remove the fuzzy matches

path.tax %>% filter(!(Name == match)) # No names to update

clo %>% select(Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass) %>%
  unique() -> virus.all

virus.all %>% pull(Virus) %>% table -> conflict.check
conflict.check[conflict.check > 1]

# Manual fix - only one
View(virus.all %>% filter(Virus == 'Pestivirus A'))
clo[clo$Virus=='Pestivirus A',]$VirusGenus <- 'Pestivirus'

# Remake the viral taxonomy with that fixed
clo %>% select(Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass) %>%
  unique() -> virus.all

virus.na <- virus.all[!complete.cases(virus.all),]
virus.na -> virus.na.raw

for (i in 1:nrow(virus.na)) {
  ncbi.num <- taxize::get_uid(virus.na$Virus[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {virus.na$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {virus.na$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {virus.na$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {virus.na$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
  }
}

identical(virus.na, virus.na.raw) # This means all the higher taxonomy is in there that could possibly be in there 

#

clo %>% pull(Host) %>% unique() -> host.list

host.tax <- jncbi(host.list, type = 'host')

host.tax %<>% filter(matched==TRUE) # Remove the fuzzy matches

host.tax %>% filter(!(Name == match)) # No names to update

clo %>% select(Host, HostFamily, HostOrder, HostClass) %>%
  unique() -> host.all

host.all %>% pull(Host) %>% table -> conflict.check
conflict.check[conflict.check > 1]

# Manual fix - only one
View(host.all %>% filter(Host == 'Miniopterus schreibersii'))
clo[clo$Host=='Miniopterus schreibersii',]$HostFamily <- 'Vespertilionidae'

# Remake the viral taxonomy with that fixed
clo %>% select(Host, HostFamily, HostOrder, HostClass) %>%
  unique() -> host.all

host.na <- host.all[!complete.cases(host.all),]
nrow(host.na) # There are none missing higher taxonomy at all. Rory how is this possible my man