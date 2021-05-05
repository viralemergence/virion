<p align = "center">
  <img src="Virion.png" width="200">
</p>

\  
\ 
 
 
  
# VIRION: The Virome, in One Network

VIRION is the most comprehensive open database describing the vertebrate-virus network. The VIRION database is curated by an entire team of researchers, with the aim of being up-to-date, accurate, transparent, and useful.

# How to use VIRION

You probably haven't worked with a dataset like VIRION before. Read this before you start your analysis:

VIRION includes a mix of _fixed_ and _probabilistic_ interactions. Fixed interactions are known host-virus associations that come from NCBI GenBank and the CLOVER dataset (which is itself a reconciled version of four other datasets: HP3, GMPD2, EID2, and Shaw), and are based on a mix of serology, PCR, and isolation. Probabilistic interactions come from NCBI's Sequence Read Archive (SRA), which includes a mix of targeted sequencing (e.g. whole genomes of isolated virus or PCR products) and shotgun sequencing (e.g. metagenomic or metatranscriptomic data). In any given SRA sample, there may be a mix of different viruses from the given host, and it is challenging to know whether the genome fragments that are present in the sample necessarily indicate the _definite_ presence of a _specific_ virus.We take advantage of a taxonomic analysis using _k_-mer matching performed by NCBI, which returns a score indicating the relative likelihood any virus in NCBI's records has been found in that sample. We validated those data against known records to come up with a very strict cutoff, a test that only X% of possible host-virus pairs pass. The score column is calculated as... (@ryan or @tim please add details)

Even though that analysis is incredibly conservative, users should be _very_ careful about whether or not they include these interactions in their analysis. Example problems they might encounter:
- The highest scoring match might be a known relative of an unknown virus (for example, in a sample with a novel SARS-like bat coronavirus, the highest score might be returned for SARS-CoV proper)
- The score could be indicative of cross-contamination 
- The score could be indicative of experimental (laboratory) infection, which - unlike isolation records - might not necessarily indicate that host can be infected with that virus
- The score might be a product of technological issues (@ryan or @angie add: what's that one virus that always shows up in metagenomic samples because of how they're calibrated?)

As such, users may want to remove all of these records entirely from the dataset, which can be done in a single line of code using the `DetectionMethod` or `Database` columns, e.g., 

```
library(tidyverse); library(magrittr)
virion %<>% filter(!(DetectionMethod == "kmer")) # option 1
virion %<>% filter(!(Database == "SRA")) # option 2 (currently equivalent)
```

Other, more advanced users may be interested in using the entire edgelist of possible host-virus associations in SRA, which is found in `SRA_as_Edgelist.zip`. Alternate scoring methods that are less conservative will include many more false positives, but also potentially more true positives. 

In the long term, we're interested in partnering with virologists and bioinformaticians to develop score metrics that are more informative (for example, % of reference genome recovered) or more advanced ways of mining metagenomic and metatranscriptomic samples for novel (currently undiscovered) viruses, which are both outside the scope of our current dataset and may confound certain analyses with it.

# The workflow

VIRION aggregates three major sources of information:
- CLOVER (see github.com/viralemergence/clover), which combines four major datasets on host-pathogen interactions
- NCBI GenBank, specifically the entirety of NCBI Virus accessions stored in the Nucleotide database
- NCBI SRA, which inculdes a mix of "normal" records and metagenomic samples, which have undergone an NCBI-based taxonomic analysis based on _k_-mers.

Unlike nearly every dataset familiar to disease ecologists, the dataset includes a mix of fixed interactions (records based on serology, PCR, or isolation that link a given host and virus pair) and probabilistic interactions (_k_-mer based estimates of the probability a given virus is being detected in a given sample). As such, the data cannot be used off the shelf, and should be *carefully* used with attention to the mix between fixed and probabilistic data.

### Current Workflow (Dec. 20, 2020)

1. Processing the NCBI GenBank dataset
- GenBank data were downloaded as a flat file on Nov. 20, 2020
- A script has been adapted from the CLOVER workflow that implements taxonomic cleaning using the R package `taxize`
- All 8,000+ hosts in GenBank were cleaned following this protocol, and bound to the GenBank file
- This was then subsetted to vertebrate records only
- (Not yet implemented) These need to be linked to the NCBI taxonomy using either `taxize` or `NCBITaxonomy.jl`, which will capture records at high taxonomic levels (e.g., bacterial family: Enterobacteriaceae), including specific use cases of unresolved names (e.g., "Bacillus sp." needs to be split into "Bacillus" based on a special "* sp." case, so the genus can be linked to _Bacillus_)
- (Not yet implemented) All host and virus taxonomy should be filtered to every virus recorded associated with vertebrates

2. Processing the NCBI SRA dataset
- @Tim and @Ryan eventually we need a lot more about how we get from SRA raw to NCBI-SRA 
- Using a Python script with the list of host names, every mammal name is subsetted to a file that is used to filter the SRA data down
- SRA-Mammals is compared against CLOVER and a cutoff log(score) is selected that maximizes the kappa statistic, treating CLOVER records as true presences and every other pair as pseudoabsences
- SRA-Vertebrates is re-thresholded 

3. VIRION is assembled
- GenBank is formatted into the CLOVER template, and added
- SRA is formatted into the CLOVER template, and added
- (Not yet implemented) as a final step, all phage families are removed using NCBITaxonomy or Ryan's python script

# The team

VIRION owes significant thanks to the entire Verena Consortium for conception, design input, and beta testing.

### Developers 
- Gregory Albery (Georgetown University)
- Colin Carlson (Georgetown University)
- Ryan Connor (NCBI)
- Rory Gibb (London School of Tropical Medicine and Hygiene)
- Timothée Poisot (Université de Montreal)

### Contact
- For general questions about VIRION, please reach out to Colin Carlson (colin.carlson@georgetown.edu).
- For specific questions about VIRION-SRA, please contact Timothée Poisot (timothee.poisot@umontreal.ca) 
- For specific questions about CLOVER, please contact Rory Gibb (rory.gibb.14@ucl.ac.uk)
