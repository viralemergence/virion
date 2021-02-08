using NCBITaxonomy
using DataFrames
import CSV

# Read the virion master data
virion = DataFrames(CSV.File(joinpath("Virion", "Virion-Master.csv")))

# DF for results
virion_cleanup = DataFrame(original = String[], name = String[], taxid = Int64[], fuzzy = Bool[], synonym = Bool[])
virion_tax = DataFrame(taxid = String[], rank = String[], name = String[], id = Int64[])

# Get the unique hosts
for sp in species
    portal_name = sp["species"] == "sp." ? sp["genus"] : sp["genus"]*" "*sp["species"]
    ncbi_tax = taxid(portal_name)
    if isnothing(ncbi_tax)
        ncbi_tax = taxid(portal_name; fuzzy=true)
    end
    ncbi_lin = lineage(ncbi_tax)
    push!(cleanup,
        (
            sp["species_id"], portal_name, ncbi_tax.name, rank(ncbi_tax),
            first(filter(t -> isequal(:order)(rank(t)), lineage(ncbi_tax))).name,
            ncbi_tax.id
        )
    )
end