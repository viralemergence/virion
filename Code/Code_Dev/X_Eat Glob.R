# install.packages('rglobi')

library(rglobi)
library(tidyverse)

# By default, the amount of results are limited. If you'd like to retrieve all results, you can used pagination. For instance, to retrieve parasitic interactions using pagination, you can use:
# 
# 
# ```r
# otherkeys = list("limit"=10, "skip"=0)
# first_page_of_ten <- get_interactions_by_type(interactiontype = c("hasParasite"), otherkeys = otherkeys)
# otherkeys = list("limit"=10, "skip"=10)
# second_page_of_ten <- get_interactions_by_type(interactiontype = c("hasParasite"), otherkeys = otherkeys)
# ```
# 
# To exhaust all available interactions, you can keep paging results until the size of the page is less than the limit (e.g., ```nrows(interactions) < limit```).

j = 0
k = 1 

while(k > 0) {
  
page <- get_interactions_by_taxa(sourcetaxon = 'Virus',
                                 targettaxon = 'Vertebrata',
                                 otherkeys = list("limit" = 1000, "skip" = 1000*j))
k = nrow(page)

if(j == 0) {all <- page} else {
  all <- rbind(page,all)
}

print(j)
j = (j + 1)

}

j = 0
k = 1 

while(k > 0) {
  
  page <- get_interactions_by_taxa(sourcetaxon = 'Viruses',
                                   targettaxon = 'Vertebrata',
                                   otherkeys = list("limit" = 1000, "skip" = 1000*j))
  k = nrow(page)
  
  all <- rbind(page,all)
  
  print(j)
  j = (j + 1)
  
}

all %>% unique() -> all 

write_csv(all, 'Source/GLOBI-raw.csv')
