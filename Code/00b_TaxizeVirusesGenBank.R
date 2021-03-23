
gb2 <- data.table::fread('Intermediate/GenBank-Taxized.csv')

# New code to get those sweet, sweet virus higher taxonomies

gb2 %>% pull(Virus) %>% unique() %>% sort() -> gb2.viruses

gb2.viruses.tax.df <- data.frame(Virus = gb2.viruses, 
                                 VirusGenus = NA,
                                 VirusFamily = NA,
                                 VirusOrder = NA, 
                                 VirusClass = NA)

for (i in 1:nrow(gb2.viruses.tax.df)) {
  ncbi.num <- taxize::get_uid(gb2.viruses.tax.df$Virus[i])
  ncbi.high <- taxize::classification(ncbi.num, db = "ncbi")
  if(!is.na(ncbi.high[[1]][1])){
    if("genus" %in% ncbi.high[[1]]$rank) {gb2.viruses.tax.df$VirusGenus[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='genus'), 'name']}
    if("family" %in% ncbi.high[[1]]$rank) {gb2.viruses.tax.df$VirusFamily[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='family'), 'name']}
    if("order" %in% ncbi.high[[1]]$rank) {gb2.viruses.tax.df$VirusOrder[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='order'), 'name']}
    if("class" %in% ncbi.high[[1]]$rank) {gb2.viruses.tax.df$VirusClass[i] <- ncbi.high[[1]][which(ncbi.high[[1]]$rank=='class'), 'name']}
  }
}

data.table::fwrite(gb2.viruses.tax.df, 'GenBank-VirusesTaxized.csv')
