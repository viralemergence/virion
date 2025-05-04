# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.
source("Code/packages.R")

# Run the R scripts in the R/ folder with your custom functions:
targets::tar_source()

initial_targets <- tar_plan(
  tar_target(template, generate_template()),
  tar_target(temp_csv, readr::write_csv(template, here::here("Intermediate/Template.csv"))),
  tar_target(virus.test, c(
    "Adeno-associated virus - 3",
    "Adeno-associated virus 3B",
    "Adenovirus predict_adv-20",
    "A bad name"
  )),
  tar_target(host.test, c(
    "Equus caballus ferus",
    "Homo sapiens",
    "Hongus bongus",
    "Chiroptera",
    "Mus",
    "Bacillus anthracis"
  ))
)


# from 02_0_Format Clover -----
clover_targets <- tar_plan(
  tar_target(clo_path, get_clover()), # clover csv from github
  tar_target(clo, readr::read_csv(clo_path)), # clover dataframe
  # tar_target(clover_template, generate_template() ), # clover template - used as a data standard, same as temp
  tar_target(clo_formatted, format_clover(clo, template)),
  tar_target(clo_formatted_path, readr::write_csv(clo_formatted, here::here("./Intermediate/Formatted/CLOVERFormatted.csv")))
)


# download genbank ----

genbank_download_targets <- tar_plan(
  tar_target(genbank_path, get_genbank()),
  tar_target(seq, read_genbank(genbank_path)),
  tar_target(write_seq, vroom::vroom_write(seq, here::here("./Source/sequences.csv")))
)

# Digest genbank ----

genbank_digest_targets <- tar_plan(
  tar_target(gb, tibble::as_tibble(seq)), # this actually takes awhile
  tar_target(host_vec, gb |>
    dplyr::pull(Host) %>%
    unique() %>%
    sort()),

  # clean up hosts
  tar_target(host_table, jhdict(host_vec)),
  tar_target(
    host_table_path, readr::write_csv(host_table, here::here("./Intermediate/GBHostTax.csv"))),
    tar_target(gb_hosts_clean, gb_clean_hosts(gb, host_table)),

    # clean up viruses
    tar_target(virus_vec, gb %>%
      dplyr::pull(Species) %>%
      unique() %>%
      sort()),
    tar_target(virus_table, jvdict(virus_vec)),
    tar_target(virus_table_path, readr::write_csv(virus_table, here::here("./Intermediate/GBVirusTax.csv"))),
    tar_target(gb_virus_clean, gb_clean_viruses(gb_hosts_clean, virus_table)),
    tar_target(gb_virus_clean_path, vroom::vroom_write(gb, here::here(
      "./Intermediate/Unformatted/GenBankUnformatted.csv.gz"
    )))
  )

# 
# # Format Genbank -----
# 
# format_genbank_targets <- tar_plan(
#   tar_target(gb_formatted, format_genbank(gb_virus_clean, temp)),
#   tar_target(gb_formatted_path, vroom::vroom_write(gb_formatted, "Intermediate/Formatted/GenbankFormatted.csv.gz"))
# )
# 
# 
# # digest predict ----
# # format predict ----
# # digest predict  pcr ----
# # format predict  pcr ----
# # merge predict and add genera ----
# # merge clean files ----
# # high level checks ----
# # dissolve virion ----
# 
# 
# 
 list(
   initial_targets,
   clover_targets,
   genbank_download_targets,
   genbank_digest_targets
#   format_genbank_targets
 )
