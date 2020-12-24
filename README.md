<img align="right" src="Virion.png"  width="200">

# VIRION: The Virome, in One Network

VIRION is the crown jewel of Verena's open data ecosystem, and is the largest open database of host-virus interactions encompassing the vertebrate virome. The VIRION database is curated by an entire team of researchers, with the aim of being up-to-date, accurrate, transparent, and useful.

# The team

### Active Curators

Gregory Albery (Georgetown University)

Colin Carlson (Georgetown University)

Ryan Connor (NCBI)

Rory Gibb (London School of Tropical Medicine and Hygiene)

Timothée Poisot (Université de Montreal)

### Points of Contact

If you have a question about the structure of the data, please reach out to Timothée Poisot (timothee.poisot@umontreal.ca) or Colin Carlson (colin.carlson@georgetown.edu).

# The workflow

VIRION aggregates three major sources of information:
- CLOVER (see github.com/viralemergence/clover), which combines four major datasets on host-pathogen interactions
- NCBI GenBank, specifically the entirety of NCBI Virus accessions stored in the Nucleotide database
- NCBI SRA, which inculdes a mix of "normal" records and metagenomic samples, which have undergone an NCBI-based taxonomic analysis based on _k_-mers.

Unlike nearly every dataset familiar to disease ecologists, the dataset includes a mix of fixed interactions (records based on serology, PCR, or isolation that link a given host and virus pair) and probabilistic interactions (_k_-mer based estimates of the probability a given virus is being detected in a given sample). As such, the data cannot be used off the shelf, and should be *carefully* used with attention to the mix between fixed and probabilistic data.

### Current Workflow (Dec. 20, 2020)

1. Processing the GenBank dataset
- GenBank data were downloaded as a flat file on Nov. 20, 2020
- A script has been adapted from the CLOVER workflow that implements taxonomic cleaning using the R package `taxize`
- All 8,000+ hosts in GenBank need to be cleaned following this protocol
- (Not yet implemented) These need to be linked to the NCBI taxonomy using either `taxize` or `NCBITaxonomy.jl`, which will capture records at high taxonomic levels (e.g., bacterial family: Enterobacteriaceae), including specific use cases of unresolved names (e.g., "Bacillus sp." needs to be split into "Bacillus" based on a special "* sp." case, so the genus can be linked to _Bacillus_)
- (Not yet implemented) All host and virus taxonomy should be filtered to every virus recorded associated with vertebrates

2. Merging GenBank into the CLOVER backbone (Not yet implemented)
- The column names need to be harmonized across these datasets
- Bespoke columns need to be added to the GenBank component that identify the provenance of the data (GenBank), the diagnostic method ("PCR / Sequence")
- The records need to be joined

3. Processing the NCBI SRA dataset
- (?)

4. Merging the NCBI SRA dataset into the CLOVER backbone
- (?)
