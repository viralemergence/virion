using NCBITaxonomy
using DataFrames
import CSV

# Read the virion master data
virion = DataFrame(CSV.File(joinpath("Virion", "Virion-Master.csv")))

# DF for results
virion_cleanup = DataFrame(original = String[], name = String[], type = String[], taxid = Int64[], fuzzy = Bool[], synonym = Bool[])
virion_tax = DataFrame(taxid = String[], rank = String[], name = String[], id = Int64[])

unique_hosts = unique(virion.Host)
unique_viruses = unique(virion.Virus)

hf = vertebratefinder(true)
vf = virusfinder()

for host in unique_hosts[1:10]
    ncbi_tax = hf(host)
    fuzzy = false
    if isnothing(ncbi_tax)
        fuzzy = true
        ncbi_tax = hf(host; fuzzy=true)
    end
    push!(virion_cleanup,(
        host, ncbi_tax.name, "host", ncbi_tax.id, fuzzy, host == ncbi_tax.name
    ))
end
