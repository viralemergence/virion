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

# If you can run julia commands in terminal but not R, it may be a PATH issue
# Depending on how you installed Julia, you may have to add homebrew to your PATH
# in R
# 
# Get your terminal PATH - in terminal run
# echo $PATH
# use str_split to compare the ":" separated items in PATH
# 
# r_path <- Sys.getenv("PATH")
# hb_path <- "/opt/homebrew/bin:/opt/homebrew/sbin"
# new_path <- paste0(hb_path,r_path,collapes = ":")
# Sys.setenv(PATH=new_path)

system2("sys_deps/julia_deps.sh")


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
    host_table_path, readr::write_csv(host_table, here::here("./Intermediate/GBHostTax.csv"))
    ),
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


# Format Genbank -----

format_genbank_targets <- tar_plan(
  tar_target(gb_formatted, format_genbank(gb_virus_clean, template)),
  tar_target(gb_formatted_path, vroom::vroom_write(gb_formatted, "Intermediate/Formatted/GenbankFormatted.csv.gz"))
)


# run: |
#   Rscript -e 'source("Code/05_Dissolve VIRION.R")'


# # digest predict ----
# # format predict ----
# # digest predict  pcr ----
# # format predict  pcr ----
# # merge predict and add genera ----
# # merge clean files ----
merge_clean_files_targets <- tar_plan(
  #gb_formatted
  #clo_formatted
  predict_all_formatted = vroom(here::here("./Intermediate/Formatted/PREDICTAllFormatted.csv"),
                                           col_type = cols(PMID = col_double(),
                                                           PublicationYear = col_double()
                                                           )
                                ),
  virion_unprocessed = dplyr::bind_rows(clo_formatted, predict_all_formatted, gb_formatted),
  virion_unprocessed_path = vroom::vroom_write(virion_unprocessed, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz")
)
# # high level checks ----
high_level_check_targets <- tar_plan(
  ### maybe convert to data.table - we will see
  tar_target(virion_no_phage, remove_phage(virion_unprocessed)),
  ictv = readr::read_csv("Source/ICTV Master Species List 2019.v1.csv"),
  tar_target(virion_ictv_ratified, ratify_virus(virion_no_phage,ictv)),
  tar_target(virion_clover_hosts, clean_clover_hosts(virion_ictv_ratified)),
  tar_target(virion_unique, deduplicate_virion(virion_clover_hosts)),
  tar_target(virion_unique_path, vroom::vroom_write(virion_unique, "Virion/Virion.csv.gz"))
)
# # dissolve virion ----
dissovle_virion_targets <- tar_plan(
  tar_target(virion_has_taxa_id, virion_unique_path %>%  
             filter(!is.na(HostTaxID),
                    !is.na(VirusTaxID))
             ),
  tar_target(host_tax,virion_has_taxa_id %>%
               select(HostTaxID, Host, HostGenus, HostFamily, HostOrder, HostClass, HostNCBIResolved) %>% 
               distinct() %>% 
               arrange(Host)
               ),
  tar_target(virus_tax, 
             virion_has_taxa_id %>% 
               select(VirusTaxID, Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass, VirusNCBIResolved, ICTVRatified) %>% 
               arrange(Virus) %>%
               unique()
             ),
  tar_target(host_tax_path, write_csv(host_tax, "./Virion/TaxonomyHost.csv")),
  tar_target(virus_tax_path, write_csv(virus_tax, "./Virion/TaxonomyVirus.csv")),
  tar_target(virion_reduced_tax, 
             virion_has_taxa_id %>% 
               select(-c(Host, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass,
                         Virus, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass, ICTVRatified)) %>% 
               mutate(AssocID = row_number()) %>%
               relocate(AssocID, .before = everything())#
              ),
  tar_target(provenance, 
             virion_reduced_tax %>%
               select(AssocID, 
                      HostOriginal, VirusOriginal, 
                      Database, DatabaseVersion,
                      ReferenceText, 
                      PMID)
             ),
  tar_target(detection,
             virion_reduced_tax %>% 
               select(AssocID,
                      DetectionMethod, DetectionOriginal, 
                      HostFlagID,
                      NCBIAccession)
             ),
  tar_target(temporal, 
             virion_reduced_tax %>% 
               select(AssocID, 
                      PublicationYear, 
                      ReleaseYear, ReleaseMonth, ReleaseDay,
                      CollectionYear, CollectionMonth, CollectionDay)
             ),
  ### write csvs
  provenance_path =  vroom_write(provenance, "./Virion/Provenance.csv.gz"),
  detection_path = vroom_write(detection, "./Virion/Detection.csv.gz"),
  temporal_path = vroom_write(temporal, "./Virion/Temporal.csv.gz"),
  tar_target(virion_edge_list, get_virion_edge_list(virion_reduced_tax)),
  tar_target(virion_edge_list_path,write_csv(virion_edge_list, "./Virion/Edgelist.csv") )
)

# 
 list(
   initial_targets,
   clover_targets,
   genbank_download_targets,
   genbank_digest_targets,
   format_genbank_targets,
   merge_clean_files_targets,
   high_level_check_targets,
   dissovle_virion_targets
 )
