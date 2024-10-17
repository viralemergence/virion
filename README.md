# The VIRION database

![GitHub last commit (branch)](https://img.shields.io/github/last-commit/viralemergence/virion/gh-pages)
![](https://img.shields.io/badge/Code%20license-MIT-green)
![](https://img.shields.io/badge/Data%20license-CC--0-brightgreen)

VIRION is an atlas of the vertebrate-virus network, maintained by [Verena](https://www.viralemergence.org/), an NSF Biology Integration Institute developing an open data ecosystem for zoonotic and vector-borne disease ecology. The development of the VIRION database through 2022 is documented [here](https://journals.asm.org/doi/10.1128/mbio.02985-21); as we work to transition to a new platform, an interim changelog can also be found below. We strongly encourage researchers to read both the _mBio_ publication and this README file before using these data.

> [!NOTE]
> Over the coming months, we hope to roll out additional changes. Goals include:
> - a revision of the license VIRION is distributed under
> - incorporation of new data sources
> - improved data standardization and taxonomic reconciliation
> - periodic updates to the static components of CLOVER to address known errors


## Citing VIRION

You can cite the study that describes VIRION as:

Carlson CJ, Gibb RJ, Albery GF, Brierley L, Connor R, Dallas T, Eskew EA, Fagre AC, Farrell MJ, Frank HK, Muylaert RL, Poisot T, Rasmussen AL, Ryan SJ, Seifert SN. The Global Virome in One Network (VIRION): an Atlas of Vertebrate-Virus Associations. mBio. 2022 Mar 1. DOI: 10.1128/mbio.02985-21.

If you want to cite the VIRION database directly, you can also use refer to [![DOI](https://zenodo.org/badge/319686363.svg)](https://zenodo.org/badge/latestdoi/319686363).


## Download VIRION

- [**Full database**](https://github.com/viralemergence/virion/blob/main/Virion/Virion.csv.gz)

- [**Simplified edgelist**](https://github.com/viralemergence/virion/blob/main/Virion/Edgelist.csv.gz)

- [**Provenance metadata**](https://github.com/viralemergence/virion/blob/main/Virion/Provenance.csv.gz)

- [**Detection metadata**](https://github.com/viralemergence/virion/blob/main/Virion/Detection.csv.gz)

- [**Temporal metadata**](https://github.com/viralemergence/virion/blob/main/Virion/Temporal.csv.gz)

- [**Host higher taxonomy**](https://github.com/viralemergence/virion/blob/main/Virion/TaxonomyHost.csv.gz)

- [**Virus higher taxonomy**](https://github.com/viralemergence/virion/blob/main/Virion/TaxonomyVirus.csv.gz)

## Pipeline

The VIRION database is periodically re-compiled from two static sources (CLOVER and PREDICT) and one dynamic source (GenBank). If you want to reproduce the vignettes we present in the publication, you can also download the entire release of [version 0.2.1](https://github.com/viralemergence/virion/releases/tag/v0.2.1-beta).

```mermaid
flowchart TB

%% Nodes
    GMPD2("GMPD2")
    HP3("HP3")
    Shaw("Shaw")
    EID2("EID2 (2015)")

    RECON1("
**Reconciliation 1**
• names reconciled to NCBI taxonomy
• temporal and sampling metadata standardized
• manual curation of unmatched names
*mammals only!*")

    style RECON1 text-align:left, fill:#efefef, stroke:#a0a0a0;
    style RECON2 text-align:left, fill:#efefef, stroke:#a0a0a0;

    CLOVER("CLOVER")

    GenBank("fa:fa-arrows-spin GenBank")

    PREDICT("fa:fa-box-archive PREDICT")

    RECON2("**Reconciliation 2**
• update of dynamic datasets (GenBank)
• names reconciled to NCBI and ICTV
• additional quality checks
• community sourcing for validation
")


    subgraph virion[**Virion flat files**]
        Virion["fa:fa-file-zipper Virion.csv.gz"]
        Edgelist["fa:fa-table Edgelist.csv"]
        TaxonomyHost["fa:fa-table TaxonomyHost.csv"]
        TaxonomyVirus["fa:fa-table TaxonomyVirus.csv"]
        Provenance["fa:fa-file-zipper Provenance.csv.gz"]
        Detection["fa:fa-file-zipper Detection.csv.gz"]
        Temporal["fa:fa-file-zipper Temporal.csv.gz"]
        direction TB
        Edgelist --> Virion
        TaxonomyHost --> Virion
        TaxonomyVirus --> Virion
        Provenance --> Virion
        Detection --> Virion
        Temporal --> Virion
    end

    style virion stroke:#a0a0a0, fill:#efefef;

%% Edge connections between nodes
    GMPD2 --> RECON1;
    HP3 --> RECON1;
    Shaw --> RECON1;
    EID2 --> RECON1;
    RECON1 --> CLOVER;

    CLOVER --> RECON2;
    GenBank --> RECON2;
    PREDICT --> RECON2;

    RECON2 --> virion;

%% Individual node styling. Try the visual editor toolbar for easier styling!
    style GMPD2 color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF
    style HP3 color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF
    style Shaw color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF
    style EID2 color:#FFFFFF, fill:#AA00FF, stroke:#AA00FF

    style CLOVER color:#FFFFFF, stroke:#00C853, fill:#00C853

    style GenBank color:#FFFFFF, stroke:#2962FF, fill:#2962FF
    style PREDICT color:#FFFFFF, stroke:#2962FF, fill:#2962FF

%% You can add notes with two "%" signs in a row!
```

# How we built VIRION

VIRION aggregates seven major sources of information, two of which can be dynamically updated (\*):
- CLOVER, a Verena-curated [database](https://github.com/viralemergence/clover), which reconciles four static datasets on host-pathogen interactions.
- The [public data](https://healthmap.org/predict) released by the USAID Emerging Pandemic Threats PREDICT program.
- NCBI GenBank\*, specifically the entirety of NCBI Virus accessions stored in the Nucleotide database.

![Virion overview](VIRION2.jpg)

# How to use VIRION

VIRION can be used for everything from deep learning to simple biological questions. For example, if you wanted to ask which bats a betacoronavirus (like SARS-CoV or MERS-CoV) has ever been isolated from, you could run this `R` code:

```r
> library(tidyverse); library(vroom)
>
> virion <- vroom("Virion/Virion.csv.gz")
>
> virion %>%
+   filter(VirusGenus == "betacoronavirus",
+          HostOrder == "chiroptera",
+          DetectionMethod == "Isolation/Observation") %>%
+   pull(Host) %>%
+   unique()
[1] "chaerephon plicatus" "pipistrellus abramus" "rhinolophus affinis"      
[4] "rhinolophus ferrumequinum" "rhinolophus macrotis" "rhinolophus pearsonii"    
[7] "rhinolophus sinicus" "rousettus leschenaultii" "tylonycteris pachypus"
```

It's that simple! Here's a few small tips and tricks you should know:
- All resolved taxonomy is lowercase (see the above example); original metadata may retain case as reported in source files, and non-taxonomic metadata is not all lowercase
- Some valid records have NA's in their taxonomy; for example, if an unclassified _Betacoronavirus_ is found in a mouse, it might be recorded as NA in the "Virus" field. This is an intentional feature, as it enables researchers to talk about higher-level taxonomic patterns, and [some studies](https://www.biorxiv.org/content/10.1101/2020.05.22.111344v4) may not need fully-resolved data.
- Sometimes, you'll see taxonomy that's outdated or strange. If you think there's an error, please leave an issue on the Github. Before you do, it may be worth checking whether a given name is correctly resolved to the NCBI taxonomy; for example, in R, you can use `taxize::classification("Whateverthe latinnameis", db = "ncbi")`. If the issue is related to that taxonomic backbone, please label your issue `ncbi-needed`
- Different databases may have overlapping records. For example, some PREDICT records are deposited in GenBank, and some GenBank records are inherited by EID2. As different data has passed between these sources, they've often lost some metadata. Presence in different datasets therefore does not indicate stronger / weaker evidence, and conversely, conflicting evidence between databases may not be indicative of any biological evidence.

## File organization and assembly

For now, VIRION lives on Github in a fully open and reproducible format. Downloading the data directly from this website, or cloning the repository, is the easiest way to access the data. To avoid relying on the Large File Storage system, the VIRION database itself is stored in two file formats:

1. The entire database is available in `Virion/Virion.csv.gz` which can be easily read as-is using the [`vroom` package](https://vroom.r-lib.org/).
2. The NCBI-matched components of the database are also available in a disaggregated format with a backbone (Edgelist.csv), two taxonomic metadata files (HostTaxonomy.csv, VirusTaxonomy.csv), and three sampling metadata files (Provenance.csv.gz, Detection.csv.gz, Temporal.csv.gz). The taxonomy files can be joined to the backbone with the `HostTaxID` and `VirusTaxID` fields, while the metadata files can be joined by the `AssocID` field (which must first be separated into unique rows). For simple tasks, not every join will be needed.

## What you should probably know about the data

Like most datasets that record host-virus associations, this includes a mix of different lines of evidence, diagnostic methods, and metadata quality. Some associations will be found in every database, with every evidence standard; others will be recorded from a single serological data point with unclear attribution. VIRION can aggregate all this data for you, but it's your job as a researcher to be thoughtful about how you use these data. Some suggested best practices:

- As a starting point, you can remove any records that aren't taxonomically resolved to the NCBI backbone (`HostNCBIResolved == FALSE, VirusNCBIResolved == FALSE`). We particularly suggest this for data that come from other databases that also aggregate content but use multiple taxonomic backbones, which may include invalid names that are not updated.

- You should also be wary of records with a flag that indicates host identification by researchers was uncertain (`HostFlagID == TRUE`).

- Limiting evidence standards based on diagnostic standards (e.g., using Nucleotide and Isolation/Observation records, but no Antibodies) or based on redundancy (i.e., number of datasets that record an association) can also lead to stronger results.

> [!CAUTION]
> We encourage particular caution with regard to the validity of virus names. Although the NCBI and ICTV taxonomies are updated against each other, valid NCBI names are not guaranteed to be ICTV-valid species level designations, and many may include sampling metadata. We recommend that researchers manually curate names where possible, but can also use simple rubrics to reduce down controversial names. For example, in the list of NCBI-accepted betacoronavirus names, eliminating all virus names that include a "/" (e.g., using `stringr::str_detect()`) will reduce many lineage-specific records ("bat coronavirus 2265/philippines/2010", "coronavirus n.noc/vm199/2007/nld") and leave behind cleaner names ("alpaca coronavirus") but won't necessarily catch everything ("bat coronavirus ank045f"). Another option is to limit analysis to viruses that are ICTV ratified (`ICTVRatified == TRUE`), but this is particularly conservative, and will leave a much larger number of valid virus names out.

# Additional information

## Reproducing VIRION

VIRION is an open database with a CC-0 license. As such, you can do just about anything with it that you'd like. We would _prefer_ it not be reproduced into other formats that lose intentional aspects of VIRION's design (e.g., in other databases that drop metadata like evidence standards; as static supplemental files on studies that will never be updated; etc.), but it's your party! That said: if you see ways to improve taxonomic corrections, add new data sources, or improve the format for credit and attribution, please contact us, so we can work together to keep improving this resource.

## Contact

- For general questions about VIRION, please reach out to [Colin Carlson](mailto:colin.carlson@yale.edu)
- For specific questions about the CLOVER dataset, please contact [Rory Gibb](mailto:rory.gibb.14@ucl.ac.uk)
- For specific questions about the GitHub actions pipeline, please contact [Timothée Poisot](mailto:timothee.poisot@umontreal.ca)

## Changelog 

**October 17, 2024**: The GLOBI dataset has been de-indexed from VIRION, due to a growing number of concerns about the reliability of text-mined data. This represents an important departure from the pipeline described in the _mBio_ publication. The current pipeline is described at the top of this README
