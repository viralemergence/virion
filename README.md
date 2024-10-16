
Access the database at the web interface [here](https://viralemergence.github.io/virion/).

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

    RECON2("**Reconcliliation 2**
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
