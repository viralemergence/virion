
if(!exists('vdict')) {source('Code/001_TaxizeFunctions.R')}

library(tidyverse)
library(magrittr)
library(lubridate)
library(naniar)
library(vroom)

predict.1 <- read_csv("~/Github/ept/PredictData (2).csv")
predict.2 <- vroom("~/Github/ept/PREDICT_PCR_Tests.csv.gz")

predict.1 %<>% # select(`Species Scientific Name Based on Field Morphology`, 
                      #Virus) %>%
  rename(Host = "Species Scientific Name Based on Field Morphology") %>%
  distinct() %>%
  mutate(Host = str_replace(Host, " \\*", "")) %>%
  mutate(Host = str_replace(Host, " cf.", "")) %>%
  mutate(Virus = str_replace(Virus, "strain of ", "")) %>%
  mutate(Host = str_to_lower(Host), Virus = str_to_lower(Virus))

predict.2 %<>% # select(ScientificName, Virus) %>%
  rename(Host = ScientificName) %>%
  filter(!is.na(Virus)) %>% 
  mutate(Host = str_replace(Host, " cf.", "")) %>%
  distinct() %>%
  mutate(Host = str_to_lower(Host), Virus = str_to_lower(Virus))

# Only grab the 50 or so records the original data are missing
predict.raw <- anti_join(predict.2, predict.1, by = c("Host", "Virus"))

# A couple sanity checks
# table(predict.raw$TestResult)
# table(predict.raw$TestType)

predict.raw %<>% select(Host,
                        Virus,
                        PREDICT_SampleID,
                        GenbankAccessionNumber) %>%
  
  # Rename the columns
  rename(NCBIAccession = "GenbankAccessionNumber") %>%
  
  # Collapse the Genbank info
  group_by_at(vars(-NCBIAccession)) %>% 
  summarize(NCBIAccession = str_c(NCBIAccession, collapse = ", ")) %>%
  unique() %>% 
  
  # Clean up the host info
  # First, remove fuzzy names
  mutate(HostFlagID = str_detect(Host, "cf."),
         Host = str_replace(Host, " cf.", "")) %>% 
  mutate(Virus = word(Virus, 1, sep = "\\(")) 

# Let's do some higher classifications to this 

twowords <- function(x) {
  q = word(x, 1:2, sep=" ")
  if(is.na(q[1])) {return(x)} else {return(str_c(na.omit(q), collapse = " "))}
}
host.tax <- hdict(predict.raw$Host %>% unique() %>% sapply(., twowords))
predict.raw %>% rename(HostOriginal = "Host") %>% 
  left_join(host.tax) -> predict.raw

# Now the viruses

# First some cleaning

predict.raw %<>% mutate(Virus = recode(Virus, !!!c("influenza a" = "influenza a virus",
                                                   "alpha coronavirus nl63" = "coronavirus nl63"))) 

predict.raw %>% pull(Virus) %>% unique() %>% sort() -> ncbi.names

ncbi.tax <- vdict(ncbi.names)

ncbi.tax[str_detect(ncbi.tax$Virus, "predict_cov"),"VirusFamily"] <- "coronaviridae"
ncbi.tax[str_detect(ncbi.tax$Virus, "predict_cov"),"VirusOrder"] <- "nidovirales"

ncbi.tax[str_detect(ncbi.tax$Virus, "predict_pmv"),"VirusFamily"] <-  "paramyxoviridae"
ncbi.tax[str_detect(ncbi.tax$Virus, "predict_pmv"),"VirusOrder"] <- "mononegavirales"

ncbi.tax[ncbi.tax$Virus=="philippines/diliman1525g2/2008","VirusGenus"] <- "betacoronavirus"
ncbi.tax[ncbi.tax$Virus=="philippines/diliman1525g2/2008","VirusFamily"] <- "coronaviridae"
ncbi.tax[ncbi.tax$Virus=="philippines/diliman1525g2/2008","VirusOrder"] <- "nidovirales"

ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky66/65/63/60","VirusGenus"] <- "alphacoronavirus"
ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky66/65/63/60","VirusFamily"] <- "coronaviridae"
ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky66/65/63/60","VirusOrder"] <- "nidovirales"

ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky83/59/58","VirusGenus"] <- "alphacoronavirus"
ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky83/59/58","VirusFamily"] <- "coronaviridae"
ncbi.tax[ncbi.tax$Virus=="kenya bat coronavirus/btky83/59/58","VirusOrder"] <- "nidovirales"

if(ncbi.tax[ncbi.tax$VirusOriginal=="predict_pmv-95", "Virus"]=="Atractiella rhizophila") {
  ncbi.tax[ncbi.tax$VirusOriginal=="predict_pmv-95",] <- c("predict_pmv-95", NA, FALSE, "predict_pmv-95", NA, "paramyxoviridae", "mononegavirales", "monjiviricetes")
}

predict.raw %<>% rename(VirusOriginal = "Virus") %>% 
  left_join(ncbi.tax, by = "VirusOriginal")

# Finally, grab the date info

meta <- read_csv("~/Github/ept/PREDICT_Animals_Sampled.csv")

meta %<>%
  rename(PREDICT_SampleID = PREDICT_IndividualID) %>%
  select(PREDICT_SampleID, SampleDate) %>%
  mutate(CollectionYear = year(SampleDate),
         CollectionMonth = month(SampleDate),
         CollectionDay = day(SampleDate)) %>%
  select(-SampleDate) 

predict.raw %<>% left_join(meta)%>%
  select(-PREDICT_SampleID)

write_csv(predict.raw, "Intermediate/Unformatted/PREDICTPCRUnformatted.csv")
