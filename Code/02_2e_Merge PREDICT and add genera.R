
p1 <- read_csv("Intermediate/Formatted/PREDICTMainFormatted.csv")
p2 <- read_csv("Intermediate/Formatted/PREDICTPCRFormatted.csv")

predict <- bind_rows(p1, p2)

spill <- read_csv("~/Github/ept/SpilloverRankings.csv")
spill %<>% mutate(`Virus Species` = str_replace(`Virus Species`, "PREDICT ", "PREDICT_")) %>%
  mutate(`Virus Species` = str_replace(`Virus Species`, "Adeno-Associated Virus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Adenovirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Arenavirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Coronavirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Lentivirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Mamastrovirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Mammastrovirus PREDICT", "PREDICT"), # There's one typo :)
         `Virus Species` = str_replace(`Virus Species`, "Paramyxovirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Picobirnavirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Polyomaovirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Posavirus PREDICT", "PREDICT"),
         `Virus Species` = str_replace(`Virus Species`, "Poxvirus PREDICT", "PREDICT")) %>%
  select(`Virus Species`, `Virus Genus`) %>%
  filter(!(`Virus Genus`=="Unassigned"))

for (i in 1:nrow(spill)){
  if(nrow(predict[str_to_lower(str_replace(predict$VirusOriginal,"strain of ","")) == str_to_lower(spill$`Virus Species`[i]),'VirusGenus'])>0){ 
    predict[str_to_lower(str_replace(predict$VirusOriginal,"strain of ","")) == str_to_lower(spill$`Virus Species`[i]),'VirusGenus'] <- str_to_lower(spill[spill$`Virus Species`==spill$`Virus Species`[i],'Virus Genus'])
  }
}

predict$VirusGenus[predict$VirusOriginal=="strain of Eidolon bat coronavirus"] <- "betacoronavirus"
predict$VirusGenus[predict$VirusOriginal=="strain of Bat coronavirus Hipposideros"] <- "betacoronavirus" # this can be reconstructed from the predict.2 object (the PCR Tests) but NOT the HealthMap copy

write_csv(predict, "Intermediate/Formatted/PREDICTAllFormatted.csv")