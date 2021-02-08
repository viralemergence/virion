using NCBITaxonomy
using DataFrames
import CSV
using ProgressMeter

# Read the virion master data
virion = DataFrame(CSV.File(joinpath("Virion", "Virion-Master.csv")))

# DF for results
virion_cleanup = DataFrame(original = String[], name = String[], type = String[], taxid = Int64[], fuzzy = Bool[], different = Bool[])
virion_tax = DataFrame(taxid = Int64[], rank = Symbol[], name = String[], id = Int64[])

unique_hosts = unique(virion.Host)
unique_viruses = unique(virion.Virus)

hf = vertebratefinder(true)
vf = virusfinder()

@showprogress for host in unique_hosts
    ncbi_tax = hf(host)
    fuzzy = false
    if isnothing(ncbi_tax)
        fuzzy = true
        ncbi_tax = hf(host; fuzzy=true)
    end
    # Get the cleaned name
    push!(virion_cleanup,(
        host, ncbi_tax.name, "host", ncbi_tax.id, fuzzy, host != ncbi_tax.name
    ))
    # Get the taxonomy
    lin = lineage(ncbi_tax)
    rnk = rank.(lin)
    class = findfirst(isequal(:class), rnk)
    for i in class:length(rnk)
        push!(virion_tax,(
            ncbi_tax.id, rnk[i], lin[i].name, lin[i].id
        ))
    end
end


@showprogress for virus in unique_viruses
    ncbi_tax = vf(virus)
    fuzzy = false
    if isnothing(ncbi_tax)
        fuzzy = true
        ncbi_tax = vf(virus; fuzzy=true)
    end
    # Get the cleaned name
    push!(virion_cleanup,(
        virus, ncbi_tax.name, "virus", ncbi_tax.id, fuzzy, virus != ncbi_tax.name
    ))
    # Get the taxonomy
    lin = lineage(ncbi_tax)
    rnk = rank.(lin)
    class = findfirst(isequal(:class), rnk)
    class = isnothing(class) ? 1 : class
    for i in class:length(rnk)
        push!(virion_tax,(
            ncbi_tax.id, rnk[i], lin[i].name, lin[i].id
        ))
    end
end

CSV.write("cleaned_named.csv", virion_cleanup)
CSV.write("taxonomy.csv", virion_tax)