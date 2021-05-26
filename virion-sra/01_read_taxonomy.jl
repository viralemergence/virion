using JSON
using DataFrames
import CSV
using Query
using GZip
using DelimitedFiles

# Taxonomy file
taxonomy_file = joinpath("..", "sra_tax_analysis_tool", "taxonomy", "2020_09_01_000000000000.gz")
taxonomy_raw = GZip.open(taxonomy_file)
taxonomy = JSON.parse.(readlines(taxonomy_raw))

# Function to get i levels to a number
_l2i = (x) -> parse(Int64, x)

# Function to get a list of taxids
function taxids_for_group(group_name, taxonomy; level=nothing)
    # Position of the group
    group_position = findfirst(r -> r["sci_name"] == group_name, taxonomy)
    group = taxonomy[group_position]
    # Boundaries of the group
    group_i_min = _l2i(group["ileft"])
    group_i_max = _l2i(group["iright"])
    # Members of the group
    group_members = filter(r -> (_l2i(r["ileft"])>=group_i_min)&(_l2i(r["iright"])<=group_i_max), taxonomy)
    if !isnothing(level)
        filter!(gm -> gm["rank"] == level, group_members)
    end
    return [(member["tax_id"], member["sci_name"]) for member in group_members]
end

viruses_raw = taxids_for_group("Viruses", taxonomy; level="species")
viruses = DataFrame(tax_id = String[], name = String[])
[push!(viruses, r) for r in viruses_raw]
CSV.write("taxonomy_viruses.csv", viruses)
DelimitedFiles.writedlm("viruses.ids", viruses.tax_id)

hosts_raw = taxids_for_group("Vertebrata", taxonomy; level="species")
hosts = DataFrame(tax_id = String[], name = String[])
[push!(hosts, r) for r in hosts_raw]
CSV.write("taxonomy_hosts.csv", hosts)
DelimitedFiles.writedlm("hosts.ids", hosts.tax_id)
