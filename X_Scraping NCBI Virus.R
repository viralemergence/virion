
# Scraping NCBI Virus ####

install.packages("rvest")

library(rvest); library(tidyverse)

simple <- read_html("https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide.html")
simple <- read_html("https://www.billboard.com/charts/hot-100")

simple <- read_html("https://www.research.net/r/MKF328G?a=virus-variation-dj&from=https%3A%2F%2Fwww.ncbi.nlm.nih.gov%2Flabs%2Fvirus%2Fvssi%2F%23%2Fvirus%3FSeqType_s%3DNucleotide&p=&s=A6F78B89F58B2C23_38940SID")

simple <- "https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus" %>% 
  read_html

"https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus" %>% 
  read_html()

simple %>% html_node("body") %>% 
  html_text %>% str_detect("DataTables")
# html_children()
xml2::xml_find_all("Content")

simple %>% html_node("body") %>% 
  html_node("main") %>% 
  html_node("div") %>% 
  html_node("div") %>% 
  html_node("section")# %>% 
  html_node("uswds-ncbi-app-root") %>% 

"/html/body/main/div/div/section/uswds-ncbi-app-root/uswds-ncbi-app-report/div/div[2]" %>% 
  str_split("/") %>% unlist %>% 
  extract(3:11) -> Roots

simple %>% 
  html_node("body") %>% 
  html_node("main")

list(simple, Roots[1]) %>% 
  reduce(html_node)
