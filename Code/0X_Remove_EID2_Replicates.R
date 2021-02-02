
# 0X_Remove EID2 duplicates because of unique years 

library(magrittr)
library(tidyverse)

virion <- read_csv("Virion/Virion-Master.csv")

virion %>% 
  filter(Database == 'EID2') -> eid2

eid2 %>%
  group_by(Host, Virus) %>%
  slice_min(Release_Year, n = 1) ->
  eid2.good

anti_join(eid2, eid2.good) -> eid2.bad

virion %<>% anti_join(eid2.bad)

write_csv(virion, "Virion/Virion-Master.csv")
