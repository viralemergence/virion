# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.
source("packages.R")

# set tar options

tar_option_set(format = "qs")

# Run the R scripts in the R/ folder with your custom functions:
targets::tar_source()

# If you can run julia commands in terminal but not R, it may be a PATH issue
# Depending on how you installed Julia, you may have to add the julia binary 
# location to your PATH in R

#set path ----
# when running locally
homebrew_path <- "/opt/homebrew/bin:/opt/homebrew/sbin"
# when running on gh actions
# github_actions_path <- "/__t/juliaup/1.17.4/x64"
# when running with act
# act_path <- "/opt/hostedtoolcache/juliaup/1.17.4/x64"
update_path(items_to_add = homebrew_path)

# source julia packages
source_julia_deps()

initial_targets <- tar_plan(
  tar_target(current_msl_path, download_current_msl(url = "https://ictv.global/msl/current"),
             format = "file",
             cue = tar_cue(mode = "always")),
  tar_target(ictv_msl_version, get_ictv_version(current_msl_path = current_msl_path)),
  tar_target(ictv, read_current_msl(current_msl_path)),
  ## get Virus Metadata Resource
  tar_target(current_vmr_path, download_current_msl(url = "https://ictv.global/vmr/current"),
             format = "file",
             cue = tar_cue(mode = "always")),
  tar_target(ictv_vmr_version, get_ictv_version(ictv_url = "https://ictv.global/sites/default/files/VMR/", current_vmr_path)),
  tar_target(vmr, read_current_vmr(current_vmr_path)),
  tar_target(phage_taxa, find_uniform_taxa(data = vmr, host = c("bacteria","archaea"))),
  tar_target(template, generate_template()),
  tar_target(temp_csv, readr::write_csv(template, here::here("Intermediate/Template.csv"))),
  # tar_target(temp_csv_virion, readr::write_csv(template, here::here("outputs/template.csv"))),
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


# CLOVER - from 02_0_Format Clover -----
clover_targets <- tar_plan(
  tar_target(clo_path, get_clover()), # clover csv from github
  # Clover is a static dataset so NCBI taxonomy shifts and needs to be 
  # validated
  tar_target(clo, readr::read_csv(clo_path) |>
               dplyr::mutate(HostNCBIResolved = FALSE,
                             PathogenNCBIResolved = FALSE)
             ),
  ## clean clover hosts ----
  tar_target(clo_host_vec, clo |>
               dplyr::pull(Host) %>%
               unique() %>%
               sort()),
  tar_target(clo_host_table, jhdict(spnames = clo_host_vec)),
  tar_target(
    clo_host_table_path, readr::write_csv(clo_host_table, here::here("./Intermediate/CLOVERHostTax.csv"))
  ),
  tar_target(clo_hosts_clean, clo_clean_hosts(clo, clo_host_table)),
  ## clean clover viruses ----
  tar_target(clo_virus_vec, clo %>%
               dplyr::pull(Pathogen) %>%
               unique() %>%
               sort()),
  tar_target(clo_virus_table, jvdict(spnames = clo_virus_vec)),
  tar_target(clo_virus_table_path, readr::write_csv(clo_virus_table, here::here("./Intermediate/GBVirusTax.csv"))),
  tar_target(clo_virus_clean, clo_clean_viruses(clo_hosts_clean, clo_virus_table)),
  
  ## format clover data ----
  tar_target(clo_formatted, format_clover(clo = clo_virus_clean,
                                          clover_template = template)),
  tar_target(clo_formatted_path, readr::write_csv(clo_formatted, here::here("./Intermediate/Formatted/CLOVERFormatted.csv")))
)


# download genbank ----

genbank_download_targets <- tar_plan(
  tar_target(genbank_path, get_genbank(), 
             format = "file",
             cue = tar_cue(mode = "always")),
  tar_target(gb, read_genbank(genbank_path))
)

# Digest genbank ----

genbank_digest_targets <- tar_plan(
  # tar_target(gb, tibble::as_tibble(seq)), # this actually takes awhile
  tar_target(host_vec, gb |>
    dplyr::pull(Host) %>%
    unique() %>%
    sort()),

  # clean up hosts
  # tar_target(test_julia_jhdict, jhdict(c("apis"))),
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
    tar_target(gb_virus_clean, gb_clean_viruses(gb_hosts_clean, virus_table))
    # tar_target(gb_virus_clean_path, vroom::vroom_write(gb, here::here(
    #   "./Intermediate/Unformatted/GenBankUnformatted.csv.gz"
    # )))
  )


# Format Genbank -----

format_genbank_targets <- tar_plan(
  tar_target(gb_database_version, sprintf("https://ftp.ncbi.nlm.nih.gov/genomes/Viruses/AllNuclMetadata/ accessed on %s",
                                       lubridate::today(tzone = "UTC"))),
  tar_target(gb_formatted, format_genbank(gb = gb_virus_clean,
                                          temp = template,
                                          database_version = gb_database_version))
  # tar_target(gb_formatted_path, vroom::vroom_write(gb_formatted, "Intermediate/Formatted/GenbankFormatted.csv.gz"))
)


# run: |
#   Rscript -e 'source("Code/05_Dissolve VIRION.R")'


# # digest predict ----
# # format predict ----
# # digest predict  pcr ----
# # format predict  pcr ----
# # merge predict and add genera ----
predict_targets <- tar_plan(
  predict_all_formatted = vroom(here::here("./Intermediate/Formatted/PREDICTAllFormatted.csv"),
                                col_type = cols(PMID = col_double(),
                                                PublicationYear = col_double()
                                ) 
  ) %>% 
    # drop sp as it returns false specificity,
    dplyr::mutate(HostOriginal= stringr::str_replace(HostOriginal," sp\\.","")) %>% 
    # some work as has already been done to reconcile names with NCBI
    dplyr::mutate(HostOriginal = dplyr::coalesce(Host, HostOriginal)), 
  ## align hosts to NCBI taxonomy
  tar_target(pre_host_vec, predict_all_formatted |>
               dplyr::pull(HostOriginal) %>% 
               unique() %>%
               sort()),
  tar_target(pre_host_table, jhdict(spnames = pre_host_vec)),
  tar_target(
    pre_host_table_path, 
    readr::write_csv(pre_host_table, 
        here::here("./Intermediate/PREDICTHostTax.csv")
        )
  ),
  tar_target(predict_all_formatted_hosts_clean, 
             pre_clean_hosts(predict_all_formatted, pre_host_table)
             )
  
  
)

# # merge clean files ----
merge_clean_files_targets <- tar_plan(
  #gb_formatted
  #clo_formatted
  #predict formatted
  virion_unprocessed = dplyr::bind_rows(
    clo_formatted,
    predict_all_formatted_hosts_clean, 
    gb_formatted),
  # virion_unprocessed_path = vroom::vroom_write(virion_unprocessed, "./Intermediate/Formatted/VIRIONUnprocessed.csv.gz")
)
# # high level checks ----
high_level_check_targets <- tar_plan(
  ### maybe convert to data.table - we will see
  # tar_target(virion_no_phage, remove_phage(virion_unprocessed,phage_taxa),garbage_collection = TRUE),
  # ictv = readr::read_csv("Source/ICTV Master Species List 2019.v1.csv"),
  # tar_target(virion_ictv_ratified, ratify_virus(virion_no_phage,ictv)),
  # tar_target(virion_clover_hosts, clean_clover_hosts(virion_ictv_ratified),garbage_collection = TRUE),
  # tar_target(virion_unique_path, deduplicate_virion(virion_clover_hosts)), ## rolls up NCBI accession numbers and writes data
  tar_target(virion_unique_path, high_level_checks(virion_unprocessed = virion_unprocessed, 
                                                   phage_taxa = phage_taxa,
                                                   ictv = ictv
                                                   ))
  
  # tar_target(virion_unique_path, vroom::vroom_write(virion_unique, "outputs/virion.csv.gz",delim = ","))
)
# # dissolve virion ----
dissovle_virion_targets <- tar_plan(
  tar_target(virion_has_taxa_id, virion_unique_path %>%  
               dplyr::filter(
             # dplyr::filter(!is.na(HostTaxID),
             #        !is.na(VirusTaxID))
               HostTaxID != "",
               VirusTaxID != ""
               )
             ),
  tar_target(host_tax,virion_has_taxa_id %>%
               dplyr::select(HostTaxID, Host, HostGenus, HostFamily, HostOrder, HostClass, HostNCBIResolved) %>% 
               dplyr::distinct() %>% 
               dplyr::arrange(Host)
               ),
  tar_target(virus_tax, 
             virion_has_taxa_id %>% 
               dplyr::group_by(VirusTaxID, Virus, VirusGenus, VirusFamily, VirusOrder, VirusClass, VirusNCBIResolved, ICTVRatified) %>% 
               dplyr::summarise(Database = paste(unique(Database),collapse = "; ")) %>% 
               dplyr::ungroup() %>% 
               dplyr::arrange(Virus) %>%
               unique() 
             ),
  tar_target(host_tax_path, write_csv(host_tax, "./outputs/taxonomy_host.csv")),
  tar_target(virus_tax_path, write_csv(virus_tax, "./outputs/taxonomy_virus.csv")),
  tar_target(virion_reduced_tax, 
             virion_has_taxa_id %>% 
               select(-c(Host, HostNCBIResolved, HostGenus, HostFamily, HostOrder, HostClass,
                         Virus, VirusNCBIResolved, VirusGenus, VirusFamily, VirusOrder, VirusClass, ICTVRatified)) %>% 
               mutate(AssocID = row_number()) %>%
               relocate(AssocID, .before = everything())#
              ),
  tar_target(provenance_path, 
             virion_reduced_tax %>%
               select(AssocID, 
                      HostOriginal, VirusOriginal, 
                      Database, DatabaseVersion,
                      ReferenceText, 
                      PMID) %>% 
               vroom_write("./outputs/provenance.csv.gz",delim = ",")
             ),
  tar_target(detection_path,
             virion_reduced_tax %>% 
               select(AssocID,
                      DetectionMethod,
                      DetectionOriginal, 
                      HostFlagID,
                      NCBIAccession) %>% 
               vroom::vroom_write( file = "./outputs/detection.csv.gz",delim = ",")
             ),
  tar_target(temporal_path, 
             virion_reduced_tax %>% 
               select(AssocID, 
                      PublicationYear, 
                      ReleaseYear, 
                      ReleaseMonth, 
                      ReleaseDay,
                      CollectionYear, 
                      CollectionMonth, 
                      CollectionDay) %>% 
               vroom_write( "./outputs/temporal.csv.gz",delim = ",")
             ),
  ### write csvs
  # provenance_path =  vroom_write(provenance, "./outputs/provenance.csv.gz",delim = ","),
  # detection_path = vroom::vroom_write(x = detection, file = "./outputs/detection.csv.gz",delim = ","),
  # temporal_path = vroom_write(temporal, "./outputs/temporal.csv.gz",delim = ","),
  tar_target(virion_edge_list, get_virion_edge_list(virion_reduced_tax)),
  tar_target(virion_edge_list_path,write_csv(virion_edge_list, "./outputs/edgelist.csv") )
)

# deposit data ----

# Everything that is current on the gh-pages site plus more metadata 

deposit_targets <- tar_plan(
  # create metadata
  ## link to original paper
  ## link to github repo for the virion code NOT for virionData
  tar_target(latest_repo_doi, get_zenodo_release_doi()),
  ## link to CLOVER, PREDICT, GENBANK
  tar_target(isPartOf,
              # code
              list(
                list (
                  identifier = latest_repo_doi, # assumes we are making releases after PRs
                  relation = "isDerivedFrom",
                  resource_type = "software"
                ),
                # paper
                list (
                  identifier = "10.1128/mbio.02985-21",
                  relation = "isDescribedBy",
                  resource_type = "publication"
                ),
                # genbank
                list(
                  identifier = gb_database_version,
                  relation = "requires",
                  resource_type = "dataset"
                ),
                # clover
                list(
                  identifier = "10.5281/zenodo.5167655",
                  relation = "requires",
                  resource_type = "dataset"
                ),
                # predict
                list(
                  identifier = "https://catalog.data.gov/dataset/predict-animals-sampled-c593d",
                  relation = "requires",
                  resource_type = "dataset"
                ),
                # ictv msl
                list(
                  identifier = ictv_msl_version,
                  relation = "requires",
                  resource_type = "dataset"
                ),
                # ictv vmr
                list(
                  identifier = ictv_vmr_version,
                  relation = "requires",
                  resource_type = "dataset"
                )
              )
            ),
  ## get creators
  tar_target(deposit_creators, get_creators(gh_url = "https://api.github.com/repos/viralemergence/virion/contributors")),
  
  # time created
  tar_target(time_created, dcmi_date_time(), cue = tar_cue("always")),
  
  
  # description 
  tar_target(zenodo_description,
             "This deposit contains a dynamically maintained database of vertebrate-virus associations. 
 The VIRION database has been assembled through both reconciliation 
 of static data sets and integration of dynamically updated databases.
 These data sources are all harmonized against one taxonomic backbone,
 including metadata on host and virus taxonomic validity and higher 
 classification; additional metadata on sampling methodology and 
 evidence strength are also available in a harmonized format.
 
 Data Products:
 1) virion.csv.gz - Virion dataset. All other data products are derived
 from Virion. 
 2) temporal.csv.gz - Publication and collection data from Virion.
 3) provenance.csv.gz - Sources used to compile virion.
 4) detection.csv.gz - Methods used to determine the presence of viruses in Virion.
 5) edgelist.csv - Host Virus associations. Only contains taxa aligned to NCBI taxonomy.
 6) taxonomy_host.csv - Host taxonomic data. Only contains taxa aligned to NCBI taxonomy.
 7) taxonomy_virus.csv"),
  
  # make metadata list 
  tar_target(metadata,
               list(
                 title = "The Global Virome in One Network (VIRION): Data Package",
                 description = zenodo_description,
                 creator = deposit_creators,
                 created = time_created,
                 isPartOf = isPartOf,
                 accessRights = "open",
                 license = "ODbL-1.0",
                 language = "eng",
                 subject = list(keywords = list("global vertebrate virome","host-virus interactions","ecological networks"))
               )
             ),
  # update resources and deposit data
  ## publish the data?
  tar_target(publish, TRUE),
  ## 
  tar_target(deposit_outcome, 
             deposit_data(metadata = metadata, 
                          outputs = list(virion = virion_unique_path,
                                         host_tax = host_tax_path,
                                         virus_tax = virus_tax_path,
                                         provenance = provenance_path,
                                         detection = detection_path,
                                         temporal = temporal_path,
                                         virion_edge_list = virion_edge_list_path),
                          resource = here::here("outputs"),
                          publish = publish)
             )
)

# 
 list(
   initial_targets,
   clover_targets,
   genbank_download_targets,
   genbank_digest_targets,
   format_genbank_targets,
   predict_targets,
   merge_clean_files_targets,
   high_level_check_targets,
   dissovle_virion_targets
   # ,
   # deposit_targets
 )
